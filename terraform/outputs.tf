# Outputs - Valeurs à afficher après le déploiement

output "test_bucket_name" {
  description = "Nom du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.id
}

output "test_bucket_arn" {
  description = "ARN du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.arn
}

output "environment" {
  description = "Environnement déployé"
  value       = var.environment
}

output "region" {
  description = "Région AWS utilisée"
  value       = var.aws_region
}