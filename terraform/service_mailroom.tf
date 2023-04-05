module "ecs_mailroom" {
  source = "./modules/ecs-service"

  depends_on = [
    module.ecs_cluster
  ]

  name         = "mailroom"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  image_repo = data.aws_ecr_repository.mailroom.repository_url
  image_tag  = "edge"

  container_memory_soft_limit = 128
  container_memory_hard_limit = 256

  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  container_port          = 8090
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
      name  = "MAILROOM_DOMAIN"
      value = local.domains.rapidpro
    },
    {
      name  = "MAILROOM_ADDRESS"
      value = "0.0.0.0"
    },
    {
      name  = "MAILROOM_LOG_LEVEL"
      value = "debug"
    },
    {
      name  = "MAILROOM_REDIS"
      value = "${local.elasticache_url}/15"
    },
    {
      name  = "MAILROOM_ELASTIC"
      value = local.elasticsearch_url
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
      name  = "MAILROOM_SESSION_STORAGE"
      value = "db"
    },
    {
      name  = "MAILROOM_S3_SESSION_BUCKET"
      value = module.s3_mailroom.bucket
    },
    {
      name  = "MAILROOM_S3_SESSION_PREFIX"
      value = "/sessions/"
    },
    {
      name  = "MAILROOM_S3_MEDIA_BUCKET"
      value = module.s3_mailroom.bucket
    },
    {
      name  = "MAILROOM_S3_MEDIA_PREFIX"
      value = "/media/"
    },
  ]

  secrets = [
    {
      name      = "MAILROOM_DB"
      valueFrom = aws_secretsmanager_secret.rapidpro_db_url.arn
    },
    {
      name      = "MAILROOM_AUTH_TOKEN"
      valueFrom = aws_secretsmanager_secret.mailroom_auth_token.arn
    },
    {
      name      = "MAILROOM_FCM_KEY"
      valueFrom = aws_secretsmanager_secret.mailroom_fcm_key.arn
    },
    {
      name      = "MAILROOM_AWS_ACCESS_KEY_ID"
      valueFrom = "${module.s3_mailroom.secret_arn}:access_key_id::"
    },
    {
      name      = "MAILROOM_AWS_SECRET_ACCESS_KEY"
      valueFrom = "${module.s3_mailroom.secret_arn}:secret_access_key::"
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_db_url.arn,
    aws_secretsmanager_secret.mailroom_auth_token.arn,
    aws_secretsmanager_secret.mailroom_fcm_key.arn,
    module.s3_mailroom.secret_arn,
  ]
}

resource "random_password" "mailroom_auth_token" {
  length  = 32
  special = false

  lifecycle {
    ignore_changes = [
      length,
      special
    ]
  }
}

resource "aws_secretsmanager_secret" "mailroom_auth_token" {
  name = "${local.namespace}-mailroom_auth_token"
}

resource "aws_secretsmanager_secret_version" "mailroom_auth_token" {
  secret_id     = aws_secretsmanager_secret.mailroom_auth_token.id
  secret_string = random_password.mailroom_auth_token.result
}

resource "aws_secretsmanager_secret" "mailroom_fcm_key" {
  name = "${local.namespace}-mailroom_fcm_key"
}

module "s3_mailroom" {
  source = "./modules/s3"

  name = "${local.namespace}-mailroom"
}
