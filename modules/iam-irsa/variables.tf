variable "project_name" { type = string }
variable "stage" { type = string }
variable "cluster_name" { type = string }

variable "secret_arns" {
  type = map(string)
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "k8s_namespace" {
  type = string
}

variable "k8s_service_account_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
