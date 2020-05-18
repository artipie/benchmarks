variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "region" {
  description = "Region to create AWS instances"
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
  default = "50"
}

variable "scenario_file" {
  description = "JMeter scenario file to run"
}

variable "repository" {
  description = "Repository to create (artipie | sonatype)"
  type = object({type = string, version = string})
}

variable "repository_credentials" {
  description = "Repository credentials"
  type = object({username = string, password = string})
  default = { username = "user", password = "password" }
}