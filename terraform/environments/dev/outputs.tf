output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.hello_world.ecr_repository_url
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.hello_world.eks_cluster_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.hello_world.rds_endpoint
}
