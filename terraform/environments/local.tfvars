# Configuration pour environnement local avec LocalStack

environment     = "local"
aws_region      = "ca-central-1"
use_localstack  = true

tags = {
  Project     = "MCP-FCC-Banking"
  Environment = "local"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}