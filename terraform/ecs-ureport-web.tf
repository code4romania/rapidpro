resource "aws_ecs_task_definition" "ureport-web" {
  family                   = local.ureport.namespace.web
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.ureport_web_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      image     = "${local.ureport.image.repo}:${local.ureport.image.tag}"
      name      = "ureport-web"
      essential = true

      ulimits = [
        {
          name      = "nofile"
          softLimit = 16384
          hardLimit = 1048576
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.ureport.namespace.web
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
          name  = "HOSTNAME"
          value = local.ureport.domains.main
        },
        {
          name  = "EMPTY_SUBDOMAIN_HOST"
          value = "https://${local.ureport.domains.main}"
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
          value = "ureport"
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
          name  = "CELERY_BROKER_URL"
          value = local.connection_url.elasticache
        },
        {
          name  = "RAPIDPRO_API_URL"
          value = "http://rapidpro.ecs.svc"
        },
        {
          name  = "DEBUG"
          value = tostring(var.debug)
        },
        {
          name  = "AWS_S3_CUSTOM_DOMAIN"
          value = aws_cloudfront_distribution.ureport-web.domain_name
        },
        {
          name  = "AWS_S3_REGION_NAME"
          value = var.region
        },
        {
          name  = "AWS_STORAGE_BUCKET_NAME"
          value = aws_s3_bucket.ureport.bucket
        },
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = aws_iam_access_key.ureport.id
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = aws_iam_access_key.ureport.secret
        },
        {
          name  = "RUN_MIGRATION"
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

resource "aws_ecs_service" "ureport-web" {
  name            = "ureport-web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ureport-web.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_execute_command = var.enable_execute_command

  service_registries {
    registry_arn = aws_service_discovery_service.ureport-web.arn
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ureport.arn
    container_name   = "ureport-web"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_service_discovery_service" "ureport-web" {
  name = "ureport-web"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "ureport_web_execution_role" {
  name               = "ECSTaskExecutionRole-${local.ureport.namespace.web}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "ureport_web_execution_role_policy" {
  role       = aws_iam_role.ureport_web_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Autoscaling
resource "aws_appautoscaling_target" "ureport-web" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.ureport-web.name}"
  role_arn           = aws_iam_role.autoscaling.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.ureport-web]
}

resource "aws_appautoscaling_policy" "ureport-web" {
  name               = "${aws_ecs_service.ureport-web.name}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ureport-web.resource_id
  scalable_dimension = aws_appautoscaling_target.ureport-web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ureport-web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 30
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.ureport-web]
}
