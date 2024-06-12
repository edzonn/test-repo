
output "vpc_id" {
  value = aws_vpc.da-mlops-test-vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.da-mlops-test-private-subnet.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.da-mlops-test-public-subnet.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.da-mlops-test-priv-rtb.*.id
}

output "public_route_table_ids" {
  value = aws_route_table.da-mlops-test-pub-rtb.*.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.da-mlops-test-natgw.*.id
}

output "nat_gateway_public_ips" {
  value = aws_nat_gateway.da-mlops-test-natgw.*.public_ip
}

output "nat_gateway_private_ips" {
  value = aws_nat_gateway.da-mlops-test-natgw.*.private_ip
}

output "database_subnet_group_id" {
  value = aws_db_subnet_group.da-mlops-test-db-subnet-group.id
}

output "database_subnet_private_subnet" {
  value = aws_db_subnet_group.da-mlops-test-db-subnet-group.subnet_ids
}

output "cidr_block" {
  value = aws_vpc.da-mlops-test-vpc.cidr_block
}

output "bastion_subnet_id" {
  value = aws_subnet.da-mlops-test-bastion-subnet.*.id
}

