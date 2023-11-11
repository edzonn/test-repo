module "docdb" {
  source = "./docdb"

  cluster_identifier    = "da-mlops-test-docdb"
  engine                = "docdb"
  master_username       = "admin"
  master_password       = "password"
  apply_immediately     = true
  skip_final_snapshot   = true
  db_subnet_group_name  = aws_db_subnet_group.da-mlops-test-docdb-subnet-group.name
  vpc_security_group_ids = [aws_security_group.da-mlops-test-docdb-sg.id]

  instance_count        = 2
  instance_identifier   = ["da-mlops-test-docdb-instance-1", "da-mlops-test-docdb-instance-2"]
  instance_class        = "db.r5.large"

  tags = {
    Name = "da-mlops-test-docdb"
  }
}