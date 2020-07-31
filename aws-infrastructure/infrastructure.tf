# This file contains terraform AWS infrostructure for benchmarking


# Security and variables

variable "instance-type" {
  description = "AWS instance type"
  default = "t2.medium"
}

variable "region" {
  description = "AWS region"
  default = "eu-central-1"
}

variable "zone" {
  description = "AWS zone"
  default = "eu-central-1b"
}

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region  = var.region
}

resource "aws_key_pair" "aws_ssh_key" {
  key_name = "aws_ssh_key"
  public_key = file("aws_ssh_key.pub")
}


# Dedicated network

resource "aws_vpc" "perf_net" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "perf-net",
    Project = "Artipie Performance"
  }
}

resource "aws_subnet" "perf_subnet" {
  cidr_block = cidrsubnet(aws_vpc.perf_net.cidr_block, 12, 1234)
  vpc_id = aws_vpc.perf_net.id
  availability_zone = var.zone
}

resource "aws_internet_gateway" "perf_gw" {
  vpc_id = aws_vpc.perf_net.id
  tags = {
    Name = "perf-gw",
    Project = "Artipie Performance"
  }
}

resource "aws_route_table" "perf_routes" {
  vpc_id = aws_vpc.perf_net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.perf_gw.id
  }
  tags = {
    Name = "perf_routes",
    Project = "Artipie Performance"
  }
}

resource "aws_route_table_association" "perf_subnet_association" {
  subnet_id = aws_subnet.perf_subnet.id
  route_table_id = aws_route_table.perf_routes.id
}


# Allow traffic 

resource "aws_security_group" "allow_ssh_sg" {
  name = "allow-all"
  vpc_id = aws_vpc.perf_net.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
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
  instance_type = var.instance-type
  key_name = aws_key_pair.aws_ssh_key.key_name
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("aws_ssh_key")
  }
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  key_name = aws_key_pair.aws_ssh_key.key_name
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("aws_ssh_key")
  }
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