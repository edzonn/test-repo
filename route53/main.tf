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

# creeate certificate

resource "aws_acm_certificate" "opensearch" {
  domain_name       = "edzon.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


