module "ecs_archiver" {
  source = "./modules/ecs-service"

  name         = "archiver"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  image_repo = data.aws_ecr_repository.archiver.repository_url
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
      name  = "ARCHIVER_DELETE"
      value = "false"
    },
    {
      name  = "ARCHIVER_TEMP_DIR"
      value = "/tmp"
    },
    {
      name  = "ARCHIVER_S3_REGION"
      value = var.region
    },
    {
      name  = "ARCHIVER_S3_ENDPOINT"
      value = "https://s3.${var.region}.amazonaws.com"
    },
    {
      name  = "ARCHIVER_S3_BUCKET"
      value = module.s3_archiver.bucket
    },
    {
      name  = "ARCHIVER_LOG_LEVEL"
      value = "info"
    }
  ]

  secrets = [
    {
      name      = "ARCHIVER_DB"
      valueFrom = aws_secretsmanager_secret.rapidpro_db_url.arn
    },
    {
      name      = "ARCHIVER_AWS_ACCESS_KEY_ID"
      valueFrom = "${module.s3_archiver.secret_arn}:access_key_id::"
    },
    {
      name      = "ARCHIVER_AWS_SECRET_ACCESS_KEY"
      valueFrom = "${module.s3_archiver.secret_arn}:secret_access_key::"
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_db_url.arn,
    module.s3_archiver.secret_arn,
  ]
}

module "s3_archiver" {
  source = "./modules/s3"

  name = "archiver-${local.namespace}"
}
