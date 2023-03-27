output "bucket" {
  value = aws_s3_bucket.this.bucket
}

output "iam_user" {
  value = try(aws_iam_user.this[0], null)
}

output "secret_arn" {
  value = try(aws_secretsmanager_secret.this.0.arn, null)
}
