

provider "aws" {
  region = "ap-southeast-1"
}



data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

module "eks_managed_node_group" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "my-cluster"
  cluster_version                = "1.27"
  subnet_ids                     = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
  vpc_id                         = data.terraform_remote_state.module_outputs.outputs.vpc_id
  cluster_endpoint_public_access = true
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]


      min_size      = 1
      max_size      = 2
      desired_size  = 1
      capacity_type = "ON_DEMAND"
      labels = {
        disktype = "test"
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = "arn:aws:kms:ap-southeast-1:396246268796:key/d885b304-ea34-41f4-89ab-eece88bfb663"
          }
        }
      }
    }

    two = {
      name           = "node-group-2"
      instance_types = ["t3.medium"]
      min_size       = 0
      max_size       = 2
      desired_size   = 0
    }
  }
}

# create dyamic scaling policy

resource "aws_autoscaling_policy" "cpu_scaling_policy" {
  name                   = "cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  # create autoscaling policy for node group 1
  autoscaling_group_name = module.eks_managed_node_group.eks_managed_node_groups_autoscaling_group_names[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

# create predictive scaling

resource "aws_appautoscaling_scheduled_action" "predictive_scaling" {
  name                 = "predictive-scaling"
  service_namespace    = "eks"
  scalable_dimension   = "eks:node-group:DesiredCapacity"
  resource_id          = module.eks_managed_node_group.eks_managed_node_groups_autoscaling_group_names[0]
  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }
  schedule = "at(2021-09-30T00:00:00)"
}


resource "null_resource" "configure_kubectl" {
  # count = var.aws_region != "" && module.eks_managed_node_group.cluster_id != null ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
# aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_managed_node_group.cluster_name} --kubeconfig /mnt/c/Users/user/Desktop/terraform/test-repo/eks/kubeconfig.yaml

aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_managed_node_group.cluster_name}
EOF
  }
  depends_on = [module.eks_managed_node_group]
}

resource "kubectl_manifest" "ebs_csi_driver" {
  yaml_body  = <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ebs-csi-driver
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: ebs-csi-driver
  template:
    metadata:
      labels:
        app: ebs-csi-driver
    spec:
      containers:
        - name: ebs-csi-driver
          image: amazon/aws-ebs-csi-driver:v1.3.0
          volumeMounts:
            - name: plugin-dir
              mountPath: /csi
          env:
            - name: AWS_REGION
              value: "${var.aws_region}"
      volumes:
        - name: plugin-dir
          hostPath:
            path: /var/lib/kubelet/plugins/kubernetes.io/csi
EOF
  depends_on = [null_resource.configure_kubectl]
}

resource "kubectl_manifest" "ebs_storage_class" {
  yaml_body  = <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
parameters:
  type: gp2
EOF
  depends_on = [kubectl_manifest.ebs_csi_driver]
}

resource "kubectl_manifest" "da_mlops_prod_namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: da-mlops-prod-namespace
EOF
}

resource "kubectl_manifest" "da_mlops_prod_storageclass" {
  yaml_body  = <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: da-mlops-prod-storageclass
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  capacity: 20Gi
  fsType: ext4
  encrypted: "true"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - "debug"
EOF
  depends_on = [kubectl_manifest.da_mlops_prod_namespace]
}