data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]

}

resource "aws_key_pair" "tf-k8s" {
  key_name   = "terraform-k8s"
  public_key = var.ssh_pub_key
}

resource "aws_instance" "controller" {
  count                       = 3
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "kubernetes"
  security_groups             = [aws_security_group.kubernetes.id]
  private_ip                  = "10.0.1.1${count.index}"
  user_data                   = "name=controller-${count.index}"
  subnet_id                   = aws_subnet.kubernetes.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "50"

  }

  tags = {
    "Name" = "controller-${count.index}"
  }

  source_dest_check = false

}

resource "aws_instance" "worker" {
  count                       = 3
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "kubernetes"
  security_groups             = [aws_security_group.kubernetes.id]
  private_ip                  = "10.0.1.2${count.index}"
  user_data                   = "name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24"
  subnet_id                   = aws_subnet.kubernetes.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "50"

  }

  tags = {
    "Name" = "controller-${count.index}"
  }

  source_dest_check = false
}