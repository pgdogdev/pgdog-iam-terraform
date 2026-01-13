output "role_arn" {
  description = "ARN of the IAM role created for PgDog access"
  value       = aws_iam_role.pgdog.arn
}

output "role_name" {
  description = "Name of the IAM role created for PgDog access"
  value       = aws_iam_role.pgdog.name
}

output "permission_boundary_arn" {
  description = "ARN of the permission boundary policy"
  value       = aws_iam_policy.permission_boundary.arn
}

output "external_id" {
  description = "External ID used for AssumeRole trust policy (either provided or generated)"
  value       = local.external_id
}
