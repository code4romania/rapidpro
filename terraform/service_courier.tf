module "ecs_courier" {
  source = "./modules/ecs-service"

  enable_execute_command = var.enable_execute_command

  name                           = "courier"
  cluster_name                   = module.ecs_cluster.cluster_name
  image_repo                     = data.aws_ecr_repository.courier.repository_url
  image_tag                      = "edge"
  container_port                 = 8080
  min_capacity                   = 1
  max_capacity                   = 1
  memory                         = 512
  container_memory_soft_limit    = 512
  container_memory_hard_limit    = 1024
  predefined_metric_type         = "ECSServiceAverageCPUUtilization"
  target_value                   = 80
  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  ordered_placement_strategy = [
    {
      type  = "binpack"
      field = "memory"
    },
    {
      type  = "binpack"
      field = "cpu"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]

  environment = [
    {
      name  = "COURIER_DOMAIN"
      value = local.domains.rapidpro
    },
    {
      name  = "COURIER_ADDRESS"
      value = "0.0.0.0"
    },
    {
      name  = "COURIER_REDIS"
      value = local.elasticache_url
    },
    {
      name  = "COURIER_LOG_LEVEL"
      value = "error"
    }
  ]

  secrets = [
    {
      name      = "COURIER_DB"
      valueFrom = aws_secretsmanager_secret.rapidpro-db-url.arn
    }
  ]

  allowed_secrets = [aws_secretsmanager_secret.rapidpro-db-url.arn]
}
