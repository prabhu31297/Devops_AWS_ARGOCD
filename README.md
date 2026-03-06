# Devops_AWS_ARGOCD
production-grade GitOps pipeline on AWS: Terraform + Kubernetes (K3s) + GitLab CI/CD + Docker + ArgoCD — fully automated from code push to live deployment.

developed by Prabhu


# DevOps Pipeline — AWS + Kubernetes + GitOps

A production-grade, end-to-end DevOps pipeline built 
from scratch on AWS. Every git push automatically 
triggers a full CI/CD pipeline that builds, packages, 
and deploys a containerized application to a 
Kubernetes cluster — with zero manual intervention.

## Architecture
Developer → GitLab CI/CD → Docker Registry → ArgoCD → Kubernetes (AWS EC2)

## Tech Stack
- **Terraform**   — Infrastructure as Code (VPC, EC2, Security Groups)
- **AWS EC2**     — Master + Worker nodes (us-east-1)
- **K3s**         — Lightweight Kubernetes cluster
- **Docker**      — Application containerization
- **GitLab CI/CD**— Automated build and manifest update pipeline
- **ArgoCD**      — GitOps continuous deployment + drift detection

## How It Works
1. Push code to GitLab
2. Pipeline builds Docker image → pushes to GitLab Registry
3. Pipeline updates Kubernetes manifest with new image tag
4. ArgoCD detects change → auto-syncs to Kubernetes
5. App live with zero downtime rolling update

## Features
- Zero manual deployments — fully automated
- Self-healing — ArgoCD detects and fixes drift
- High availability — 2 pods spread across master/worker
- Rolling updates — zero downtime on every deploy
- Infrastructure as Code — entire AWS setup in Terraform
```


