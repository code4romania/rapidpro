# Domain
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_identity_verification" "main_verification" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [aws_route53_record.main_ses_verification_record]
}

# DKIM
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# MAIL FROM
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.domain_name}"
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
