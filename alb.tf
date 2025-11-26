resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-alb-${var.environment}"
      Environment = var.environment
    }
  )
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-tg-${var.environment}"
      Environment = var.environment
    }
  )
}

# Register EC2 instances with Target Group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-listener-${var.environment}"
      Environment = var.environment
    }
  )
}