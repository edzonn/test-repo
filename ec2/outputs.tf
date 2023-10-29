output "elb_dns" {
    value = aws_lb.da-mlops-test-lb.dns_name  
}