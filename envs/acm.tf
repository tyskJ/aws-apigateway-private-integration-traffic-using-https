/************************************************************
Public Certificate
************************************************************/
resource "aws_acm_certificate" "public_cert" {
  domain_name       = "acm.${var.domain_name}"
  validation_method = "DNS"
  key_algorithm     = "EC_prime256v1"
  tags = {
    Name = "internal-alb-public-certificate"
  }
  lifecycle {
    create_before_destroy = true
  }
}

/************************************************************
Public Certificate DNS Validation
************************************************************/
### Create CNAME Record
resource "aws_route53_record" "public_cert_cname_record" {
  for_each = {
    for dvo in aws_acm_certificate.public_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  zone_id         = var.public_hostedzone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}
### Validation
resource "aws_acm_certificate_validation" "public_cert_validation" {
  certificate_arn         = aws_acm_certificate.public_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.public_cert_cname_record : record.fqdn]
}