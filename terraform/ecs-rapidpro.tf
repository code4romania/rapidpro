resource "aws_ecs_task_definition" "rapidpro" {
  family                   = local.rapidpro.namespace
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.rapidpro_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      image     = "${local.rapidpro.image.repo}:${local.rapidpro.image.tag}"
      name      = "rapidpro"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.rapidpro.namespace
        }
      }

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      environment = [
        {
          name  = "DOMAIN_NAME"
          value = local.rapidpro.domain
        },
        {
          name  = "SECRET_KEY"
          value = random_password.app_key.result
        },
        {
          name  = "POSTGRES_HOSTNAME"
          value = aws_db_proxy.main.endpoint
        },
        {
          name  = "POSTGRES_PORT"
          value = tostring(aws_db_instance.db_instance.port)
        },
        {
          name  = "POSTGRES_DB"
          value = aws_db_instance.db_instance.db_name
        },
        {
          name  = "POSTGRES_USER"
          value = aws_db_instance.db_instance.username
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = aws_db_instance.db_instance.password
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_cluster.main.cache_nodes.0.address
        },
        {
          name  = "REDIS_PORT"
          value = tostring(aws_elasticache_cluster.main.port)
        },
        {
          name  = "MAILROOM_URL"
          value = "http://mailroom.ecs.svc:8090"
        },
        {
          name  = "MAILROOM_AUTH_TOKEN"
          value = random_password.mailroom_auth_token.result
        },
        {
          name  = "COURIER_URL"
          value = "http://courier.ecs.svc:8080"
        },
        {
          name  = "ALLOW_SIGNUPS"
          value = tostring(false)
        },
        {
          name  = "DEBUG"
          value = tostring(var.debug)
        },
        {
          name  = "RUN_MIGRATION"
          value = "yes"
        },
        {
          name  = "SEND_EMAILS"
          value = "yes"
        },
        {
          name  = "EMAIL_HOST"
          value = local.mail.host
        },
        {
          name  = "EMAIL_HOST_USER"
          value = aws_iam_access_key.ureport.id
        },
        {
          name  = "EMAIL_HOST_PASSWORD"
          value = aws_iam_access_key.ureport.ses_smtp_password_v4
        },
        {
          name  = "DEFAULT_FROM_EMAIL"
          value = local.mail.from
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "rapidpro" {
  name            = "rapidpro"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.rapidpro.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  force_new_deployment   = var.force_new_deployment
  enable_execute_command = var.enable_execute_command

  service_registries {
    registry_arn = aws_service_discovery_service.rapidpro.arn
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rapidpro.arn
    container_name   = "rapidpro"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_service_discovery_service" "rapidpro" {
  name = "rapidpro"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "rapidpro_execution_role" {
  name               = "ECSTaskExecutionRole-${local.rapidpro.namespace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "rapidpro_execution_role_policy" {
  role       = aws_iam_role.rapidpro_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
