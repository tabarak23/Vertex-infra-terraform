variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}




variable "rds_endpoints" { type = map(string) }
variable "rds_passwords" { type = map(string) }

variable "tags" { type = map(string) }
