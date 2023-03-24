module "ecs_rapidpro" {
  source = "./modules/ecs-service"

  name         = "rapidpro"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  lb_dns_name             = aws_lb.main.dns_name
  lb_zone_id              = aws_lb.main.zone_id
  lb_vpc_id               = aws_vpc.main.id
  lb_listener_arn         = aws_lb_listener.https.arn
  lb_hosts                = [local.domains.rapidpro]
  lb_domain_zone_id       = aws_route53_zone.main.zone_id
  lb_health_check_enabled = true

  image_repo = data.aws_ecr_repository.rapidpro.repository_url
  image_tag  = "edge"

  container_memory_soft_limit = 1024
  container_memory_hard_limit = 2048

  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  container_port          = 80
  network_mode            = "awsvpc"
  network_security_groups = [aws_security_group.ecs.id]
  network_subnets         = [aws_subnet.private.0.id]

  enable_execute_command = var.enable_execute_command

  predefined_metric_type = "ECSServiceAverageCPUUtilization"
  target_value           = 80

  ordered_placement_strategy = [
    {
      type  = "binpack"
      field = "memory"
    }
  ]

  environment = [
    {
      name  = "DOMAIN_NAME"
      value = local.domains.rapidpro
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
      name  = "COURIER_HOST"
      value = "courier.ecs.svc"
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
      value = var.run_migration ? "yes" : "no"
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
  secret_string = random_password.rapidpro_secret_key.result
}

resource "random_password" "rapidpro_secret_key" {
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
