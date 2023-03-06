resource "aws_acm_certificate" "rapidpro" {
  domain_name               = var.rapidpro_public_domain
  subject_alternative_names = ["*.${var.rapidpro_public_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
