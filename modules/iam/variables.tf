variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "stage" {
  description = "Deployment stage (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "secret_arns" {
  description = "Map of secret ARNs to grant access to"
  type        = map(string)
  default     = {}
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider associated with the EKS cluster"
  type        = string
  default     = null
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider associated with the EKS cluster"
  type        = string
  default     = null
}

variable "k8s_namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
  default     = null
}

variable "k8s_service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
