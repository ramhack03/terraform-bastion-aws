# Launch Template for application servers

resource "aws_launch_template" "app" {
  name_prefix   = "bastion-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.private.id
  ]

  user_data = base64encode(file("${path.module}/userdata.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "ASG-App-Instance"
      Environment = "Dev"
      Project     = "Bastion-Architecture"
    }
  }
}

# Auto Scaling Group

resource "aws_autoscaling_group" "app" {
  name = "bastion-app-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.private.id
  ]

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-App-Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "Bastion-Architecture"
    propagate_at_launch = true
  }
}