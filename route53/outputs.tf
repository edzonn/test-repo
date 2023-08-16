# create outputs route53

output "route53_zone_id" {
  value = aws_route53_zone.opensearch.zone_id
}

output "route53_zone_name" {
  value = aws_route53_zone.opensearch.name
}

output "route53_zone_name_servers" {
  value = aws_route53_zone.opensearch.name_servers
}

output "arn_certificate" {
    value = aws_acm_certificate.opensearch.arn
}
