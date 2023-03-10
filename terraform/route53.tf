resource "aws_route53_zone" "main" {
  name = var.domain_name
}

# ACM / validation
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}


# RapidPro A record
resource "aws_route53_record" "rapidpro_public_ipv4" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.rapidpro.domain
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# RapidPro AAAA record
resource "aws_route53_record" "rapidpro_public_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.rapidpro.domain
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# U-Report RO A record
resource "aws_route53_record" "ureport_ro_public_ipv4" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.ureport.domains.ro
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# U-Report RO AAAA record
resource "aws_route53_record" "ureport_ro_public_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.ureport.domains.ro
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# U-Report UK A record
resource "aws_route53_record" "ureport_uk_public_ipv4" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.ureport.domains.uk
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# U-Report UK AAAA record
resource "aws_route53_record" "ureport_uk_public_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.ureport.domains.uk
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# SES / verification
resource "aws_route53_record" "main_ses_verification_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

# SES / DKIM
resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = aws_route53_zone.main.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SES / MAIL FROM
resource "aws_route53_record" "mx_send_mail_from" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

# SES / SPF validation record
resource "aws_route53_record" "spf_mail_from" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

# SES / DMARC
resource "aws_route53_record" "txt_dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=quarantine;"]
}
