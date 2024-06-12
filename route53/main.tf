resource "aws_route53_zone" "opensearch" {
  name = "edzon.com"
}
resource "aws_route53_zone" "test" {
  name = "test.edzon.com"

  tags = {
    Environment = "test"
  }
}

resource "aws_route53_record" "test-ns" {
  zone_id = aws_route53_zone.opensearch.zone_id
  name    = "test.edzon.com"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.test.name_servers
}

resource "aws_acm_certificate" "opensearch" {
  domain_name       = "edzon.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# crasete aws route53 record for certificate validation

resource "aws_route53_record" "opensearch" {
  zone_id = aws_route53_zone.opensearch.zone_id
  name    = aws_acm_certificate.opensearch.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.opensearch.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.opensearch.domain_validation_options.0.resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "opensearch" {
  certificate_arn         = aws_acm_certificate.opensearch.arn
  validation_record_fqdns = [aws_route53_record.opensearch.fqdn]
}


