variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "region" {
  default = "eu-central-1"
}

variable "availability_zone" {
  description = "Availability Zone for Subnets (must corresponds with Region)"
  default = "eu-central-1b"
}

variable "instance_type" {
  description = "AWS EC2 Instance Size"
  default = "t2.medium"
}

variable "repo_storage_size" {
  description = "Storage size for repository (in GB)"
  default = "20"
}

variable "scenario_file" {
  description = "JMeter scenario file to run"
}

variable "run_repository_cmds" {
  type = list(string)
  description = "Command line to start and init repository (usually as docker container)"
}