resource "aws_lb" "main" {
  name               = "demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ecs.id]
  subnets            = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

resource "aws_lb_target_group" "main" {
  name        = "demo-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path = "/"
    port = "80"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  mutual_authentication {
    mode            = "verify"
    trust_store_arn = aws_lb_trust_store.mtls_trust_store.arn
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [
    aws_lb_trust_store.mtls_trust_store,
    aws_acm_certificate.alb_acm_cert,
    aws_acm_certificate_validation.cert_validation
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
