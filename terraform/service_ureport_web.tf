module "ecs_ureport_web" {
  source = "./modules/ecs-service"

  name         = "ureport-web"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 3

  lb_dns_name             = aws_lb.main.dns_name
  lb_zone_id              = aws_lb.main.zone_id
  lb_vpc_id               = aws_vpc.main.id
  lb_listener_arn         = aws_lb_listener.https.arn
  lb_hosts                = values(local.domains.ureport)
  lb_domain_zone_id       = aws_route53_zone.main.zone_id
  lb_health_check_enabled = true

  image_repo = data.aws_ecr_repository.ureport.repository_url
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
      name  = "HOSTNAME"
      value = local.domains.ureport.main
    },
    {
      name  = "EMPTY_SUBDOMAIN_HOST"
      value = "https://${local.domains.ureport.main}"
    },
    {
      name  = "POSTGRES_HOSTNAME"
      value = aws_db_proxy.main.endpoint
    },
    {
      name  = "POSTGRES_DB"
      value = "ureport"
    },
    {
      name  = "CELERY_BROKER_URL"
      value = local.elasticache_url
    },
    {
      name  = "RAPIDPRO_API_URL"
      value = "http://rapidpro.ecs.svc"
    },
    {
      name  = "DEBUG"
      value = tostring(var.debug)
    },
    {
      name  = "AWS_S3_CUSTOM_DOMAIN"
      value = module.cloudfront_ureport.domain_name
    },
    {
      name  = "AWS_S3_REGION_NAME"
      value = var.region
    },
    {
      name  = "AWS_STORAGE_BUCKET_NAME"
      value = module.s3_ureport.bucket
    },
    {
      name  = "RUN_MIGRATION"
      value = var.run_migration ? "yes" : "no"
    },
    {
      name  = "EMAIL_HOST"
      value = local.mail.host
    },
    {
      name  = "EMAIL_HOST_USER"
      value = aws_iam_access_key.ureport.id
    },
    {
      name  = "EMAIL_HOST_PASSWORD"
      value = aws_iam_access_key.ureport.ses_smtp_password_v4
    },
    {
      name  = "DEFAULT_FROM_EMAIL"
      value = local.mail.from
    }
  ]

  secrets = [
    {
      name      = "SECRET_KEY"
      valueFrom = aws_secretsmanager_secret.ureport_secret_key.arn
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
      name      = "AWS_ACCESS_KEY_ID"
      valueFrom = "${module.s3_ureport.secret_arn}:access_key_id::"
    },
    {
      name      = "AWS_SECRET_ACCESS_KEY"
      valueFrom = "${module.s3_ureport.secret_arn}:secret_access_key::"
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.ureport_secret_key.arn,
    aws_secretsmanager_secret.rds.arn,
    module.s3_ureport.secret_arn,
  ]
}

module "s3_ureport" {
  source = "./modules/s3"

  name = "ureport-${local.namespace}"
}

module "cloudfront_ureport" {
  source = "./modules/cloudfront"

  name   = "ureport-${local.namespace}"
  bucket = module.s3_ureport.bucket
}

resource "aws_secretsmanager_secret" "ureport_secret_key" {
  name = "${local.namespace}-ureport_secret_key"
}

resource "aws_secretsmanager_secret_version" "ureport_secret_key" {
  secret_id     = aws_secretsmanager_secret.ureport_secret_key.id
  secret_string = random_password.ureport_secret_key.result
}

resource "random_password" "ureport_secret_key" {
  length  = 50
  special = true

  lifecycle {
    ignore_changes = [
      length,
      special
    ]
  }
}

resource "aws_iam_access_key" "ureport" {
  user = aws_iam_user.ureport.name
}

resource "aws_iam_user" "ureport" {
  name = "${local.namespace}-ureport-user"
}
