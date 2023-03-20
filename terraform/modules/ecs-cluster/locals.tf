resource "aws_ecs_cluster" "main" {
  name = local.namespace
  tags = var.tags
}
