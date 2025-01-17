resource "aws_alb" "webapp_alb" {
  name            = "webapp-Load-Balancer"
  subnets         = [aws_subnet.webapp_subnet_1.id, aws_subnet.webapp_subnet_2.id]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "app" {
  name        = "webapp-Target-Group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.webapp_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}


# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.webapp_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}