output "jmeter_ip_addr" {
  description = "The public IP of the loader machine"
  value = aws_instance.jmeter.public_ip
}

output "server_ip_addr" {
  description = "The private IP of the tested service machine"
  value = coalesce(join("", aws_instance.artipie.*.private_ip), join("", aws_instance.sonatype.*.private_ip))
}