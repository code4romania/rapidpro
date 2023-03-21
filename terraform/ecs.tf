module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name            = local.namespace
  vpc_id          = aws_vpc.main.id
  ecs_subnets     = [aws_subnet.private.0.id]
  security_groups = [aws_security_group.ecs.id]
  instance_types = {
    "m5.large" = ""
    "t3.large" = ""
  }

  min_size                  = 1
  max_size                  = 3
  minimum_scaling_step_size = 1
  maximum_scaling_step_size = 1

  target_capacity                          = 1
  capacity_rebalance                       = true
  on_demand_base_capacity                  = 0
  on_demand_percentage_above_base_capacity = 0
  ecs_cloudwatch_log_retention             = 3
  userdata_cloudwatch_log_retention        = 3
  protect_from_scale_in                    = true

  spot_allocation_strategy = "price-capacity-optimized"
  spot_instance_pools      = 0

  depends_on = [aws_iam_service_linked_role.ecs]
}

resource "aws_iam_service_linked_role" "ecs" {
  count            = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_security_group" "ecs" {
  name        = "${local.namespace}-ecs"
  description = "Inbound - Security Group attached to the ECS Service (${var.env})"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Load balancer traffic"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    description = "Internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
