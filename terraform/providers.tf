terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }
  }

  # cloud {
  #   organization = "code4romania"

  #   workspaces {
  #     name = "onghub"
  #   }
  # }
}

provider "aws" {
  region = var.region

  profile = "ureport-romania"

  default_tags {
    tags = {
      app = "rapidpro"
      env = var.env
    }
  }
}
