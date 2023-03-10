resource "aws_ecs_task_definition" "archiver" {
  family                   = "${local.archiver.namespace}-task"
  execution_role_arn       = aws_iam_role.archiver_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      image     = "${local.archiver.image.repo}:${local.archiver.image.tag}"
      name      = "archiver"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.archiver.namespace
        }
      }

      portMappings = [
        {
          name          = "archiver"
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      environment = [
        {
          name  = "ARCHIVER_DELETE"
          value = "false"
        },
        {
          name  = "ARCHIVER_DB"
          value = local.rapidpro.database_url
        },
        {
          name  = "ARCHIVER_TEMP_DIR"
          value = "/tmp"
        },
        {
          name  = "ARCHIVER_LOG_LEVEL"
          value = var.debug ? "debug" : "warn"
        },
        {
          name  = "ARCHIVER_S3_REGION"
          value = var.region
        },
        {
          name  = "ARCHIVER_S3_BUCKET"
          value = aws_s3_bucket.archiver.bucket
        },
        {
          name  = "ARCHIVER_AWS_ACCESS_KEY_ID"
          value = aws_iam_access_key.archiver.id
        },
        {
          name  = "ARCHIVER_AWS_SECRET_ACCESS_KEY"
          value = aws_iam_access_key.archiver.secret
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "archiver" {
  name            = "archiver"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.archiver.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.archiver.arn
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private.*.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_service_discovery_service" "archiver" {
  name = "archiver"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "archiver_execution_role" {
  name               = "ECSTaskExecutionRole-${local.archiver.namespace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "archiver_execution_role_policy" {
  role       = aws_iam_role.archiver_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "archiver_s3_access_policy" {
  role       = aws_iam_role.archiver_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
