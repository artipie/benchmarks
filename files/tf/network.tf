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
  availability_zone = var.availability_zone
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
  subnet_id      = aws_subnet.perf_subnet.id
  route_table_id = aws_route_table.perf_routes.id
}