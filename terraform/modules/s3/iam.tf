data "aws_iam_policy_document" "this" {
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

module "iam_user" {
  source = "../../modules/iam_user"

  count  = local.create_iam_user ? 1 : 0
  name   = var.name
  policy = data.aws_iam_policy_document.this.json
}
