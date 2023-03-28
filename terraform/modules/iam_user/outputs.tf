output "name" {
  value = aws_iam_user.this.name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}
