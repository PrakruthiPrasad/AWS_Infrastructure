resource "aws_security_group" "loadBalancer_SG" {
  name   = "loadbalance_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "loadbalance_sg"
  }
}

resource "aws_lb" "loadBalancer" {
  name                       = "loadBalance"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.loadBalancer_SG.id}"]
  subnets                    = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
  enable_deletion_protection = false

  tags = {
    Environment = "prod"
  }
}


resource "aws_lb_target_group" "loadBalancerTargetGroup" {
  name        = "loadBalancerTargetGroup"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "loadbalancerListener" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port              = "80"
  protocol          = "HTTP"
  //   ssl_policy = "ELBSecurityPolicy-2016-08"
  //   certificate_arn = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadBalancerTargetGroup.arn
  }
}