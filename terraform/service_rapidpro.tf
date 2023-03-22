module "ecs_rapidpro" {
  source = "./modules/ecs-service"

  enable_execute_command = var.enable_execute_command

  name                           = "rapidpro"
  cluster_name                   = module.ecs_cluster.cluster_name
  image_repo                     = data.aws_ecr_repository.rapidpro.repository_url
  image_tag                      = "edge"
  container_port                 = 80
  min_capacity                   = 1
  max_capacity                   = 1
  memory                         = 1024
  container_memory_soft_limit    = 1024
  container_memory_hard_limit    = 2048
  predefined_metric_type         = "ECSServiceAverageCPUUtilization"
  target_value                   = 80
  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  network_mode            = "awsvpc"
  network_security_groups = [aws_security_group.ecs.id]
  network_subnets         = [aws_subnet.private.0.id]

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
      name  = "DOMAIN_NAME"
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
    },
    {
      name  = "POSTGRES_HOSTNAME"
      value = aws_db_proxy.main.endpoint
    },
    {
      name  = "POSTGRES_DB"
      value = aws_db_instance.main.db_name
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
      name  = "MAILROOM_HOST"
      value = "mailroom.ecs.svc"
    },
    {
      name  = "MAILROOM_SRV"
      value = "service=mailroom resolve"
    },
    {
      name  = "COURIER_HOST"
      value = "courier.ecs.svc"
    },
    {
      name  = "COURIER_SRV"
      value = "service=courier resolve"
    },
    {
      name  = "ALLOW_SIGNUPS"
      value = tostring(false)
    },
    {
      name  = "DEBUG"
      value = tostring(false)
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
      value = aws_iam_access_key.rapidpro.id
    },
    {
      name  = "EMAIL_HOST_PASSWORD"
      value = aws_iam_access_key.rapidpro.ses_smtp_password_v4
    },
    {
      name  = "DEFAULT_FROM_EMAIL"
      value = local.mail.from
    }
  ]

  secrets = [
    {
      name      = "SECRET_KEY"
      valueFrom = aws_secretsmanager_secret.rapidpro_secret_key.arn
    },
    {
      name      = "POSTGRES_PORT"
      valueFrom = "${aws_secretsmanager_secret.rds.arn}:port::"
    },
    {
      name      = "POSTGRES_USER"
      valueFrom = "${aws_secretsmanager_secret.rds.arn}:username::"
    },
    {
      name      = "POSTGRES_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret.rds.arn}:password::"
    },
    {
      name      = "MAILROOM_AUTH_TOKEN"
      valueFrom = aws_secretsmanager_secret.mailroom_auth_token.arn
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_secret_key.arn,
    aws_secretsmanager_secret.mailroom_auth_token.arn,
    aws_secretsmanager_secret.rds.arn,
  ]
}


resource "aws_secretsmanager_secret" "rapidpro_secret_key" {
  name = "${local.namespace}-rapidpro_secret_key"
}

resource "aws_secretsmanager_secret_version" "rapidpro_secret_key" {
  secret_id     = aws_secretsmanager_secret.rapidpro_secret_key.id
  secret_string = random_password.app_key.result
}

resource "random_password" "app_key" {
  length  = 50
  special = true

  lifecycle {
    ignore_changes = [
      length,
      special
    ]
  }
}

resource "aws_iam_access_key" "rapidpro" {
  user = aws_iam_user.rapidpro.name
}

resource "aws_iam_user" "rapidpro" {
  name = "${local.namespace}-rapidpro-user"
}
