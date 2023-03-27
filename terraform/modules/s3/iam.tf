resource "aws_iam_user" "this" {
  count = local.create_iam_user ? 1 : 0
  name  = "${var.name}-user"
}

resource "aws_iam_access_key" "this" {
  count = local.create_iam_user ? 1 : 0
  user  = aws_iam_user.this.0.name
}

resource "aws_iam_user_policy" "access_policy" {
  name   = "${var.name}-s3-access-policy"
  user   = local.create_iam_user ? aws_iam_user.this.0.name : var.iam_user
  policy = data.aws_iam_policy_document.bucket_acccess.json
}

data "aws_iam_policy_document" "bucket_acccess" {
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
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}
