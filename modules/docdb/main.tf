resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier         = var.cluster_identifier
  engine                     = var.engine
  master_username            = var.master_username
  master_password            = var.master_password
  apply_immediately          = var.apply_immediately   
  skip_final_snapshot        = var.skip_final_snapshot
  db_subnet_group_name       = var.db_subnet_group_name
  vpc_security_group_ids     = var.vpc_security_group_ids
  tags                       = var.tags
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  count              = var.instance_count
  identifier         = var.instance_identifier[count.index]
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.instance_class
  apply_immediately  = true
  tags               = var.tags
}