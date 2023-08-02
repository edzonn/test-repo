# create aws vpc

resource "aws_vpc" "da-mlops-prod-vpc" {
  cidr_block           = "10.22.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "da-mlops-prod-vpc"
  }
}

resource "aws_internet_gateway" "da-mlops-prod-igw" {
  vpc_id     = aws_vpc.da-mlops-prod-vpc.id
  depends_on = [aws_vpc.da-mlops-prod-vpc]

  tags = {
    Name = "da-mlops-prod-igw"
  }
}

# create eip

resource "aws_eip" "da-mlops-prod-eip" {
  count      = 1
  vpc        = true
  depends_on = [aws_internet_gateway.da-mlops-prod-igw]

  tags = {
    Name = "da-mlops-prod-eip"
  }
}

# create public subnet

resource "aws_subnet" "da-mlops-prod-public-subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-prod-vpc.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.da-mlops-prod-igw]

  tags = {
    Name                                          = "da-mlops-prod-public-${count.index}",
    "kubernetes.io/cluster/da-mlops-prod-cluster" = "enabled",
    "kubernetes.io/role/elb"                      = "1"
  }
}

# create routeable public subnet

resource "aws_route_table" "da-mlops-prod-pub-rtb" {
  vpc_id = aws_vpc.da-mlops-prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.da-mlops-prod-igw.id
  }
  # depends_on = [ aws_internet_gateway.da-mlops-prod-igw ]

  tags = {
    Name = "da-mlops-prod-pub-rtb"
  }
}

resource "aws_nat_gateway" "da-mlops-prod-natgw" {
#   count         = length(var.public_subnet_cidr)
#   allocation_id = element(aws_eip.da-mlops-prod-eip.*.id, count.index)
#   subnet_id     = element(aws_subnet.da-mlops-prod-public-subnet.*.id, count.index)

count         = 1
allocation_id = aws_eip.da-mlops-prod-eip[0].id
subnet_id     = aws_subnet.da-mlops-prod-public-subnet[0].id

  tags = {
    Name = "da-mlops-prod-natgw-0"
  }
}

# create route tables

resource "aws_route_table" "da-mlops-prod-priv-rtb" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.da-mlops-prod-vpc.id

  tags = {
    Name = "da-mlops-prod-priv-rtb-${count.index}"
  }
}

# create aws_route
resource "aws_route" "da-mlops-prod-priv-route" {
  count                  = length(var.private_subnet_cidr)
  route_table_id         = element(aws_route_table.da-mlops-prod-priv-rtb.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  # nat_gateway_id         = element(aws_nat_gateway.da-mlops-prod-natgw.*.id, count.index)
  nat_gateway_id = aws_nat_gateway.da-mlops-prod-natgw[0].id
}

resource "aws_route_table_association" "da-mlops-prod-pub-rtba" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-prod-public-subnet.*.id, count.index)
  route_table_id = aws_route_table.da-mlops-prod-pub-rtb.id

  # tags = {
  #     Name = "da-mlops-prod-pub-rtba"
  # }
}

# create private subnet

resource "aws_subnet" "da-mlops-prod-private-subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-prod-vpc.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # map_public_ip_on_launch = true
  depends_on = [aws_route_table.da-mlops-prod-priv-rtb]

  tags = {
    Name                                          = "da-mlops-prod-private-${count.index}",
    "kubernetes.io/cluster/da-mlops-prod-cluster" = "enabled",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# create route table association

resource "aws_route_table_association" "da-mlops-prod-priv-rtba" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-prod-private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.da-mlops-prod-priv-rtb.*.id, count.index)

  # tags = {
  #     Name = "da-mlops-prod-priv-rtba"
  # }
}

# create aws subnet db

resource "aws_subnet" "da-mlops-prod-db-sub" {
  count             = length(var.private_db_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-prod-vpc.id
  cidr_block        = element(var.private_db_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # map_public_ip_on_launch = true
  depends_on = [aws_route.da-mlops-prod-priv-route]

  tags = {
    Name = "da-mlops-prod-db-${count.index}"
  }
}

# create aws subnet db route table association

resource "aws_route_table_association" "da-mlops-prod-db-rtba" {
  count          = length(var.private_db_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-prod-db-sub.*.id, count.index)
  route_table_id = element(aws_route_table.da-mlops-prod-priv-rtb.*.id, count.index)

  # tags = {
  #     Name = "da-mlops-prod-db-rtba"
  # }
}

# create aws db subnet group

resource "aws_db_subnet_group" "da-mlops-prod-db-subnet-group" {
  name       = "da-mlops-prod-db-subnet-group"
  subnet_ids = aws_subnet.da-mlops-prod-db-sub.*.id
  # depends_on = [aws_route_table_association.da-mlops-prod-db-rtba]

  tags = {
    Name = "da-mlops-prod-db-subnet-group"
  }
}

resource "aws_vpc_endpoint" "da-mlops-prod-ecrapi-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    security_group_ids = [aws_security_group.da-mlops-prod-ecrapi-sg.id]
    subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecrapi-endpoint"
    }
}

# create ecrdkr endpoint

resource "aws_vpc_endpoint" "da-mlops-prod-ecrdkr-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    security_group_ids = [aws_security_group.da-mlops-prod-ecrdkr-sg.id]
    subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecrdkr-endpoint"
    }
}

# create ecrapi ecr s3 endpoint

# resource "aws_vpc_endpoint" "da-mlops-prod-ecrapi-ecr-s3-endpoint" {
#     vpc_id = aws_vpc.da-mlops-prod-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecr.api"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-prod-ecrapi-sg.id]
#     subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-prod-ecrapi-ecr-s3-endpoint"
#     }
# }

# create ecs s3 endpoint

resource "aws_vpc_endpoint" "da-mlops-prod-ecs-s3-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.s3"
    vpc_endpoint_type = "Gateway"
    private_dns_enabled = false
    # security_group_ids = [aws_security_group.da-mlops-prod-ecs-sg.id]
    # subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecs-s3-endpoint"
    }
}

# create ecs-agent endpoint.

resource "aws_vpc_endpoint" "da-mlops-prod-ecs-agent-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.ecs-agent"
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    security_group_ids = [aws_security_group.da-mlops-prod-ecs-sg.id]
    subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecs-agent-endpoint"
    }
}

# create ecs-telemetry endpoint
resource "aws_vpc_endpoint" "da-mlops-prod-ecs-telemetry-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.ecs-telemetry"
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    security_group_ids = [aws_security_group.da-mlops-prod-ecs-sg.id]
    subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecs-telemetry-endpoint"
    }
}

# create ecs endpoint
resource "aws_vpc_endpoint" "da-mlops-prod-ecs-endpoint" {
    vpc_id = aws_vpc.da-mlops-prod-vpc.id
    service_name = "com.amazonaws.${var.region}.ecs"
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    security_group_ids = [aws_security_group.da-mlops-prod-ecs-sg.id]
    subnet_ids = aws_subnet.da-mlops-prod-private-subnet.*.id
    tags = {
        Name = "da-mlops-prod-ecs-endpoint"
    }
}

