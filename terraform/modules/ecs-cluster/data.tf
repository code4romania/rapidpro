### Latest Amazon Linux ECS Optimized AMI
data "aws_ami" "this" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

### ECS instances user_data
data "template_file" "user_data" {
  template = file("${path.module}/assets/user_data.sh")

  vars = {
    ecs_cluster_name            = var.name
    disk_path                   = var.disk_path
    maintenance_log_group_name  = aws_cloudwatch_log_group.userdata.name
    additional_user_data_script = var.additional_user_data_script
  }
}
