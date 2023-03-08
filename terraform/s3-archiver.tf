resource "aws_s3_bucket" "archiver" {
  bucket = "${local.archiver.namespace}-${random_string.s3_bucket_suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "archiver_public_access_block" {
  bucket = aws_s3_bucket.archiver.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "archiver" {
  bucket = aws_s3_bucket.archiver.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_access_key" "archiver" {
  user = aws_iam_user.archiver.name
}

resource "aws_iam_user" "archiver" {
  name = "${local.archiver.namespace}-user"
}

data "aws_iam_policy_document" "archiver_bucket_acccess" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.archiver.arn,
      "${aws_s3_bucket.archiver.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "archiver_access_policy" {
  name   = "${local.archiver.namespace}-s3-access-policy"
  user   = aws_iam_user.archiver.name
  policy = data.aws_iam_policy_document.archiver_bucket_acccess.json
}
