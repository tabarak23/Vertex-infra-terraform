output "rds_endpoints" {
  value = {
    for k, v in aws_db_instance.this :
    k => v.address
  }
}

output "rds_passwords" {
  sensitive = true
  value = {
    for k, v in random_password.db :
    k => v.result
  }
}

output "secret_arns" {
  value = {
    for k, v in aws_secretsmanager_secret.db :
    k => v.arn
  }
}
