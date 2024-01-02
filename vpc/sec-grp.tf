resource "aws_security_group" "da-mlops-test-ecrdkr-sg" {
  name        = "da-mlops-test-ecrdkr-sg"
  description = "Security group for DA MLOps testuction ECR Docker"

  vpc_id = aws_vpc.da-mlops-test-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "da-mlops-test-ecrapi-sg" {
  name        = "da-mlops-test-ecrapi-sg"
  description = "Security group for DA MLOps testuction ECR API"

  vpc_id = aws_vpc.da-mlops-test-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# da-mlops-test-ecs-sg

resource "aws_security_group" "da-mlops-test-ecs-sg" {
  name        = "da-mlops-test-ecs-sg"
  description = "Security group for DA MLOps testuction ECS"

  vpc_id = aws_vpc.da-mlops-test-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}