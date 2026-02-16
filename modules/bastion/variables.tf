variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  type = string
}

variable "key_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
