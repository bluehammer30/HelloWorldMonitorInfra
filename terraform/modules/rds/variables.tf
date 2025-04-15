variable "identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "Database engine for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version for the RDS instance"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "db_name" {
  description = "Name of the database to create in the RDS instance"
  type        = string
}

variable "username" {
  description = "Username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for the RDS instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
