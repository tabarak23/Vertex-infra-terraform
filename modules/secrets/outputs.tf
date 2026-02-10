output "orders_db_secret_name" {
  value = aws_secretsmanager_secret.orders_db.name
}

output "orders_db_secret_arn" {
  value = aws_secretsmanager_secret.orders_db.arn
}

output "products_db_secret_name" {
  value = aws_secretsmanager_secret.products_db.name
}

output "products_db_secret_arn" {
  value = aws_secretsmanager_secret.products_db.arn
}

output "users_db_secret_name" {
  value = aws_secretsmanager_secret.users_db.name
}

output "users_db_secret_arn" {
  value = aws_secretsmanager_secret.users_db.arn
}
