data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  user_data = file("${path.module}/user_data.sh")
}

resource "aws_launch_template" "this" {
  name          = "${var.name_prefix}-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  user_data     = base64encode(local.user_data)

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [var.ssh_sg_id, var.private_http_sg_id]
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  vpc_zone_identifier       = var.subnet_ids
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  target_group_arns         = [aws_lb_target_group.this.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
    ]
  }
}

resource "aws_lb" "this" {
  name               = "${var.name_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_http_sg_id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
