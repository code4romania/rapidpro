terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.18.0"
    }
  }

  cloud {
    organization = "code4romania"

    workspaces {
      name = "rapidpro"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      app = "rapidpro"
      env = var.env
    }
  }
}

provider "postgresql" {
  scheme          = "awspostgres"
  host            = aws_db_instance.db_instance.address
  port            = aws_db_instance.db_instance.port
  username        = aws_db_instance.db_instance.username
  password        = aws_db_instance.db_instance.password
  superuser       = true
  sslmode         = "require"
  connect_timeout = 20
}
