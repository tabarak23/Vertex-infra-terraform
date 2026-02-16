variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
}

variable "single_nat_gateway" {
  description = "Whether to create a single shared NAT gateway"
  type        = bool
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
}

variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint"
  type        = bool
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public EKS endpoint"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain EKS control plane logs"
  type        = number
}

variable "cluster_log_types" {
  description = "List of EKS control plane log types to enable"
  type        = list(string)
}

variable "addons" {
  description = "Map of EKS addons and their configurations"
  type        = map(any)
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations"
  type        = map(any)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
variable "allowed_ssh_cidr" {
  type = string
}

variable "key_name" {
  type = string
}
