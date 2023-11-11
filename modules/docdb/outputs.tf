output "cluster_id" {
  value = aws_docdb_cluster.docdb_cluster.id
}

output "instance_ids" {
  value = aws_docdb_cluster_instance.docdb_instance.*.id
}