
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "App security group"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-app-sg"
    Project = var.project_name
  }
}


resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Public API access"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

# Never 0.0.0.0/0 here — Checkov flags this

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app_sg.id
  description       = "SSH from allowed IP only"
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Outbound for package installs and AWS API calls"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    encrypted   = true
    volume_size = 30
    volume_type = "gp3"
  }

  # IMDSv2 only — mitigates the SSRF path used in the Capital One breach

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name    = "${var.project_name}-app-instance"
    Project = var.project_name
  }
}
