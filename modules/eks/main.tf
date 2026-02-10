################################
# Locals
################################
locals {
  name = "${var.name}-${var.environment}-eks"
}

################################
# KMS for Secrets Encryption
################################
resource "aws_kms_key" "this" {
  description             = "KMS key for EKS cluster ${local.name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = local.name
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.this.key_id
}

################################
# CloudWatch Logs
################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

################################
# Security Groups
################################
resource "aws_security_group" "control_plane" {
  name_prefix = "${local.name}-control-plane-"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name}-control-plane"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "worker_nodes" {
  name_prefix = "${local.name}-workers-"
  description = "EKS worker node security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name                                        = "${local.name}-workers"
    "kubernetes.io/cluster/${local.name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "workers_to_control_plane" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker_nodes.id
}

resource "aws_security_group_rule" "control_plane_to_workers" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 1025
  to_port                  = 65535
  security_group_id        = aws_security_group.worker_nodes.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "workers_to_workers" {
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.worker_nodes.id
  self              = true
}

################################
# EKS Cluster
################################
resource "aws_eks_cluster" "this" {
  name     = local.name
  version  = var.kubernetes_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.control_plane.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.this.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = var.cluster_log_types

  depends_on = [
    aws_cloudwatch_log_group.this
  ]

  tags = var.tags
}

################################
# IRSA (OIDC Provider)
################################
data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.enable_irsa ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = local.name
  })
}

################################
# EKS Addons
################################
resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = lookup(each.value, "version", null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags
}

################################
# Launch Templates
################################
resource "aws_launch_template" "node_groups" {
  for_each = var.node_groups

  name_prefix = "${local.name}-${each.key}-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = lookup(each.value, "disk_size", 20)
      volume_type = "gp3"
      encrypted   = true
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.worker_nodes.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${local.name}-${each.key}"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################
# Managed Node Groups
################################
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  instance_types = each.value.instance_types
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")

  launch_template {
    id      = aws_launch_template.node_groups[each.key].id
    version = aws_launch_template.node_groups[each.key].latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags
}
