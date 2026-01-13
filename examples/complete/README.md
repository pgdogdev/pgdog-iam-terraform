# Complete Example

This example demonstrates a complete deployment of the PgDog IAM module.

## Usage

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:
   - `eks_cluster_name`: Your EKS cluster name
   - `rds_database_name`: Your RDS database instance name
   - `route53_hosted_zone_id`: Your Route53 hosted zone ID
   - `aws_region`: Your AWS region

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

6. Share the output `pgdog_role_arn` with the PgDog team

## Cleanup

To remove all resources:
```bash
terraform destroy
```
