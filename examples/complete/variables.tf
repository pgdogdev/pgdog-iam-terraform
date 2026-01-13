variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "rds_database_name" {
  description = "Name of the RDS database instance"
  type        = string
}

variable "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID (e.g., Z02965561036BDGGGL5TJ)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "us-west-2"
}
