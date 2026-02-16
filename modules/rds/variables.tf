variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "worker_node_security_group_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
