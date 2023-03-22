resource "aws_iam_user" "this" {
  name = "${var.name}-user"
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy" "access_policy" {
  name   = "${var.name}-s3-access-policy"
  user   = aws_iam_user.this.name
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
