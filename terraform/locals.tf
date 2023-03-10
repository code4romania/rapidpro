locals {
  namespace = "rapidpro-${var.env}"

  connection_url = {
    elasticache = "redis://${aws_elasticache_cluster.main.cache_nodes.0.address}:${aws_elasticache_cluster.main.port}/15"
    smtp        = "smtp://${aws_iam_access_key.mailroom.id}%40${aws_iam_access_key.mailroom.ses_smtp_password_v4}@email-smtp.${var.region}.amazonaws.com:587/?from=no-reply%40${var.domain_name}"
  }

  archiver = {
    namespace = "archiver-${var.env}"

    image = {
      repo = data.aws_ecr_repository.archiver.repository_url
      tag  = "edge"
    }
  }

  courier = {
    namespace = "courier-${var.env}"

    image = {
      repo = data.aws_ecr_repository.courier.repository_url
      tag  = "edge"
    }
  }

  indexer = {
    namespace = "indexer-${var.env}"

    image = {
      repo = data.aws_ecr_repository.indexer.repository_url
      tag  = "edge"
    }
  }

  mailroom = {
    namespace = "mailroom-${var.env}"

    image = {
      repo = data.aws_ecr_repository.mailroom.repository_url
      tag  = "edge"
    }
  }

  rapidpro = {
    namespace = "rapidpro-${var.env}"
    domain    = "rapidpro.${var.domain_name}"

    database_url = format(
      "postgres://%s:%s@%s:%d/%s",
      aws_db_instance.db_instance.username,
      aws_db_instance.db_instance.password,
      aws_db_instance.db_instance.address,
      aws_db_instance.db_instance.port,
      "rapidpro"
    )

    image = {
      repo = data.aws_ecr_repository.rapidpro.repository_url
      tag  = "edge"
    }
  }

  vpc = {
    cidr_block = "10.0.0.0/16"

    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]

    private_subnets = [
      "10.0.4.0/24",
      "10.0.5.0/24",
      "10.0.6.0/24"
    ]
  }
}
