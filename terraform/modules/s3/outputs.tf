output "bucket" {
  value = aws_s3_bucket.this.bucket
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}
