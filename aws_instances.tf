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

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-k8s" {
  key_name   = "tf-k8s"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_instance" "controller" {
  count                       = 3
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.tf-k8s.key_name
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  private_ip                  = "10.0.1.1${count.index}"
  user_data                   = "name=controller-${count.index}"
  subnet_id                   = aws_subnet.kubernetes.id

  root_block_device {
    volume_size = "50"
  }

  tags = {
    "Name" = "controller-${count.index}"
  }

  source_dest_check = false

  provisioner "local-exec" {
    command = <<EOT
      wget -q --show-progress --https-only --timestamping \
        https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
        https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
      chmod +x cfssl cfssljson
      sudo mv cfssl /usr/local/bin/
      sudo mv cfssljson /usr/local/bin/
      cd csrs
      cfssl gencert -initca ca-csr.json | cfssljson -bare ca
      EOT
  }

}

resource "aws_instance" "worker" {
  count                       = 3
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.tf-k8s.key_name
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  private_ip                  = "10.0.1.2${count.index}"
  user_data                   = "name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24"
  subnet_id                   = aws_subnet.kubernetes.id

  root_block_device {
    volume_size = "50"
  }

  tags = {
    "Name" = "controller-${count.index}"
  }

  source_dest_check = false
}

