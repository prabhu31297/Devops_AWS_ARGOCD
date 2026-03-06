# ── IAM Role: K3s EC2 Instance ────────────────────────────────────────────────

resource "aws_iam_role" "k3s" {
  name = "${var.project_name}-k3s-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k3s" {
  name = "${var.project_name}-k3s-profile"
  role = aws_iam_role.k3s.name
}

# Allow K3s node to pull images from ECR
resource "aws_iam_role_policy" "k3s_ecr_pull" {
  name = "${var.project_name}-k3s-ecr-pull"
  role = aws_iam_role.k3s.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        # GetAuthorizationToken must target * (not a specific repo)
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}

# ── IAM Role: GitLab CI Runner ────────────────────────────────────────────────

resource "aws_iam_role" "gitlab_runner" {
  name = "${var.project_name}-gitlab-runner-role"

  # Trust policy: allow GitLab OIDC or an assumed-role from a specific IAM user.
  # Replace the Principal ARN with your GitLab runner's IAM user/role ARN,
  # or configure OIDC federation per:
  # https://docs.gitlab.com/ee/ci/cloud_services/aws/
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Replace with the specific IAM entity (user or role) used by the runner
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.gitlab_runner_entity_name}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Allow GitLab runner to push images to ECR
resource "aws_iam_role_policy" "gitlab_runner_ecr" {
  name = "${var.project_name}-gitlab-runner-ecr"
  role = aws_iam_role.gitlab_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        # GetAuthorizationToken must target * (not a specific repo)
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
        ]
        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}
