# This file contains terraform AWS infrostructure for benchmarking


# Security and variables

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region  = "eu-central-1"
}

resource "aws_key_pair" "aws_ssh_key" {
  key_name   = "aws_ssh_key"
  public_key = file("aws_ssh_key.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# Client and Server AWS instances:

resource "aws_instance" "client" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.aws_ssh_key.key_name
  associate_public_ip_address = true
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.aws_ssh_key.key_name
  associate_public_ip_address = true
}


# Output env variables

output "public_client_ip_addr" {
  description = "The public IP of client machine"
  value = aws_instance.client.public_ip
}

output "public_server_ip_addr" {
  description = "The public IP of client machine"
  value =  aws_instance.server.public_ip
}

output "private_client_ip_addr" {
  description = "The public IP of client machine"
  value = aws_instance.client.private_ip
}

output "private_server_ip_addr" {
  description = "The public IP of client machine"
  value =  aws_instance.server.private_ip
}