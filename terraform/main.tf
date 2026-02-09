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
#resource "random_id" "suffix" {
#  byte_length = 4
#}

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

# Module SQS: Transactions Queue
module "transactions_queue" {
  source = "./modules/sqs"

  queue_name                 = "${var.project_name}-transactions-${var.environment}"
  visibility_timeout_seconds = 60  # 2x le timeout de la Lambda
  max_receive_count          = 3
  enable_dlq                 = true

  tags = var.tags
}

# Module Lambda: Process Transaction
module "process_transaction_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-process-transaction-${var.environment}"
  description   = "Process transactions from SQS queue"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  source_file = "../dist/lambdas/process-transaction.zip"

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
  }

  # Permissions pour lire depuis SQS
  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = module.transactions_queue.queue_arn
    }
  ]

  tags = var.tags
}

# Event Source Mapping: SQS → Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = module.transactions_queue.queue_arn
  function_name    = module.process_transaction_lambda.function_name
  batch_size       = 10
  enabled          = true

  # Scaling configuration
  scaling_config {
    maximum_concurrency = 10
  }

  depends_on = [
    module.transactions_queue,
    module.process_transaction_lambda
  ]
}