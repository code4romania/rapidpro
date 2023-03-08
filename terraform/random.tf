resource "random_string" "s3_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}
