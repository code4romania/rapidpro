resource "aws_ecs_cluster" "main" {
  name = local.namespace
}

resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name = "ecs.svc" # ecsdemo.cloud
  vpc  = aws_vpc.main.id
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_security_group" "ecs" {
  name        = "${local.namespace}-ecs"
  description = "Inbound - Security Group attached to the ECS Service (${var.env})"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "task" {
  name               = "ECSTaskRole-remote-access"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy" "ssm_agent" {
  count  = var.enable_execute_command ? 1 : 0
  name   = "${local.namespace}-ssm-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.ssm_task_permissions.json
}

data "aws_iam_policy_document" "ssm_task_permissions" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
  }
}
