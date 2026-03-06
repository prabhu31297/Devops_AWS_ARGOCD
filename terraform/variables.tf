variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "c7i-flex.large"
}

variable "key_name" {
  default = "devops-key"
}

variable "ami_id" {
  # Ubuntu 22.04 LTS - us-east-1
  default = "ami-0c7217cdde317cfec"
}
