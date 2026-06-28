resource "aws_security_group" "ssh" {
  name        = "${var.name_prefix}-ssh-sg"
  description = "Security group for SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-ssh-sg"
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group" "public_http" {
  name        = "${var.name_prefix}-public-http-sg"
  description = "Security group for public HTTP access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-public-http-sg"
  }
}

resource "aws_security_group_rule" "public_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http.id
}

resource "aws_security_group" "private_http" {
  name        = "${var.name_prefix}-private-http-sg"
  description = "Security group for private HTTP access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-http-sg"
  }
}

resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
}
