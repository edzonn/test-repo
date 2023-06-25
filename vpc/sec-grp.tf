resource "aws_security_group" "da-mlops-prod-ecrdkr-sg" {
  name        = "da-mlops-prod-ecrdkr-sg"
  description = "Security group for DA MLOps production ECR Docker"

  vpc_id = aws_vpc.da-mlops-prod-vpc.id

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

resource "aws_security_group" "da-mlops-prod-ecrapi-sg" {
  name        = "da-mlops-prod-ecrapi-sg"
  description = "Security group for DA MLOps production ECR API"

  vpc_id = aws_vpc.da-mlops-prod-vpc.id

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

# da-mlops-prod-ecs-sg

resource "aws_security_group" "da-mlops-prod-ecs-sg" {
  name        = "da-mlops-prod-ecs-sg"
  description = "Security group for DA MLOps production ECS"

  vpc_id = aws_vpc.da-mlops-prod-vpc.id

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