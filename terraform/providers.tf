terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60"
    }
  }

  cloud {
    organization = "code4romania"

    workspaces {
      tags = [
        "rapidpro"
      ]
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
