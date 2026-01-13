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

variable "pgdog_account_id" {
  description = "PgDog AWS account ID that will assume the role"
  type        = string
  default     = "588738614642"
}

variable "external_id" {
  description = "External ID for AssumeRole trust policy"
  type        = string
  default     = "32b0a5561c176331ef68fbde550397191a005ee2cbf07414922cfa85cd8d1926"
}

variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
  default     = "pgdog-client-hosted-role"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
