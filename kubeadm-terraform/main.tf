resource "aws_vpc" "kubeadm_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "kubeadm_igw" {
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_route_table" "kubeadm_route_table" {
  vpc_id = aws_vpc.kubeadm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_igw.id
  }

  tags = {
    Name = "Kubeadm Route Table"
  }
}

resource "aws_subnet" "kubeadm_public_subnet" {
  vpc_id            = aws_vpc.kubeadm_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_route_table_association" "kubeadm_public_association" {
  subnet_id      = aws_subnet.kubeadm_public_subnet.id
  route_table_id = aws_route_table.kubeadm_route_table.id
}

resource "aws_security_group" "kubeadm_security_group" {
  name   = "allow_ssh"
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "kubeadm_allow_ssh_ipv4" {
  security_group_id = aws_security_group.kubeadm_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_key_pair" "yoofi_key" {
  key_name = "yoofi_key_pair"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5CL5Rxf6h/xgGW1ad5I9n+fMuDpmkQJSpAtWCgjpOMrztbBYI4quIzU7pcfxBnMFwyl4aQ/yxLtA78LAXZ5TAlZiuQKvePtwjDzeEa6iU3Sqi84FGsQByNTW6N0j0JWtYsyzi8vwmEfUKNX7Lxoedaf2MaNJDIufGv28yysumde4xT6eUlNvU7Hiz0ZSsBuPw5co24awpidI/tefV+U4cSQLLGKL+z93tdp0o+gvaB0d2BD/V/n+N2WzY6jWk80WChjqtPzZHnDBGxYRMqp0dMpHqCvtmeBDz++/lkXo4k85TeMzAfWVASHdA60rHVzJaiJLzq/wEI/OCROMbJsOYBewBjkCdvDV2Qqie8lw99VmSR7WdbQMrBl4RSeBq2l2TCBSV7NlgmgsN9cOe8U9eBKKbvc8vIqa4jq2+y4Wid67VZ3B7sPcmpicJyvHBTfO6DAhpM/bgPtFzYxBAJBIHh/KfWSZU0lja98Zj6WaRxul5S5vuWVDiOt4dYZSZnUc= ybquansah@gmail.com"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240809"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "kubeadm_instance" {
  ami = data.aws_ami.ubuntu.id

  subnet_id = aws_subnet.kubeadm_public_subnet.id

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [aws_security_group.kubeadm_security_group.id]

  user_data = file("scripts/init.sh")

  tags = {
    Name = "kubeadm-instance"
  }
}
