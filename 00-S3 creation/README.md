# Remote State Infrastructure

This repo contains Terraform code for setting up remote state management infrastructure in AWS. 
I've kept it simple but secure - just an S3 bucket and DynamoDB table for now.

## Why These Design Choices?

### Storage Choice
Went with S3 + DynamoDB since it's the most battle-tested combo for remote state. Considered using Terraform Cloud 
but wanted to keep things in-house for better control and cost predictability.

### Security Decisions
- Using AWS managed KMS key for now to keep it simple. May want to create a custom key later
- Blocked ALL public access because there's zero reason for state files to be public
- Versioning enabled so we can roll back if something breaks
- Used separate IAM policies rather than a single combined one - makes it easier to audit

### Cost Considerations  
- DynamoDB is on-demand since state locking is infrequent
- S3 versioning might increase costs slightly but worth it for the safety net
- No lifecycle rules yet since state files are tiny - can add later if needed

### TODO / Future Improvements
- [ ] Move to customer-managed KMS key
- [ ] Add lifecycle rules to clean up old versions after X days
- [ ] Consider replication for DR
- [ ] Standardize tags across all resources
- [ ] Maybe add CloudWatch alarms for suspicious access patterns

## Usage

1. Clone this repo
2. Update terraform.tfvars with your settings
3. Run:
```
terraform init
terraform plan
terraform apply
```

4. Update your other Terraform configs to use this backend:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-bucket-name" 
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "your-table-name"
    encrypt        = true
  }
}
```
