module "ecs_rapidpro" {
  source = "./modules/ecs-service"

  depends_on = [
    module.ecs_cluster
  ]

  name         = "${var.env}-rapidpro"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 3

  use_load_balancer       = var.use_load_balancer
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
      value = "${var.env}-mailroom.ecs.svc"
    },
    {
      name  = "COURIER_HOST"
      value = "${var.env}-courier.ecs.svc"
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
      value = tostring(true)
    },
    {
      name  = "AWS_S3_REGION_NAME"
      value = var.region
    },
    {
      name  = "AWS_STORAGE_BUCKET_NAME"
      value = module.s3_rapidpro_storage.bucket
    },
    {
      name  = "ARCHIVE_BUCKET"
      value = module.s3_archiver.bucket
    },
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
    {
      name      = "EMAIL_HOST"
      valueFrom = "${aws_secretsmanager_secret.smtp.arn}:host::"
    },
    {
      name      = "EMAIL_PORT"
      valueFrom = "${aws_secretsmanager_secret.smtp.arn}:port::"
    },
    {
      name      = "EMAIL_HOST_USER"
      valueFrom = "${aws_secretsmanager_secret.smtp.arn}:user::"
    },
    {
      name      = "EMAIL_HOST_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret.smtp.arn}:password::"
    },
    {
      name      = "DEFAULT_FROM_EMAIL"
      valueFrom = "${aws_secretsmanager_secret.smtp.arn}:from::"
    },
    {
      name      = "AWS_ACCESS_KEY_ID"
      valueFrom = "${module.iam_user_rapidpro.secret_arn}:access_key_id::"
    },
    {
      name      = "AWS_SECRET_ACCESS_KEY"
      valueFrom = "${module.iam_user_rapidpro.secret_arn}:secret_access_key::"
    },
    {
      name      = "FACEBOOK_APPLICATION_ID"
      valueFrom = "${aws_secretsmanager_secret.facebook.arn}:application_id::"
    },
    {
      name      = "FACEBOOK_APPLICATION_SECRET"
      valueFrom = "${aws_secretsmanager_secret.facebook.arn}:application_secret::"
    },
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_secret_key.arn,
    aws_secretsmanager_secret.mailroom_auth_token.arn,
    aws_secretsmanager_secret.facebook.arn,
    aws_secretsmanager_secret.smtp.arn,
    aws_secretsmanager_secret.rds.arn,
    module.iam_user_rapidpro.secret_arn,
  ]
}

resource "aws_secretsmanager_secret" "facebook" {
  name = "${local.namespace}-facebook"
}

resource "aws_secretsmanager_secret_version" "facebook" {
  secret_id = aws_secretsmanager_secret.facebook.id
  secret_string = jsonencode({
    application_id     = ""
    application_secret = ""
  })
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

module "s3_rapidpro_storage" {
  source = "./modules/s3"

  name     = "${local.namespace}-rapidpro-storage"
  iam_user = module.iam_user_rapidpro.name
}

module "iam_user_rapidpro" {
  source = "./modules/iam_user"

  name   = "${local.namespace}-rapidpro"
  policy = data.aws_iam_policy_document.bucket_acccess.json
}

data "aws_iam_policy_document" "bucket_acccess" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]

    resources = [
      module.s3_archiver.bucket_arn,
      "${module.s3_archiver.bucket_arn}/*",
      module.s3_rapidpro_storage.bucket_arn,
      "${module.s3_rapidpro_storage.bucket_arn}/*",
      module.s3_mailroom.bucket_arn,
      "${module.s3_mailroom.bucket_arn}/*",
      module.s3_courier.bucket_arn,
      "${module.s3_courier.bucket_arn}/*",
    ]
  }
}
