provider "aws" {
  region = "us-west-2"
}

module "hello_world" {
  source = "../../"

  # Override default variables for dev environment
  aws_region          = "us-west-2"
  eks_cluster_name    = "hello-world-dev"
  rds_identifier      = "hello-world-dev"
  ecr_repository_name = "hello-world-dev"
  
  # RDS credentials (use environment variables or a secure method)
  rds_username = "admin"
  # Password should be provided via environment variables, not hardcoded
  rds_password = ""

  tags = {
    Environment = "dev"
    Project     = "monitoring-challenge"
    ManagedBy   = "terraform"
  }
}
