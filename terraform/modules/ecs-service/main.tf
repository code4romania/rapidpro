resource "aws_ecs_service" "this" {
  name            = var.name
  task_definition = aws_ecs_task_definition.this.arn
  cluster         = data.aws_ecs_cluster.this.arn

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  force_new_deployment               = var.force_new_deployment

  enable_execute_command = var.enable_execute_command

  dynamic "load_balancer" {
    for_each = var.target_group_arn == null ? [] : [1]

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.name
      container_port   = var.container_port
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = lookup(ordered_placement_strategy.value, "type")
      field = lookup(ordered_placement_strategy.value, "field")
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags
}