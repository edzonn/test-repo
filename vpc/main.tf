resource "aws_vpc" "da-mlops-test-vpc" {
  cidr_block           = "10.22.0.0/16"
  instance_tenancy     = "default"
  assign_generated_ipv6_cidr_block = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "da-mlops-test-vpc"
  }
}

resource "aws_internet_gateway" "da-mlops-test-igw" {
  vpc_id     = aws_vpc.da-mlops-test-vpc.id
  depends_on = [aws_vpc.da-mlops-test-vpc]

  tags = {
    Name = "da-mlops-test-igw"
  }
}

# create eip

resource "aws_eip" "da-mlops-test-eip" {
  count      = 1
  vpc        = true
  depends_on = [aws_internet_gateway.da-mlops-test-igw]

  tags = {
    Name = "da-mlops-test-eip"
  }
}

resource "aws_nat_gateway" "da-mlops-test-natgw" {
count         = 1
allocation_id = aws_eip.da-mlops-test-eip[0].id
subnet_id     = aws_subnet.da-mlops-test-public-subnet[0].id

  tags = {
    Name = "da-mlops-test-natgw-0"
  }
}

resource "aws_subnet" "da-mlops-test-public-subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-test-vpc.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  depends_on = [aws_internet_gateway.da-mlops-test-igw]

  tags = {
    Name                                          = "da-mlops-test-public-${count.index}",
    "kubernetes.io/cluster/test-cluster-da" = "enabled",
    "kubernetes.io/role/elb"                      = "1"
  }
}

# create bastion_subnet

resource "aws_subnet" "da-mlops-test-bastion-subnet" {
  count             = 1
  vpc_id            = aws_vpc.da-mlops-test-vpc.id
  cidr_block        = var.bastion_subnet
  availability_zone = element(var.availability_zones, count.index)
  depends_on = [aws_internet_gateway.da-mlops-test-igw]

  tags = {
    Name = "da-mlops-test-bastion"
  }
}

# create route table bastion

resource "aws_route_table" "da-mlops-test-bastion-rtb" {
  vpc_id = aws_vpc.da-mlops-test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.da-mlops-test-igw.id
  }
  tags = {
    Name = "da-mlops-test-bastion-rtb"
  }
}

# create route table association bastion

resource "aws_route_table_association" "da-mlops-test-bastion-rtba" {
  count          = 1
  subnet_id      = aws_subnet.da-mlops-test-bastion-subnet[0].id
  route_table_id = aws_route_table.da-mlops-test-bastion-rtb.id
}

# create private subnet

resource "aws_subnet" "da-mlops-test-private-subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-test-vpc.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  # ipv6_cidr_block = "${cidrsubnet(aws_vpc.da-mlops-test-vpc.ipv6_cidr_block, 8, 4)}"
  availability_zone = element(var.availability_zones, count.index)
  # map_public_ip_on_launch = true
  depends_on = [aws_route_table.da-mlops-test-priv-rtb]

  tags = {
    Name                                          = "da-mlops-test-private-${count.index}",
    "kubernetes.io/cluster/test-cluster-da" = "enabled",
    "kubernetes.io/role/internal-elb"             = "1",
    "kubernetes.io/role/elb" = "1"
  }
}

# create aws subnet db

resource "aws_subnet" "da-mlops-test-db-sub" {
  count             = length(var.private_db_subnet_cidr)
  vpc_id            = aws_vpc.da-mlops-test-vpc.id
  cidr_block        = element(var.private_db_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # depends_on = [aws_route.da-mlops-test-priv-route]

  tags = {
    Name = "da-mlops-test-db-${count.index}"
  }
}

# # # create aws_route
# resource "aws_route" "da-mlops-test-priv-route" {
#   count                  = length(var.private_subnet_cidr)
#   route_table_id         = element(aws_route_table.da-mlops-test-priv-rtb.*.id, count.index)
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = element(aws_nat_gateway.da-mlops-test-natgw.*.id, count.index)
#   # nat_gateway_id = aws_nat_gateway.da-mlops-test-natgw[0].id

# }


# create routeable public subnet

resource "aws_route_table" "da-mlops-test-pub-rtb" {
  vpc_id = aws_vpc.da-mlops-test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.da-mlops-test-igw.id
  }
  tags = {
    Name = "da-mlops-test-pub-rtb"
  }
}


# create route tables

resource "aws_route_table" "da-mlops-test-priv-rtb" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.da-mlops-test-vpc.id

  tags = {
    Name = "da-mlops-test-priv-rtb-${count.index}"
  }
}


resource "aws_route_table_association" "da-mlops-test-pub-rtba" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-test-public-subnet.*.id, count.index)
  route_table_id = aws_route_table.da-mlops-test-pub-rtb.id
}

resource "aws_route_table" "da-mlops-test-priv-rtb-1" {
  count = length(var.private_db_subnet_cidr)
  vpc_id = aws_vpc.da-mlops-test-vpc.id

  tags = {
    Name = "da-mlops-test-priv-rtb-1-${count.index}"
  }
}

# create route table association

resource "aws_route_table_association" "da-mlops-test-priv-rtba" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-test-private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.da-mlops-test-priv-rtb.*.id, count.index)
}



# create aws subnet db route table association

# resource "aws_route_table_association" "da-mlops-test-db-rtba" {
#   count          = length(var.private_db_subnet_cidr)
#   subnet_id      = element(aws_subnet.da-mlops-test-db-sub.*.id, count.index)
#   route_table_id = element(aws_route_table.da-mlops-test-priv-rtb.*.id, count.index)
# }

resource "aws_route_table_association" "da-mlops-test-db-rtba-1" {
  count          = length(var.private_db_subnet_cidr)
  subnet_id      = element(aws_subnet.da-mlops-test-db-sub.*.id, count.index)
  route_table_id = element(aws_route_table.da-mlops-test-priv-rtb-1.*.id, count.index)
}

# create aws db subnet group

resource "aws_db_subnet_group" "da-mlops-test-db-subnet-group" {
  name       = "da-mlops-test-db-subnet-group"
  subnet_ids = aws_subnet.da-mlops-test-db-sub.*.id
  tags = {
    Name = "da-mlops-test-db-subnet-group"
  }
}

# resource "aws_vpc_endpoint" "da-mlops-test-ecrapi-endpoint" {
#     vpc_id = aws_vpc.da-mlops-test-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecr.api"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-test-ecrapi-sg.id]
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-ecrapi-endpoint"
#     }
# }

# # create ecrdkr endpoint

# resource "aws_vpc_endpoint" "da-mlops-test-ecrdkr-endpoint" {
#     vpc_id = aws_vpc.da-mlops-test-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecr.dkr"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-test-ecrdkr-sg.id]
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-ecrdkr-endpoint"
#     }
# }

# # create ecrapi ecr s3 endpoint

# # resource "aws_vpc_endpoint" "da-mlops-test-ecrapi-ecr-s3-endpoint" {
# #     vpc_id = aws_vpc.da-mlops-test-vpc.id
# #     service_name = "com.amazonaws.${var.region}.ecr.api"
# #     vpc_endpoint_type = "Interface"
# #     private_dns_enabled = true
# #     security_group_ids = [aws_security_group.da-mlops-test-ecrapi-sg.id]
# #     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
# #     tags = {
# #         Name = "da-mlops-test-ecrapi-ecr-s3-endpoint"
# #     }
# # }

# # create ecs s3 endpoint

resource "aws_vpc_endpoint" "da-mlops-test-ecs-s3-endpoint" {
    vpc_id = aws_vpc.da-mlops-test-vpc.id
    service_name = "com.amazonaws.${var.region}.s3"
    vpc_endpoint_type = "Gateway"
    private_dns_enabled = false
    # security_group_ids = [aws_security_group.da-mlops-test-ecs-sg.id]
    # subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
    route_table_ids = flatten([
          aws_route_table.da-mlops-test-priv-rtb[*].id,
          [aws_route_table.da-mlops-test-pub-rtb.id]
  ])

    tags = {
        Name = "da-mlops-test-ecs-s3-endpoint"
    }
}

# # create ecs-agent endpoint.

# resource "aws_vpc_endpoint" "da-mlops-test-ecs-agent-endpoint" {
#     vpc_id = aws_vpc.da-mlops-test-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecs-agent"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-test-ecs-sg.id]
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-ecs-agent-endpoint"
#     }
# }

# # create ecs-telemetry endpoint
# resource "aws_vpc_endpoint" "da-mlops-test-ecs-telemetry-endpoint" {
#     vpc_id = aws_vpc.da-mlops-test-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecs-telemetry"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-test-ecs-sg.id]
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-ecs-telemetry-endpoint"
#     }
# }

# # create ecs endpoint
# resource "aws_vpc_endpoint" "da-mlops-test-ecs-endpoint" {
#     vpc_id = aws_vpc.da-mlops-test-vpc.id
#     service_name = "com.amazonaws.${var.region}.ecs"
#     vpc_endpoint_type = "Interface"
#     private_dns_enabled = true
#     security_group_ids = [aws_security_group.da-mlops-test-ecs-sg.id]
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-ecs-endpoint"
#     }
# }

# resource "aws_vpc_endpoint" "da-mlops-test-vpce" {
#   count                     = length(var.private_subnet_cidr)
#   vpc_id                    = aws_vpc.da-mlops-test-vpc.id
#   subnet_ids                = [element(aws_subnet.da-mlops-test-private-subnet.*.id, count.index)]
#   service_name              = "com.amazonaws.${var.region}.ec2" # EC2 endpoint service name
#   private_dns_enabled       = false
# }

# resource "aws_route" "da-mlops-test-priv-route" {
#   count                  = length(var.private_subnet_cidr)
#   route_table_id         = element(aws_route_table.da-mlops-test-priv-rtb.*.id, count.index)
#   destination_cidr_block = "0.0.0.0/0"
#   # nat_gateway_id         = element(aws_nat_gateway.da-mlops-test-natgw.*.id, count.index)
#   # If you want to route traffic to the VPC endpoint instead of the NAT Gateway:
#   gateway_id             = element(aws_vpc_endpoint.da-mlops-test-vpce.*.id, count.index)
# }

