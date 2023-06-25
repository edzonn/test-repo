module "eks_managed_node_group" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.27"
  subnet_ids = ["subnet-0171ec076302cd911","subnet-02e5fd1742451ebb5","subnet-0f0c48b4cd4d60ad0"]
#   subnet_ids = ["subnet-03a6ef92f8d53354c","subnet-0a6572ba66dcb2a27","subnet-0a2e80c16fc0107a6"]
  vpc_id          = "vpc-077aac6ba34314277"
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }



}