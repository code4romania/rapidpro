resource "aws_iam_role" "autoscaling" {
  name               = "ECSAutoscalingRole-${local.namespace}"
  assume_role_policy = data.aws_iam_policy_document.autoscaling_role.json
}

resource "aws_iam_role_policy" "autoscaling" {
  name   = "${local.namespace}-autoscaling-policy"
  policy = data.aws_iam_policy_document.autoscaling_role_policy.json
  role   = aws_iam_role.autoscaling.id
}

data "aws_iam_policy_document" "autoscaling_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.application-autoscaling.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "autoscaling_role_policy" {
  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]

    resources = ["*"]
  }
}
