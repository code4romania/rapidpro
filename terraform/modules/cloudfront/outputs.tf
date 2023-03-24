output "domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "Domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net."
}
