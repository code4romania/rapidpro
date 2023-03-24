module "ecs_indexer" {
  source = "./modules/ecs-service"

  name         = "indexer"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  image_repo = data.aws_ecr_repository.indexer.repository_url
  image_tag  = "edge"

  container_memory_soft_limit = 128
  container_memory_hard_limit = 256

  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  container_port          = 8080
  network_mode            = "awsvpc"
  network_security_groups = [aws_security_group.ecs.id]
  network_subnets         = [aws_subnet.private.0.id]

  enable_execute_command = var.enable_execute_command

  ordered_placement_strategy = [
    {
      type  = "binpack"
      field = "memory"
    }
  ]

  environment = [
    {
      name  = "INDEXER_ELASTIC_URL"
      value = local.elasticsearch_url
    },
    {
      name  = "INDEXER_POLL"
      value = tostring(300)
    },
    {
      name  = "INDEXER_LOG_LEVEL"
      value = "error"
    }
  ]

  secrets = [
    {
      name      = "INDEXER_DB"
      valueFrom = aws_secretsmanager_secret.rapidpro_db_url.arn
    }
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_db_url.arn,
  ]
}
