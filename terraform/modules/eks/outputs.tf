output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "lb_controller_role_arn" {
  description = "The ARN of the IAM role for the AWS Load Balancer Controller"
  value       = aws_iam_role.lb_controller.arn
}

output "secrets_manager_csi_role_arn" {
  description = "The ARN of the IAM role for the AWS Secrets Manager CSI driver"
  value       = aws_iam_role.secrets_manager_csi.arn
}
