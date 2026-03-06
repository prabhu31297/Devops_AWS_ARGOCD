# Devops_AWS_ARGOCD

Production-grade GitOps pipeline on AWS: **Terraform + Kubernetes (K3s) + GitLab CI/CD + Docker + ArgoCD** — fully automated from code push to live deployment.

---

## Architecture Overview

```
Developer push
     │
     ▼
┌─────────────────────────────────────────────────────────────────┐
│  GitLab CI/CD (.gitlab-ci.yml)                                  │
│                                                                  │
│  Stage 1 – test        Python unit tests (pytest)               │
│  Stage 2 – build       docker build → push to Amazon ECR        │
│  Stage 3 – deploy      update k8s/deployment.yaml image tag     │
└──────────────────────────┬──────────────────────────────────────┘
                           │  git push (updated manifest)
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│  ArgoCD (running inside K3s on AWS EC2)                          │
│                                                                  │
│  Watches this repository  →  detects new image tag              │
│  kubectl apply k8s/       →  rolling deployment to K3s          │
└──────────────────────────────────────────────────────────────────┘
```

### AWS infrastructure (Terraform)

| Resource | Purpose |
|---|---|
| VPC + subnets | Isolated network with public + private subnets |
| NAT Gateways | Outbound internet for private subnets |
| EC2 (t3.medium) | K3s single-node Kubernetes server |
| Elastic IP | Static public IP for the K3s node |
| Amazon ECR | Private Docker image registry |
| IAM roles | Least-privilege access for EC2 (pull) and GitLab runner (push) |
| Security Groups | Ports 22, 80, 443, 6443, 8080 (ArgoCD UI) |

---

## Repository Structure

```
.
├── .gitlab-ci.yml          # GitLab CI/CD pipeline definition
├── app/
│   ├── Dockerfile          # Multi-stage Docker image for the Flask app
│   ├── app.py              # Sample Flask application
│   ├── requirements.txt    # Production dependencies
│   ├── requirements-dev.txt# Test dependencies
│   └── tests/
│       └── test_app.py     # pytest unit tests
├── argocd/
│   ├── application.yaml    # ArgoCD Application (auto-sync enabled)
│   └── project.yaml        # ArgoCD AppProject with RBAC constraints
├── k8s/
│   ├── namespace.yaml      # gitops-app namespace
│   ├── deployment.yaml     # Rolling-update Deployment (2 replicas)
│   ├── service.yaml        # ClusterIP Service
│   └── ingress.yaml        # Ingress (nginx ingress controller)
├── scripts/
│   ├── install-k3s.sh      # Manual K3s installation helper
│   └── setup-argocd.sh     # ArgoCD install + manifest registration
└── terraform/
    ├── main.tf             # Provider config + S3 remote state backend
    ├── variables.tf        # Input variables
    ├── outputs.tf          # Useful outputs (IPs, ECR URL, IAM ARNs)
    ├── vpc.tf              # VPC, subnets, IGW, NAT, route tables
    ├── ec2.tf              # K3s EC2 instance + Elastic IP
    ├── ecr.tf              # ECR repository + lifecycle policy
    ├── iam.tf              # IAM roles for K3s node and GitLab runner
    ├── security_groups.tf  # Security group rules
    └── templates/
        └── k3s_userdata.sh.tftpl  # EC2 user-data bootstrap script
```

---

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | ≥ 1.6 |
| AWS CLI | ≥ 2.x |
| Docker | ≥ 24 |
| kubectl | ≥ 1.28 |
| GitLab (SaaS or self-hosted) | any |

---

## Quick Start

### 1 — Provision AWS infrastructure

```bash
# Create the remote state S3 bucket + DynamoDB lock table first
# (one-time setup — update bucket/region in terraform/main.tf)

cd terraform

# Initialise providers and remote backend
terraform init

# Review the execution plan
terraform plan \
  -var="ssh_key_name=<your-key-pair>" \
  -var="allowed_ssh_cidr=<your-ip>/32" \
  -var="gitlab_runner_entity_name=<runner-iam-role-name>"

# Apply
terraform apply \
  -var="ssh_key_name=<your-key-pair>" \
  -var="allowed_ssh_cidr=<your-ip>/32" \
  -var="gitlab_runner_entity_name=<runner-iam-role-name>"
```

Note down the outputs:

```
k3s_public_ip      = "x.x.x.x"
ecr_repository_url = "123456789.dkr.ecr.us-east-1.amazonaws.com/gitops-app"
```

### 2 — Configure GitLab CI/CD variables

In **GitLab → Settings → CI/CD → Variables**, add:

| Variable | Value |
|---|---|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID |
| `AWS_REGION` | e.g. `us-east-1` |
| `AWS_ACCESS_KEY_ID` | IAM key for the GitLab runner role |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret |
| `ECR_REPO_NAME` | `gitops-app` |
| `GIT_DEPLOY_TOKEN` | GitLab project access token (repo read/write) |

### 3 — Install ArgoCD and register the application

SSH into the K3s node (the bootstrap user-data already installs ArgoCD, but
you can also run this locally against any cluster):

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Or from your workstation if you copied the kubeconfig
bash scripts/setup-argocd.sh
```

Retrieve the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Access the UI via port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open https://localhost:8080  (user: admin)
```

### 4 — Trigger a deployment

Push any change to the `main` branch:

```bash
git commit --allow-empty -m "chore: trigger pipeline"
git push origin main
```

The GitLab pipeline will:
1. Run unit tests.
2. Build and push the Docker image to ECR.
3. Commit the updated image tag to `k8s/deployment.yaml`.

ArgoCD detects the new commit and performs a rolling deployment within
seconds — no manual `kubectl` commands required.

---

## Pipeline Stages

```
test  ──►  build-push  ──►  update-k8s-manifest
           (ECR push)        (GitOps git commit)
                                    │
                             ArgoCD detects change
                                    │
                             kubectl apply k8s/
```

- **test** — runs on every MR and every `main` push; fails fast.
- **build-push** — only on `main`; labels the image with the commit SHA.
- **update-k8s-manifest** — only on `main`; commits `[skip ci]` to avoid
  infinite loops.

---

## Customisation

| What | Where |
|---|---|
| Change instance type | `terraform/variables.tf` → `k3s_instance_type` |
| Add a custom domain | `k8s/ingress.yaml` → `spec.rules[].host` |
| Change replica count | `k8s/deployment.yaml` → `spec.replicas` |
| Add staging environment | Duplicate `argocd/application.yaml`, point to a `staging` branch |
| Replace K3s with EKS | Swap `terraform/ec2.tf` for an `aws_eks_cluster` resource |

---

## Security Notes

- The K3s node runs as a non-root container user (`UID 1000`).
- ECR images are scanned on push.
- IAM roles follow least-privilege (separate roles for push vs. pull).
- The S3 backend uses server-side encryption and DynamoDB state locking.
- Restrict `allowed_ssh_cidr` to your team's IP range in production.

