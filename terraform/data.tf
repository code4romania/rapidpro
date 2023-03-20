data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "current" {
  state = "available"
}

data "aws_availability_zone" "current" {
  name = "${var.region_name}${var.region_az}"
}
