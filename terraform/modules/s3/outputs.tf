output "bucket" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "iam_user" {
  value = try(module.iam_user.0.name, null)
}

output "secret_arn" {
  value = try(module.iam_user.0.secret_arn, null)
}
