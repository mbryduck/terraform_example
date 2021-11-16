### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}

# Security Group
variable "ingressrules" {
  type    = list(number)
  default = [8080, 22]
}

variable "pem_file" {
  type    = string
  default = "./Jenkins_EC2_Key.pem"
}

# Ubuntu 18.04 AMI ID
variable "ubuntu_ami_id" {
  type    = string
  default = "ami-0747bdcabd34c712a"
}
