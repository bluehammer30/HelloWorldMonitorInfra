output "endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.this.db_name
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}
