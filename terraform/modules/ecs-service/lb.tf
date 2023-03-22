resource "aws_lb_target_group" "this" {
  count = local.use_load_balancer ? 1 : 0

  name        = var.name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.lb_vpc_id
  target_type = "ip"

}

resource "aws_lb_listener_rule" "routing" {
  count = local.use_load_balancer ? 1 : 0

  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.0.arn
  }

  condition {
    host_header {
      values = var.lb_hosts
    }
  }
}
