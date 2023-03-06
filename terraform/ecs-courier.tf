resource "aws_ecs_task_definition" "courier" {
  family                   = "${local.courier.namespace}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      image     = "${local.courier.image.repo}:${local.courier.image.tag}"
      name      = "courier"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.courier.namespace
        }
      }

      portMappings = [
        {
          name          = "courier"
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      environment = [
        {
          name  = "COURIER_DOMAIN"
          value = var.rapidpro_public_domain
        },
        {
          name  = "COURIER_ADDRESS"
          value = "0.0.0.0"
        },
        {
          name  = "COURIER_DB"
          value = local.connection_url.database
        },
        {
          name  = "COURIER_REDIS"
          value = local.connection_url.elasticache
        },
        {
          name  = "COURIER_LOG_LEVEL"
          value = "debug"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = aws_db_instance.db_instance.password
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "courier" {
  name            = "${local.courier.namespace}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.courier.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn

    service {
      discovery_name = "courier"
      port_name      = "courier"
      client_alias {
        dns_name = "courier"
        port     = 8080
      }
    }
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
