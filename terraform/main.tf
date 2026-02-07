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

# Module Lambda: Hello World
module "hello_world_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-hello-world-${var.environment}"
  description   = "Lambda de test Hello World"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  source_file = "../dist/lambdas/hello-world.zip"

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
    LOG_LEVEL   = "INFO"
  }

  tags = var.tags
}