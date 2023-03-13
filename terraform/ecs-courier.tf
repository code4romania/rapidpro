resource "aws_ecs_task_definition" "courier" {
  family                   = local.courier.namespace
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.courier_execution_role.arn
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
          value = local.rapidpro.domain
        },
        {
          name  = "COURIER_ADDRESS"
          value = "0.0.0.0"
        },
        {
          name  = "COURIER_DB"
          value = local.rapidpro.database_url
        },
        {
          name  = "COURIER_REDIS"
          value = local.connection_url.elasticache
        },
        {
          name  = "COURIER_LOG_LEVEL"
          value = var.debug ? "debug" : "warn"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "courier" {
  name            = "courier"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.courier.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_execute_command = var.enable_execute_command

  service_registries {
    registry_arn = aws_service_discovery_service.courier.arn
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

resource "aws_service_discovery_service" "courier" {
  name = "courier"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "courier_execution_role" {
  name               = "ECSTaskExecutionRole-${local.courier.namespace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "courier_execution_role_policy" {
  role       = aws_iam_role.courier_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
