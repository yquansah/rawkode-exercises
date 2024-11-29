terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "kubeadm_security_group" {
  id = "sg-008d57b5c21976371"
}

resource "aws_key_pair" "yoofi_key" {
  key_name = "yoofi_key_pair"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5CL5Rxf6h/xgGW1ad5I9n+fMuDpmkQJSpAtWCgjpOMrztbBYI4quIzU7pcfxBnMFwyl4aQ/yxLtA78LAXZ5TAlZiuQKvePtwjDzeEa6iU3Sqi84FGsQByNTW6N0j0JWtYsyzi8vwmEfUKNX7Lxoedaf2MaNJDIufGv28yysumde4xT6eUlNvU7Hiz0ZSsBuPw5co24awpidI/tefV+U4cSQLLGKL+z93tdp0o+gvaB0d2BD/V/n+N2WzY6jWk80WChjqtPzZHnDBGxYRMqp0dMpHqCvtmeBDz++/lkXo4k85TeMzAfWVASHdA60rHVzJaiJLzq/wEI/OCROMbJsOYBewBjkCdvDV2Qqie8lw99VmSR7WdbQMrBl4RSeBq2l2TCBSV7NlgmgsN9cOe8U9eBKKbvc8vIqa4jq2+y4Wid67VZ3B7sPcmpicJyvHBTfO6DAhpM/bgPtFzYxBAJBIHh/KfWSZU0lja98Zj6WaRxul5S5vuWVDiOt4dYZSZnUc= ybquansah@gmail.com"
}

resource "aws_instance" "kubeadm-instance" {
  ami           = "ami-0866a3c8686eaeeba"

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [data.aws_security_group.kubeadm_security_group.id]

  user_data = file("scripts/init.sh")

  tags = {
    Name = "kubeadm-instance"
  }
}
