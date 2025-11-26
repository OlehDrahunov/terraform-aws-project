resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  
  lifecycle {
    prevent_destroy = true  
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "terraform-state-bucket"
      Purpose     = "Terraform State Storage"
      Environment = var.environment
    }
  )
}


resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "terraform-state-lock"
      Purpose     = "Terraform State Locking"
      Environment = var.environment
    }
  )
}


data "aws_caller_identity" "current" {}


output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_lock_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}