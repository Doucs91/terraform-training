# Configuration principale du projet

# Resource de test: un bucket S3 simple
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-test-bucket-${var.environment}"

  tags = merge(
    var.tags,
    {
      Name        = "Test Bucket"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Random ID pour rendre les noms uniques
resource "random_id" "suffix" {
  byte_length = 4
}