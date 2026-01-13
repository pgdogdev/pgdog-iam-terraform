# PgDog Client-Hosted IAM Terraform Module

This Terraform module creates the necessary IAM resources for PgDog Enterprise to access your AWS-hosted EKS cluster, RDS database, and Route53 hosted zone.

## Overview

The module creates:

- An IAM role with a trust policy allowing PgDog's AWS account to assume it
- An inline role policy granting specific permissions for EKS, RDS, Route53, and CloudFormation
- A permission boundary policy to enforce additional security constraints

## Prerequisites

Before using this module, you need to gather the following information from your AWS Console:

1. **AWS Account ID**: Click your name in the top right corner of AWS Console, copy the Account ID
2. **AWS Region**: Go to EKS, find your PgDog cluster, check the region in the top right corner
3. **EKS Cluster Name**: Go to EKS service and copy the cluster name
4. **Route53 Hosted Zone ID**: Go to Route53 → Hosted Zones → Click on your zone → Copy the Hosted zone ID
5. **RDS Database Name**: Go to RDS service and copy the database instance name

## Usage

### Basic Example

```hcl
module "pgdog_iam" {
  source = "github.com/pgdogdev/pgdog-iam-terraform"

  eks_cluster_name       = "my-pgdog-cluster"
  rds_database_name      = "my-pgdog-db"
  route53_hosted_zone_id = "Z02965561036BDGGGL5TJ"
  aws_region             = "us-west-2"
}

output "pgdog_role_arn" {
  value       = module.pgdog_iam.role_arn
  description = "Share this ARN with the PgDog team"
}
```

### Custom Role Name

```hcl
module "pgdog_iam" {
  source = "github.com/pgdogdev/pgdog-iam-terraform"

  eks_cluster_name       = "my-pgdog-cluster"
  rds_database_name      = "my-pgdog-db"
  route53_hosted_zone_id = "Z02965561036BDGGGL5TJ"
  aws_region             = "us-west-2"
  role_name              = "custom-pgdog-role"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Team        = "platform"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `eks_cluster_name` | Name of the EKS cluster | `string` | - | yes |
| `rds_database_name` | Name of the RDS database instance | `string` | - | yes |
| `route53_hosted_zone_id` | Route53 hosted zone ID | `string` | - | yes |
| `aws_region` | AWS region where resources are deployed | `string` | `"us-west-2"` | no |
| `pgdog_account_id` | PgDog AWS account ID that will assume the role | `string` | `"588738614642"` | no |
| `external_id` | External ID for AssumeRole trust policy | `string` | `"32b0a5561c176331ef68fbde550397191a005ee2cbf07414922cfa85cd8d1926"` | no |
| `role_name` | Name of the IAM role to create | `string` | `"pgdog-client-hosted-role"` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `role_arn` | ARN of the IAM role (share this with PgDog team) |
| `role_name` | Name of the IAM role |
| `permission_boundary_arn` | ARN of the permission boundary policy |

## Security Features

### Permission Boundary

The module implements a permission boundary that:

- Restricts all operations to the specified AWS region
- Limits access to only the specified EKS cluster, RDS database, and Route53 zone
- Explicitly denies IAM administrative actions
- Prevents destructive KMS operations
- Blocks access to AWS Organizations, Account, and SSO services

### Trust Policy

The IAM role can only be assumed by:
- The PgDog AWS account (`588738614642` by default)
- With the correct External ID for additional security

### Least Privilege

The role policy grants only the minimum permissions needed for PgDog to:

- Access and manage the specified EKS cluster
- Control the specified RDS database
- Manage DNS records in the specified Route53 zone
- Use CloudFormation for eksctl operations

## Deployment Steps

1. Copy the module to your Terraform workspace
2. Create a `main.tf` file with the module configuration (see examples above)
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the planned changes:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```
6. Share the `role_arn` output with the PgDog team


- Terraform >= 1.0
- AWS Provider >= 4.0

## License

MIT
