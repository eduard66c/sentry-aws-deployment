resource "aws_key_pair" "sentry_ssh_key" {
  key_name = "sentry-deployer-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "sentry_sg" {
    name = "sentry-secure-sg"
    description = "Restricted access to Sentry"

    ingress {
        description = "SSH allowed only from my current public IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
    }

    ingress {
        description = "Access to the web UI of Sentry"
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
    }

    egress {
        description = "Internet access required for installing Docker"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "sentry_vm" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = aws_key_pair.sentry_ssh_key.key_name

  vpc_security_group_ids = [aws_security_group.sentry_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}