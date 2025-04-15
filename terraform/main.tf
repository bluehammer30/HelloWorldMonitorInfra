provider "aws" {
  region = var.aws_region
}

# Create ECR repository
module "ecr" {
  source = "./modules/ecr"
  name   = var.ecr_repository_name
  tags   = var.tags
}

# Create networking resources (VPC, subnets, etc.)
module "networking" {
  source             = "./modules/networking"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  tags               = var.tags
}

# Create EKS cluster
module "eks" {
  source                  = "./modules/eks"
  cluster_name            = var.eks_cluster_name
  cluster_version         = var.eks_cluster_version
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_subnet_ids
  security_group_id       = module.networking.eks_security_group_id
  node_group_name         = var.eks_node_group_name
  node_instance_type      = var.eks_node_instance_type
  node_desired_capacity   = var.eks_node_desired_capacity
  node_max_capacity       = var.eks_node_max_capacity
  node_min_capacity       = var.eks_node_min_capacity
  tags                    = var.tags
}

# Create RDS instance
module "rds" {
  source            = "./modules/rds"
  identifier        = var.rds_identifier
  allocated_storage = var.rds_allocated_storage
  storage_type      = var.rds_storage_type
  engine            = var.rds_engine
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  db_name           = var.rds_db_name
  username          = var.rds_username
  password          = var.rds_password
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.networking.rds_security_group_id
  tags              = var.tags
}

# Output values
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds.endpoint
}

output "rds_database_name" {
  description = "The name of the RDS database"
  value       = module.rds.database_name
}
