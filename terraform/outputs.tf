output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "k3s_instance_id" {
  description = "EC2 instance ID of the K3s node"
  value       = aws_instance.k3s.id
}

output "k3s_public_ip" {
  description = "Public IP address of the K3s node"
  value       = aws_eip.k3s.public_ip
}

output "k3s_private_ip" {
  description = "Private IP address of the K3s node"
  value       = aws_instance.k3s.private_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_registry_id" {
  description = "Registry ID (AWS account ID)"
  value       = aws_ecr_repository.app.registry_id
}

output "gitlab_runner_role_arn" {
  description = "IAM role ARN to be assumed by the GitLab CI runner for ECR access"
  value       = aws_iam_role.gitlab_runner.arn
}
