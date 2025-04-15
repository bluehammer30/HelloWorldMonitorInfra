variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "monitoring-challenge"
    ManagedBy   = "terraform"
  }
}

# ECR variables
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "hello-world-app"
}

# Networking variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "hello-world-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EKS variables
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "hello-world-cluster"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "eks_node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "hello-world-nodes"
}

variable "eks_node_instance_type" {
  description = "Instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_max_capacity" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "eks_node_min_capacity" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 2
}

# RDS variables
variable "rds_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "hello-world-db"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "rds_storage_type" {
  description = "Storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable "rds_engine" {
  description = "Database engine for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "Database engine version for the RDS instance"
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "rds_db_name" {
  description = "Name of the database to create in the RDS instance"
  type        = string
  default     = "hellodb"
}

variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "rds_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}
