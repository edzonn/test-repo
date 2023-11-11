resource "aws_rds_cluster" "da-mlops-prod-rds-cluster" {
  cluster_identifier      = "da-mlops-prod-rds-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.07.2"
  database_name           = "da_mlops_prod_db"
  master_username         = "da_mlops_prod_db_user"
  master_password         = "da_mlops_prod_db_password"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.da-mlops-prod-db-sg.id]
  db_subnet_group_name    = aws_db_subnet_group.da-mlops-prod-db-subnet-group.name
  storage_encrypted       = true
  deletion_protection     = false
  apply_immediately       = true
  tags = {
    Name = "da-mlops-prod-rds-cluster"
  }
}


