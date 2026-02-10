locals {
  project_name = "vertex"
  stage        = "dev"
}

module "vpc" {
  source = "../../modules/vpc"

  project_name       = local.project_name
  stage              = local.stage
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

module "iam" {
  source = "../../modules/iam"

  project_name = local.project_name
  stage        = local.stage
  cluster_name = var.name
  tags         = var.tags
}

module "eks" {
  source = "../../modules/eks"

  name        = var.name
  environment = local.stage

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  kubernetes_version = var.kubernetes_version
  cluster_role_arn  = module.iam.cluster_role_arn
  node_role_arn     = module.iam.node_group_role_arn

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  log_retention_days = var.log_retention_days
  cluster_log_types  = var.cluster_log_types

  addons      = var.addons
  node_groups = var.node_groups
  tags        = var.tags
}

module "secrets" {
  source = "../../modules/secrets"

  project_name = local.project_name
  stage        = local.stage
}
