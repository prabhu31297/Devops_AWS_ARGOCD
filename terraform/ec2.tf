# ── Elastic IP for K3s node ───────────────────────────────────────────────────

resource "aws_eip" "k3s" {
  instance = aws_instance.k3s.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-k3s-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# ── K3s EC2 Instance ──────────────────────────────────────────────────────────

resource "aws_instance" "k3s" {
  ami                    = var.k3s_ami_id
  instance_type          = var.k3s_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.k3s.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(templatefile("${path.module}/templates/k3s_userdata.sh.tftpl", {
    ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    aws_region   = var.aws_region
  }))

  tags = {
    Name = "${var.project_name}-k3s"
    Role = "k3s-server"
  }
}

data "aws_caller_identity" "current" {}
