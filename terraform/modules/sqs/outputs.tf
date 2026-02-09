output "queue_id" {
  description = "ID de la queue"
  value       = aws_sqs_queue.queue.id
}

output "queue_arn" {
  description = "ARN de la queue"
  value       = aws_sqs_queue.queue.arn
}

output "queue_url" {
  description = "URL de la queue"
  value       = aws_sqs_queue.queue.url
}

output "dlq_arn" {
  description = "ARN de la DLQ (si activée)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "URL de la DLQ (si activée)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}
