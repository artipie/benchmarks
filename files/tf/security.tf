resource "aws_security_group" "allow_ssh_sg" {
  name = "allow-ssh-sg"
  vpc_id = aws_vpc.perf_net.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      aws_subnet.perf_subnet.cidr_block
    ]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}