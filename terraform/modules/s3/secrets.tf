resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}-s3-access"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode({
    "access_key_id"     = aws_iam_access_key.this.id
    "secret_access_key" = aws_iam_access_key.this.secret
  })
}
