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

resource "aws_instance" "artipie" {
  count = var.repository.type == "artipie" ? 1 : 0

  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.perf_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.repo_storage_size
  }

  tags = {
    Name = "repository",
    Project = "Artipie Performance"
  }

  connection {
    user = "ubuntu"
    host = self.public_ip
    private_key = file("id_rsa_perf")
  }

  provisioner "file" {
    source = "wait-instance-init.sh"
    destination = "/home/ubuntu/wait-instance-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ./wait-instance-init.sh",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y apt-transport-https gnupg-agent",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "mkdir upload"
    ]
  }

  provisioner "file" {
    source = "artipie"
    destination = "/home/ubuntu/upload"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p artipie/repo",
      "cp upload/artipie/*.yaml artipie/repo",
      "sudo docker run -d -e ARTIPIE_USER_NAME=${var.repository_credentials.username} -e ARTIPIE_USER_PASS=${var.repository_credentials.password} -v /home/ubuntu/artipie:/var/artipie -p 80:80 --name artipie artipie/artipie:${var.repository.version}",
      "rm -fr upload"
    ]
  }
}

resource "aws_instance" "sonatype" {
  count = var.repository.type == "sonatype" ? 1 : 0

  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.perf_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh_sg.id]
  subnet_id = aws_subnet.perf_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.repo_storage_size
  }

  tags = {
    Name = "repository",
    Project = "Artipie Performance"
  }

  connection {
    user = "ubuntu"
    host = self.public_ip
    private_key = file("id_rsa_perf")
  }

  provisioner "file" {
    source = "wait-instance-init.sh"
    destination = "/home/ubuntu/wait-instance-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ./wait-instance-init.sh",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https gnupg-agent",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "mkdir upload",
      "mkdir nexus-data",
      "sudo chown 200 nexus-data",
    ]
  }

  provisioner "file" {
    source = "sonatype"
    destination = "/home/ubuntu/upload"
  }

  provisioner "file" {
    content = templatefile("templates/credentials.tpl", {
      username = var.repository_credentials.username,
      password = var.repository_credentials.password
    })
    destination = "/home/ubuntu/upload/sonatype/credentials"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -v /home/ubuntu/nexus-data:/nexus-data -p 80:8081 --name nexus sonatype/nexus3:${var.repository.version}",
      "sudo sh upload/sonatype/wait-nexus-ready.sh",
      "sudo sed -i '$ a nexus.scripts.allowCreation=true' nexus-data/etc/nexus.properties",
      "sudo docker restart nexus",
      "sudo sh upload/sonatype/wait-nexus-ready.sh",
      "sh upload/sonatype/setup-nexus.sh",
      "rm -fr upload"
    ]
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
    Name = "jmeter",
    Project = "Artipie Performance"
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

  provisioner "file" {
    source = "wait-instance-init.sh"
    destination = "/home/ubuntu/wait-instance-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ./wait-instance-init.sh",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-11-jre-headless",
      "curl -O https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.2.1.tgz",
      "tar xzf apache-jmeter-5.2.1.tgz"
    ]
  }
}