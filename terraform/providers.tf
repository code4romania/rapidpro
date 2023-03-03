terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
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
