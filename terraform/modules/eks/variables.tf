variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_instance_type" {
  description = "Instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_max_capacity" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "node_min_capacity" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "security_group_id" {
  description = "ID of the security group for the EKS cluster"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
