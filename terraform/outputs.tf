# Outputs - Valeurs à afficher après le déploiement

output "test_bucket_name" {
  description = "Nom du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.id
}

output "test_bucket_arn" {
  description = "ARN du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.arn
}

output "hello_world_lambda_name" {
  description = "Nom de la Lambda Hello World"
  value       = module.hello_world_lambda.function_name
}

output "hello_world_lambda_arn" {
  description = "ARN de la Lambda Hello World"
  value       = module.hello_world_lambda.function_arn
}

output "environment" {
  description = "Environnement déployé"
  value       = var.environment
}

output "region" {
  description = "Région AWS utilisée"
  value       = var.aws_region
}