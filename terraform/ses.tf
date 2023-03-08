# Domain
resource "aws_ses_domain_identity" "main" {
  domain = var.ses_domain
}

resource "aws_route53_record" "main_ses_verification_record" {
  zone_id = var.ses_domain_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_ses_domain_identity_verification" "main_verification" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [aws_route53_record.main_ses_verification_record]
}

# DKIM
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = var.ses_domain_zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.ses_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# MAIL FROM
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.ses_domain}"
}

resource "aws_route53_record" "mx_send_mail_from" {
  zone_id = var.ses_domain_zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

# SPF validation record
resource "aws_route53_record" "spf_mail_from" {
  zone_id = var.ses_domain_zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

# DMARC
resource "aws_route53_record" "txt_dmarc" {
  zone_id = var.ses_domain_zone_id
  name    = "_dmarc.${var.ses_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=quarantine;"]
}


data "aws_iam_policy_document" "ses_email_send" {
  statement {
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]

    resources = [aws_ses_domain_identity.main.arn]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_ses_identity_policy" "email_send_policy" {
  identity = aws_ses_domain_identity.main.arn
  name     = "email-send-policy"
  policy   = data.aws_iam_policy_document.ses_email_send.json
}
