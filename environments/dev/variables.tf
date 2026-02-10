variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type = number
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_flow_logs" {
  type = bool
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "public_access_cidrs" {
  type = list(string)
}

variable "log_retention_days" {
  type = number
}

variable "cluster_log_types" {
  type = list(string)
}

variable "addons" {
  type = map(any)
}

variable "node_groups" {
  type = map(any)
}

variable "tags" {
  type = map(string)
}
