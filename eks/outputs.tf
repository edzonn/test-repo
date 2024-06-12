output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks_managed_node_group.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks_managed_node_group.eks_managed_node_groups_autoscaling_group_names
}

# output for security group

output "eks_security_group_id" {
  description = "The ID of the security group created for the EKS cluster"
  value       = module.eks_managed_node_group.node_security_group_id
}

# output "eks_cluster_endpoint" {
#   description = "The endpoint for the EKS Kubernetes API"
#   value       = module.eks_cluster.eks_cluster_endpoint
# }

output "eks_cluster_endpoint" {
  description = "The name of the EKS cluster"
  value       = module.eks_managed_node_group.cluster_endpoint
}

# data "terraform_remote_state" "module_outputs_eks" {
#   backend = "s3"
#   config = {
#     bucket = "aws-terraform-tfstatefile-001"
#     key    = "dev/terraform-eks-test.statefile"
#     region = "ap-southeast-1"
#   }
# }

