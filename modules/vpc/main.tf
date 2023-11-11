resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.vpc_name}-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-IG"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name                                          = "da-mlops-test-public-${count.index}",
    "kubernetes.io/cluster/my-cluster" = "enabled",
    "kubernetes.io/role/elb"                      = "1"
  }
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name                                          = "da-mlops-test-private-${count.index}",
    "kubernetes.io/cluster/my-cluster" = "enabled",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_eip" "nat_gateways" {
  count = length(aws_subnet.private_subnets)
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.private_subnets)
  allocation_id = element(aws_eip.nat_gateways, count.index).id
  subnet_id     = element(aws_subnet.private_subnets, count.index).id
}

resource "aws_subnet" "database_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.database_subnet_cidrs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}


# ROUTE TABLE

resource "aws_route_table" "private_subnets" {
  count  = length(aws_nat_gateway.nat_gw)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gw, count.index).id
  }

  tags = {
    Name = "Private Subnet Route Table"
  }
}

resource "aws_route_table" "database_subnets" {
  count  = length(aws_nat_gateway.nat_gw)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gw, count.index).id
  }

  tags = {
    Name = "Database Subnet Route Table"
  }
}

# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_subnets[*].id, count.index)
}

resource "aws_route_table_association" "database_subnet_asso" {
  count          = length(aws_subnet.database_subnets)
  subnet_id      = element(aws_subnet.database_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.database_subnets[*].id, count.index)
}