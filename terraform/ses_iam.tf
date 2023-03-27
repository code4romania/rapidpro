resource "aws_iam_user" "smtp" {
  name = "${local.namespace}-smtp-user"
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

resource "aws_secretsmanager_secret" "smtp" {
  name = "${local.namespace}-smtp"
}

resource "aws_secretsmanager_secret_version" "smtp" {
  secret_id = aws_secretsmanager_secret.smtp.id
  secret_string = jsonencode({
    from     = "no-reply@${var.domain_name}"
    host     = "email-smtp.${var.region}.amazonaws.com"
    port     = 587
    user     = aws_iam_access_key.smtp.id
    password = aws_iam_access_key.smtp.ses_smtp_password_v4
  })
}

data "aws_iam_policy_document" "ses_email_send" {
  statement {
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]

    resources = [aws_ses_domain_identity.main.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.smtp.arn]
    }
  }
}

resource "aws_ses_identity_policy" "email_send_policy" {
  identity = aws_ses_domain_identity.main.arn
  name     = "email-send-policy"
  policy   = data.aws_iam_policy_document.ses_email_send.json
}
