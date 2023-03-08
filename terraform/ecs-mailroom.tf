resource "aws_ecs_task_definition" "mailroom" {
  family                   = "${local.mailroom.namespace}-task"
  execution_role_arn       = aws_iam_role.mailroom_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      image     = "${local.mailroom.image.repo}:${local.mailroom.image.tag}"
      name      = "mailroom"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.mailroom.namespace
        }
      }

      portMappings = [
        {
          name          = "mailroom"
          containerPort = 8090
          hostPort      = 8090
        }
      ]

      environment = [
        {
          name  = "MAILROOM_DOMAIN"
          value = var.rapidpro_public_domain
        },
        {
          name  = "MAILROOM_ADDRESS"
          value = "0.0.0.0"
        },
        {
          name  = "MAILROOM_AUTH_TOKEN"
          value = random_password.mailroom_auth_token.result
        },
        {
          name  = "MAILROOM_DB"
          value = local.connection_url.database
        },
        {
          name  = "MAILROOM_REDIS"
          value = local.connection_url.elasticache
        },
        {
          name  = "MAILROOM_ELASTIC"
          value = "https://${aws_elasticsearch_domain.rapidpro.endpoint}"
        },
        {
          name  = "MAILROOM_SMTP_SERVER"
          value = local.connection_url.smtp
        },
        {
          name  = "MAILROOM_FCM_KEY"
          value = var.mailroom_fcm_key
        },
        {
          name  = "MAILROOM_LOG_LEVEL"
          value = var.debug ? "debug" : "warn"
        },
        {
          name  = "MAILROOM_S3_REGION"
          value = var.region
        },
        {
          name  = "MAILROOM_S3_ENDPOINT"
          value = "https://s3.${var.region}.amazonaws.com"
        },
        {
          name  = "MAILROOM_AWS_ACCESS_KEY_ID"
          value = aws_iam_access_key.mailroom.id
        },
        {
          name  = "MAILROOM_AWS_SECRET_ACCESS_KEY"
          value = aws_iam_access_key.mailroom.secret
        },
        {
          name  = "MAILROOM_SESSION_STORAGE"
          value = "s3"
        },
        {
          name  = "MAILROOM_S3_SESSION_BUCKET"
          value = aws_s3_bucket.mailroom.bucket
        },
        {
          name  = "MAILROOM_S3_SESSION_PREFIX"
          value = "/sessions/"
        },
        {
          name  = "MAILROOM_S3_MEDIA_BUCKET"
          value = aws_s3_bucket.mailroom.bucket
        },
        {
          name  = "MAILROOM_S3_MEDIA_PREFIX"
          value = "/media/"
        },
      ]
    }
  ])
}

resource "aws_ecs_service" "mailroom" {
  name            = "${local.mailroom.namespace}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mailroom.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.mailroom.arn
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

resource "aws_service_discovery_service" "mailroom" {
  name = "mailroom"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "mailroom_execution_role" {
  name               = "ECSTaskExecutionRole-${local.mailroom.namespace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "mailroom_execution_role_policy" {
  role       = aws_iam_role.mailroom_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "mailroom_s3_access_policy" {
  role       = aws_iam_role.mailroom_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
