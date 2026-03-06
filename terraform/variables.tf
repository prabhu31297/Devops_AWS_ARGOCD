variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "gitops-pipeline"
}

variable "environment" {
  description = "Deployment environment (e.g. production, staging)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "k3s_instance_type" {
  description = "EC2 instance type for the K3s node"
  type        = string
  default     = "t3.medium"
}

variable "k3s_ami_id" {
  description = "AMI ID for the K3s EC2 instance (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS us-east-1; update per region
}

variable "ssh_key_name" {
  description = "Name of the EC2 SSH key pair to associate with the K3s instance"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the K3s instance (and access the Kubernetes API / ArgoCD UI). Must be explicitly provided — restrict to your team's IP range."
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for application images"
  type        = string
  default     = "gitops-app"
}

variable "gitlab_runner_entity_name" {
  description = "Name of the existing IAM role or user that GitLab CI runners will use to assume the gitlab-runner IAM role"
  type        = string
}
