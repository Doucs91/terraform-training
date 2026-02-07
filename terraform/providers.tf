# Configuration du provider AWS pour LocalStack
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Configuration LocalStack
  # Ces paramètres sont ignorés si use_localstack = false
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # Endpoints LocalStack
  endpoints {
    apigateway     = var.use_localstack ? "http://localhost:4566" : null
    cloudformation = var.use_localstack ? "http://localhost:4566" : null
    cloudwatch     = var.use_localstack ? "http://localhost:4566" : null
    cloudwatchlogs = var.use_localstack ? "http://localhost:4566" : null
    dynamodb       = var.use_localstack ? "http://localhost:4566" : null
    ec2            = var.use_localstack ? "http://localhost:4566" : null
    iam            = var.use_localstack ? "http://localhost:4566" : null
    lambda         = var.use_localstack ? "http://localhost:4566" : null
    s3             = var.use_localstack ? "http://s3.localhost.localstack.cloud:4566" : null
    sqs            = var.use_localstack ? "http://localhost:4566" : null
    stepfunctions  = var.use_localstack ? "http://localhost:4566" : null
    sts            = var.use_localstack ? "http://localhost:4566" : null
  }

  # IMPORTANT: Force path-style pour S3 avec LocalStack
  s3_use_path_style           = var.use_localstack
  
  # Credentials fake pour LocalStack
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
}