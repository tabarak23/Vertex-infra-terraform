locals {
  name = "${var.project_name}-${var.stage}-${var.cluster_name}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.stage
    },
    var.tags
  )
}

resource "aws_iam_policy" "secrets_access" {
  name = "${local.name}-rds-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Resource = values(var.secret_arns)
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role" "irsa" {
  name = "${local.name}-rds-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}",
          "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "irsa_attach" {
  role       = aws_iam_role.irsa.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
