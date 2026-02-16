locals {
  name = "${var.project_name}-${var.stage}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.stage
    },
    var.tags
  )

  databases = {
    users    = { db_name = "users" }
    products = { db_name = "products" }
    orders   = { db_name = "orders" }
  }
}

data "aws_subnet" "selected" {
  id = var.private_subnet_ids[0]
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name}-rds-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds-"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name}-rds-sg"
  })
}

resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.worker_node_security_group_id
}

resource "random_password" "db" {
  for_each = local.databases

  length  = 20
  special = true
}

resource "aws_db_instance" "this" {
  for_each = local.databases

  identifier                 = "${local.name}-${each.key}-db"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  storage_type               = "gp3"
  multi_az                   = false
  publicly_accessible        = false
  deletion_protection        = false
  backup_retention_period    = 7
  skip_final_snapshot        = true
  port                       = 3306

  db_name  = each.value.db_name
  username = "admin"
  password = random_password.db[each.key].result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = merge(local.common_tags, {
    Name = "${local.name}-${each.key}-db"
  })
}

resource "aws_secretsmanager_secret" "db" {
  for_each = local.databases

  name = "${local.name}-${each.key}-db-secret"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db" {
  for_each = local.databases

  secret_id = aws_secretsmanager_secret.db[each.key].id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db[each.key].result
    endpoint = aws_db_instance.this[each.key].address
    port     = 3306
    database = each.value.db_name
  })
}
