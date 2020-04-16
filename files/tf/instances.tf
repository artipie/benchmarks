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

resource "aws_instance" "repository" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.perf_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.repo_storage_size
  }

  tags = {
    Name = "repository"
  }

  connection {
    user = "ubuntu"
    host = self.public_ip
    private_key = file("id_rsa_perf")
  }

  provisioner "remote-exec" {
    inline = concat([
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y apt-transport-https gnupg-agent",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
    ], var.run_repository_cmds)
  }
}

resource "aws_instance" "jmeter" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.perf_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "jmeter"
  }

  connection {
    user = "ubuntu"
    host = self.public_ip
    private_key = file("id_rsa_perf")
  }

  provisioner "file" {
    source = var.scenario_file
    destination = "/home/ubuntu/${var.scenario_file}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-11-jdk-headless",
      "curl -O https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.2.1.tgz",
      "tar xzf apache-jmeter-5.2.1.tgz"
    ]
  }
}