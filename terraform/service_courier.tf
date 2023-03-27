module "ecs_courier" {
  source = "./modules/ecs-service"

  name         = "courier"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  image_repo = data.aws_ecr_repository.courier.repository_url
  image_tag  = "edge"

  container_memory_soft_limit = 128
  container_memory_hard_limit = 256

  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  container_port          = 8080
  network_mode            = "awsvpc"
  network_security_groups = [aws_security_group.ecs.id]
  network_subnets         = [aws_subnet.private.0.id]

  ordered_placement_strategy = [
    {
      type  = "binpack"
      field = "memory"
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
      value = "info"
    },
    {
      name  = "COURIER_SPOOL_DIR"
      value = "/tmp/courier"
    },
    {
      name  = "COURIER_S3_REGION"
      value = var.region
    },
    {
      name  = "COURIER_S3_ENDPOINT"
      value = "https://s3.${var.region}.amazonaws.com"
    },
    {
      name  = "COURIER_S3_MEDIA_BUCKET"
      value = module.s3_courier.bucket
    },
  ]

  secrets = [
    {
      name      = "COURIER_DB"
      valueFrom = aws_secretsmanager_secret.rapidpro_db_url.arn
    },
    {
      name      = "COURIER_AWS_ACCESS_KEY_ID"
      valueFrom = "${module.s3_courier.secret_arn}:access_key_id::"
    },
    {
      name      = "COURIER_AWS_SECRET_ACCESS_KEY"
      valueFrom = "${module.s3_courier.secret_arn}:secret_access_key::"
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_db_url.arn,
    module.s3_courier.secret_arn,
  ]
}

module "s3_courier" {
  source = "./modules/s3"

  name = "courier-${local.namespace}"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  enable_versioning       = true
}
