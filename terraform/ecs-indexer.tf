resource "aws_ecs_task_definition" "indexer" {
  family                   = "${local.indexer.namespace}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      image     = "${local.indexer.image.repo}:${local.indexer.image.tag}"
      name      = "indexer"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rapidpro.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.indexer.namespace
        }
      }

      portMappings = [
        {
          name          = "indexer"
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      environment = [
        {
          name  = "INDEXER_DB"
          value = local.connection_url.database
        },
        {
          name  = "INDEXER_ELASTIC_URL"
          value = "https://${aws_elasticsearch_domain.rapidpro.endpoint}"
        },
        {
          name  = "INDEXER_LOG_LEVEL"
          value = var.debug ? "debug" : "warn"
        },
        {
          name  = "INDEXER_POLL"
          value = tostring(15)
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "indexer" {
  name            = "${local.indexer.namespace}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.indexer.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_registries {
    registry_arn = aws_service_discovery_service.indexer.arn
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

resource "aws_service_discovery_service" "indexer" {
  name = "indexer"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.ecs.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}
