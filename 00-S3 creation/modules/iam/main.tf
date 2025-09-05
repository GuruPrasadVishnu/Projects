# Read-only policy for terraform state
# Splitting read/write access for better security control
resource "aws_iam_policy" "terraform_state_read" {
  name = "terraform-state-read-only"
  
  # Had to look up exact permissions needed through trial and error
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.table_name}"
      }
    ]
  })
}

# Full access policy for terraform state management
resource "aws_iam_policy" "terraform_state_write" {
  name = "terraform-state-full-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.table_name}"
      }
    ]
  })
}
