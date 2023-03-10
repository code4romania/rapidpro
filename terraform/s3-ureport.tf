resource "aws_s3_bucket" "ureport" {
  bucket = "${local.ureport.namespace}-${random_string.s3_bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "ureport" {
  bucket = aws_s3_bucket.ureport.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "ureport_public_access_block" {
  bucket = aws_s3_bucket.ureport.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ureport" {
  bucket = aws_s3_bucket.ureport.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_access_key" "ureport" {
  user = aws_iam_user.ureport.name
}

resource "aws_iam_user" "ureport" {
  name = "${local.ureport.namespace}-user"
}

data "aws_iam_policy_document" "ureport_bucket_acccess" {
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
      aws_s3_bucket.ureport.arn,
      "${aws_s3_bucket.ureport.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "ureport_access_policy" {
  name   = "${local.ureport.namespace}-s3-access-policy"
  user   = aws_iam_user.ureport.name
  policy = data.aws_iam_policy_document.ureport_bucket_acccess.json
}
