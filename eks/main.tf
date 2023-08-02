# terraform {
#   required_providers {
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = "2.21.1"  # Replace with the desired version
#     }
#   }
# }

terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "terraform_remote_state" "module_outputs" {
  backend = "local" # This assumes local backend; adjust according to your setup
  config = {
    path = "../vpc/terraform.tfstate"
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

      instance_types = ["t3.small"]


      min_size      = 1
      max_size      = 3
      desired_size  = 2
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
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

resource "null_resource" "configure_kubectl" {
  # count = var.aws_region != "" && module.eks_managed_node_group.cluster_id != null ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_managed_node_group.cluster_name} --kubeconfig /mnt/c/Users/user/Desktop/terraform/test-repo/eks/kubeconfig.yaml
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
  type: gp2  # Adjust the volume type as needed (e.g., io1, sc1, st1)
EOF
  depends_on = [kubectl_manifest.ebs_csi_driver]
}


resource "kubernetes_storage_class" "da-mlops-prod-storageclass" {
  metadata {
    name = "da-mlops-prod-storageclass"
  }
  # storageclass
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type      = "gp2"
    fsType    = "ext4"
    encrypted = "true"
  }
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  mount_options          = ["debug"]
  # depends_on             = [kubernetes_namespace.da-mlops-prod-namespace]
}

# resource "kubernetes_namespace" "da-mlops-prod-namespace" {
#   metadata {
#     name = "da-mlops-prod-namespace"
#   }
#   depends_on = [kubernetes_storage_class.da-mlops-prod-storageclass]
# }

