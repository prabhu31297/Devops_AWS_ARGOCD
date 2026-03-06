output "master_public_ip" {
  value       = aws_instance.k8s_master.public_ip
  description = "Master node public IP"
}

output "worker_public_ip" {
  value       = aws_instance.k8s_worker.public_ip
  description = "Worker node public IP"
}

output "ssh_master" {
  value = "ssh -i ${path.module}/devops-key.pem ubuntu@${aws_instance.k8s_master.public_ip}"
}

output "ssh_worker" {
  value = "ssh -i ${path.module}/devops-key.pem ubuntu@${aws_instance.k8s_worker.public_ip}"
}
