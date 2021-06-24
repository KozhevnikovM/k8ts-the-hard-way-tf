
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "kubernetes-the-hard-way"
  }
}

resource "aws_subnet" "kubernetes" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "kubernetes"
  }
}

resource "aws_internet_gateway" "kubernetes" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_route_table" "kubernetes" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes.id
  }

  tags = {
    "Name" = "kubernates"
  }
}

resource "aws_route_table_association" "kubernates" {
  subnet_id      = aws_subnet.kubernetes.id
  route_table_id = aws_route_table.kubernetes.id
}

resource "aws_security_group" "kubernetes" {
  name = "kubernetes"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "all"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = [aws_vpc.vpc.cidr_block, "10.200.0.0/16"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
