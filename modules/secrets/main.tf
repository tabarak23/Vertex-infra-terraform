################################
# Locals
################################
locals {
  name = "${var.project_name}-${var.stage}"

  common_tags = {
    Project     = var.project_name
    Environment = var.stage
  }
}

#order db secrets 
resource "aws_secretsmanager_secret" "orders_db" {
  name = "${local.name}-orders-db"

  recovery_window_in_days = 7

  tags = merge(
    {
      Name    = "${local.name}-orders-db"
      Service = "orders"
      Type    = "mysql"
    },
    local.common_tags
  )
}

#product db secrets
resource "aws_secretsmanager_secret" "products_db" {
  name = "${local.name}-products-db"

  recovery_window_in_days = 7

  tags = merge(
    {
      Name    = "${local.name}-products-db"
      Service = "products"
      Type    = "mysql"
    },
    local.common_tags
  )
}

#user db secrets
resource "aws_secretsmanager_secret" "users_db" {
  name = "${local.name}-users-db"

  recovery_window_in_days = 7

  tags = merge(
    {
      Name    = "${local.name}-users-db"
      Service = "users"
      Type    = "mysql"
    },
    local.common_tags
  )
}
