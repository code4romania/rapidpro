resource "aws_cloudwatch_log_group" "rapidpro" {
  name              = local.namespace
  retention_in_days = 30
}
