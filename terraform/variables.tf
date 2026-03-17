variable "aws_region" {
 description = "AWS Region to deploy to"
 type = string
 default = "eu-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision; Sentry is pretty memory-intensive so at least 4GB RAM should be provided."
  type = string
  default = "t3.medium"
}

variable "instance_name" {
    description = "Value for the instance name tag"
    type = string
    default = "sentry-server"
}

variable "public_key_path" {
  description = "Path to key to be uploaded to the EC2 instance for SSH access"
  type = string
  default = "~/.ssh/sentry_key.pub"
}

variable "private_key_path" {
  description = "Path to the private key to be used by Ansible"
  type = string
  default = "~/.ssh/sentry_key"
}