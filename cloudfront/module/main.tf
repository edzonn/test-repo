# create cloudfront main.terraform 

resource "aws_cloudfront_distribution" "da-mlops-prod-cloudfront" {
  origin {
    domain_name = aws_s3_bucket.da-mlops-prod-s3-bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.da-mlops-prod-s3-bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "da-mlops-prod-cloudfront"
  price_class         = "PriceClass_100"
  http_version        = "http2"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.da-mlops-prod-s3-bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "da-mlops-prod-cloudfront"
  }
}


resource "aws_cloudfront_distribution" "example" {
  default_cache_behavior {
    allowed_methods = var.allowed_methods
    cached_methods  = var.cached_methods
    compress        = var.compress
    default_ttl     = var.default_ttl

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = var.target_origin_id
    viewer_protocol_policy = "allow-all"
  }

  enabled         = var.enabled
  http_version    = "http2"
  is_ipv6_enabled = var.is_ipv6_enabled

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = var.origin_domain_name
    origin_id   = var.origin_id
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}


module "cloudfront" {
  source = "./modules/cloudfront_distribution"

  allowed_methods       = ["GET", "HEAD"]
  cached_methods        = ["GET", "HEAD"]
  compress              = true
  default_ttl           = 86400
  target_origin_id      = "da-mlops-test-lb-02b8b583eddd3ed7.elb.ap-southeast-1.amazonaws.com"
  enabled               = true
  is_ipv6_enabled       = true
  origin_domain_name    = "da-mlops-test-lb-02b8b583eddd3ed7.elb.ap-southeast-1.amazonaws.com"
  origin_id             = "da-mlops-test-lb-02b8b583eddd3ed7.elb.ap-southeast-1.amazonaws.com"
}

# You can also reference outputs from the module if defined
output "example_id" {
  value = module.cloudfront.aws_cloudfront_distribution.example.id
}