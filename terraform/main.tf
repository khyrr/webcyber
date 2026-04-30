data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }
}

# tfsec:ignore:aws-ec2-add-description-to-security-group cosmetic LOW; setting description forces SG replacement
resource "aws_security_group" "ssh" {
  name_prefix = "allow_inboud_outboud"

  dynamic "ingress" {
    for_each = var.sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    Name = var.sg_name
  }
}

# tfsec:ignore:aws-ec2-enable-at-rest-encryption AWS Academy lab; no sensitive data and encryption forces EC2 replacement
resource "aws_instance" "instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ssh.name]
  key_name        = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com | sudo sh",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl enable docker",
      "sudo systemctl start docker"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = var.instance_name
  }
}

resource "aws_eip_association" "instance" {
  instance_id   = aws_instance.instance.id
  allocation_id = var.eip_allocation_id
}

output "public_ip" {
  value = aws_eip_association.instance.public_ip
}

output "public_dns" {
  value = aws_instance.instance.public_dns
}
