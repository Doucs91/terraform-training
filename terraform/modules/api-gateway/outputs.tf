output "api_id" {
  description = "ID de l'API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_endpoint" {
  description = "Endpoint de l'API"
  value       = var.use_localstack ? "http://localhost:4566/restapis/${aws_api_gateway_rest_api.api.id}/${var.stage_name}/_user_request_" : aws_api_gateway_stage.stage.invoke_url
}

output "api_url" {
  description = "URL complète de l'API"
  value       = var.use_localstack ? "http://localhost:4566/restapis/${aws_api_gateway_rest_api.api.id}/${var.stage_name}/_user_request_/transactions" : "${aws_api_gateway_stage.stage.invoke_url}/transactions"
}