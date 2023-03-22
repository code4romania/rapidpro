module "ecs_mailroom" {
  source = "./modules/ecs-service"

  name         = "mailroom"
  cluster_name = module.ecs_cluster.cluster_name
  min_capacity = 1
  max_capacity = 1

  image_repo = data.aws_ecr_repository.mailroom.repository_url
  image_tag  = "edge"

  container_memory_soft_limit = 256
  container_memory_hard_limit = 512

  log_group_name                 = module.ecs_cluster.log_group_name
  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  container_port          = 8090
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
      name  = "MAILROOM_DOMAIN"
      value = local.domains.rapidpro
    },
    {
      name  = "MAILROOM_ADDRESS"
      value = "0.0.0.0"
    },
    {
      name  = "MAILROOM_LOG_LEVEL"
      value = "error"
    },
    {
      name  = "MAILROOM_REDIS"
      value = local.elasticache_url
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
      name  = "MAILROOM_AWS_ACCESS_KEY_ID"
      value = aws_iam_access_key.mailroom.id
    },
    {
      name  = "MAILROOM_AWS_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.mailroom.secret
    },
    {
      name  = "MAILROOM_SESSION_STORAGE"
      value = "s3"
    },
    {
      name  = "MAILROOM_S3_SESSION_BUCKET"
      value = aws_s3_bucket.mailroom.bucket
    },
    {
      name  = "MAILROOM_S3_SESSION_PREFIX"
      value = "/sessions/"
    },
    {
      name  = "MAILROOM_S3_MEDIA_BUCKET"
      value = aws_s3_bucket.mailroom.bucket
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
    }
  ]

  allowed_secrets = [
    aws_secretsmanager_secret.rapidpro_db_url.arn,
    aws_secretsmanager_secret.mailroom_auth_token.arn,
    aws_secretsmanager_secret.mailroom_fcm_key.arn,
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

resource "random_string" "mailroom_s3_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}


resource "aws_s3_bucket" "mailroom" {
  bucket = "${local.namespace}-mailroom-${random_string.mailroom_s3_bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "mailroom" {
  bucket = aws_s3_bucket.mailroom.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mailroom_public_access_block" {
  bucket = aws_s3_bucket.mailroom.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mailroom" {
  bucket = aws_s3_bucket.mailroom.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_access_key" "mailroom" {
  user = aws_iam_user.mailroom.name
}

resource "aws_iam_user" "mailroom" {
  name = "${local.namespace}-mailroom-user"
}

data "aws_iam_policy_document" "mailroom_bucket_acccess" {
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
      aws_s3_bucket.mailroom.arn,
      "${aws_s3_bucket.mailroom.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "mailroom_access_policy" {
  name   = "${local.namespace}-mailroom-s3-access-policy"
  user   = aws_iam_user.mailroom.name
  policy = data.aws_iam_policy_document.mailroom_bucket_acccess.json
}

