terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "pgdog_iam" {
  source = "../.."

  eks_cluster_name       = var.eks_cluster_name
  rds_database_name      = var.rds_database_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
  aws_region             = var.aws_region

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "pgdog-enterprise"
  }
}

output "pgdog_role_arn" {
  description = "Share this ARN with the PgDog team"
  value       = module.pgdog_iam.role_arn
}

output "pgdog_role_name" {
  description = "Name of the created IAM role"
  value       = module.pgdog_iam.role_name
}
