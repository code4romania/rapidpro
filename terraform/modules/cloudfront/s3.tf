data "aws_s3_bucket" "this" {
  bucket = var.bucket
}

resource "aws_s3_bucket_policy" "this" {
  bucket = data.aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn
      ]
    }
  }
}
