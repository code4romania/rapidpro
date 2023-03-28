resource "aws_iam_user" "this" {
  name = "${var.name}-user"
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy" "this" {
  name   = "${var.name}-s3-access-policy"
  user   = aws_iam_user.this.name
  policy = var.policy
}
