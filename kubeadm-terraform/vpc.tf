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
}

resource "aws_subnet" "kubeadm_public_subnet" {
  vpc_id                  = aws_vpc.kubeadm_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "kubeadm_public_association" {
  subnet_id      = aws_subnet.kubeadm_public_subnet.id
  route_table_id = aws_route_table.kubeadm_route_table.id
}

resource "aws_network_acl" "kubeadm_nacl" {
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_network_acl_rule" "kubeadm_nacl_rule_ingress" {
  network_acl_id = aws_network_acl.kubeadm_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "kubeadm_nacl_rule_egress" {
  network_acl_id = aws_network_acl.kubeadm_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "kubeadm_nacl_association" {
  network_acl_id = aws_network_acl.kubeadm_nacl.id
  subnet_id      = aws_subnet.kubeadm_public_subnet.id
}
