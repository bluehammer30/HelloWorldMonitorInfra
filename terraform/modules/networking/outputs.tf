output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "rds_security_group_id" {
  description = "ID of the security group for RDS"
  value       = aws_security_group.rds.id
}

output "eks_security_group_id" {
  description = "ID of the security group for EKS"
  value       = aws_security_group.eks.id
}
