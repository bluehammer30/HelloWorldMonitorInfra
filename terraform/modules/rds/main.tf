resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier           = var.identifier
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = "default.${var.engine}${var.engine_version}"
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  
  skip_final_snapshot     = true
  backup_retention_period = 7
  storage_encrypted       = true
  
  tags = var.tags
}

# Create a secret in AWS Secrets Manager for the RDS credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.identifier}-credentials"
  description = "RDS credentials for ${var.identifier}"
  
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.username
    password = var.password
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
}
