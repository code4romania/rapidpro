resource "aws_lb" "main" {
  name               = "${local.namespace}-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_alb_listener" "https" {
  certificate_arn   = aws_acm_certificate.rapidpro.arn
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_alb_target_group.rapidpro.id
    type             = "forward"
  }
}


resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_alb_target_group" "rapidpro" {
  name        = "rapidpro"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  #   health_check {
  #     healthy_threshold   = "3"
  #     interval            = "30"
  #     protocol            = "HTTP"
  #     matcher             = "200"
  #     timeout             = "3"
  #     path                = "/common/ping"
  #     unhealthy_threshold = "2"
  #   }
}



resource "aws_security_group" "lb" {
  name        = "${local.namespace}-lb-sg"
  description = "Inbound - Security Group attached to the Application Load Balancer (${var.env})"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
