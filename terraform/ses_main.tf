# Domain
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_identity_verification" "main_verification" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [aws_route53_record.main_ses_verification_record]
}

resource "aws_route53_record" "main_ses_verification_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

# DMARC
resource "aws_route53_record" "txt_dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=quarantine;"]
}

# Configuration set
resource "aws_ses_configuration_set" "main" {
  name                       = local.namespace
  sending_enabled            = true
  reputation_metrics_enabled = true

  delivery_options {
    tls_policy = "Require"
  }
}
