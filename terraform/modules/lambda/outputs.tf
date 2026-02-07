# Outputs du module Lambda

output "function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = "ARN d'invocation de la fonction"
  value       = aws_lambda_function.function.invoke_arn
}

output "function_role_arn" {
  description = "ARN du rôle IAM de la fonction"
  value       = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  description = "Nom du CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}