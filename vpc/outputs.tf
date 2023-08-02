
output "vpc_id" {
  value = aws_vpc.da-mlops-prod-vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.da-mlops-prod-private-subnet.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.da-mlops-prod-public-subnet.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.da-mlops-prod-priv-rtb.*.id
}

output "public_route_table_ids" {
  value = aws_route_table.da-mlops-prod-pub-rtb.*.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.da-mlops-prod-natgw.*.id
}

output "nat_gateway_public_ips" {
  value = aws_nat_gateway.da-mlops-prod-natgw.*.public_ip
}

output "nat_gateway_private_ips" {
  value = aws_nat_gateway.da-mlops-prod-natgw.*.private_ip
}


