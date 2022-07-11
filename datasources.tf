data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]

  }
}

resource "aws_instance" "ilab_bastion_host" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.imaginelb_auth.id
  vpc_security_group_ids = ["${aws_security_group.albonly.id}"]
  subnet_id              = aws_subnet.ilab_subnet_pub_a.id
  user_data              = file("userdata.tpl")

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/imaginelbkey"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]

  }
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "ilab bastion host"
  }
}

/*resource "aws_instance" "ilab_lb_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.imaginelb_auth.id
  vpc_security_group_ids = ["${aws_security_group.allow_http_ssh.id}"]
  subnet_id              = aws_subnet.ilab_subnet_pub_a.id
  user_data              = file("userdata.tpl")

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/imaginelbkey"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]

  }
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "ilab lb instance"
  }
}*/