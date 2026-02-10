variable "name" {
  description = "Project or application name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS (usually private subnets)"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access EKS public endpoint"
  type        = list(string)
  default     = []
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention for EKS logs"
  type        = number
  default     = 7
}

variable "cluster_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "addons" {
  description = "EKS addons to install"
  type        = map(any)
}

variable "node_groups" {
  description = "EKS managed node groups"
  type        = map(any)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
