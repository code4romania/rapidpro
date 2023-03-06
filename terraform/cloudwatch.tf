resource "aws_cloudwatch_log_group" "rapidpro" {
  name              = "rapidpro"
  retention_in_days = 30
}
