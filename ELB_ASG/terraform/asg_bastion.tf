resource "aws_launch_template" "bastion" {
  name_prefix   = "bastion-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-bastion" }
  }
}

resource "aws_autoscaling_group" "bastion" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = aws_subnet.public[*].id
  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }
}