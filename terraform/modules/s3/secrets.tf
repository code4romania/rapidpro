resource "aws_secretsmanager_secret" "this" {
  count = local.create_iam_user ? 1 : 0
  name  = "${var.name}-s3-access"
}

resource "aws_secretsmanager_secret_version" "this" {
  count     = local.create_iam_user ? 1 : 0
  secret_id = aws_secretsmanager_secret.this.0.id

  secret_string = jsonencode({
    "access_key_id"     = aws_iam_access_key.this.0.id
    "secret_access_key" = aws_iam_access_key.this.0.secret
  })
}
