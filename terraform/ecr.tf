data "aws_ecr_repository" "archiver" {
  name = "archiver"
}

data "aws_ecr_repository" "courier" {
  name = "courier"
}

data "aws_ecr_repository" "indexer" {
  name = "indexer"
}

data "aws_ecr_repository" "mailroom" {
  name = "mailroom"
}

data "aws_ecr_repository" "rapidpro" {
  name = "rapidpro"
}

data "aws_ecr_repository" "ureport" {
  name = "ureport"
}
data "aws_ecr_repository" "ureport-celery" {
  name = "ureport-celery"
}
