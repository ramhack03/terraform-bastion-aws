#Security group for Application Load Balancer

resource "aws_security_group" "alb" {
  name        = "alb_sg"
  description = "Allow HTTP traffic to Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ALB-SG"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
}

#Application Load Balancer

resource "aws_lb" "app" {
  name               = "bastion-app-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public2.id
  ]

  tags = {

    Name        = "Bastion-APP-ALB"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
}

#Target Group for application instances

resource "aws_lb_target_group" "app" {
  name     = "bastion-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "Bastion-App-TG"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
}

# ALB HTTP Listener

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}