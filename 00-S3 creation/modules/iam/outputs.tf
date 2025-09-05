output "read_policy_arn" {
  description = "ARN of the read-only IAM policy for Terraform state"
  value       = aws_iam_policy.terraform_state_read.arn
}

output "write_policy_arn" {
  description = "ARN of the full-access IAM policy for Terraform state"
  value       = aws_iam_policy.terraform_state_write.arn
}
