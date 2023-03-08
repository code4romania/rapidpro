resource "aws_s3_bucket" "mailroom" {
  bucket = "${local.mailroom.namespace}-${random_string.s3_bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "mailroom" {
  bucket = aws_s3_bucket.mailroom.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mailroom_public_access_block" {
  bucket = aws_s3_bucket.mailroom.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mailroom" {
  bucket = aws_s3_bucket.mailroom.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_access_key" "mailroom" {
  user = aws_iam_user.mailroom.name
}

resource "aws_iam_user" "mailroom" {
  name = "${local.mailroom.namespace}-user"
}

data "aws_iam_policy_document" "mailroom_bucket_acccess" {
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
      aws_s3_bucket.mailroom.arn,
      "${aws_s3_bucket.mailroom.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "mailroom_access_policy" {
  name   = "${local.mailroom.namespace}-s3-access-policy"
  user   = aws_iam_user.mailroom.name
  policy = data.aws_iam_policy_document.mailroom_bucket_acccess.json
}
