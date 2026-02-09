variable "api_name" {
  description = "Nom de l'API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description de l'API"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "Stage de déploiement (dev, prod, etc.)"
  type        = string
  default     = "api"
}

variable "lambda_invoke_arn" {
  description = "ARN d'invocation de la Lambda backend"
  type        = string
}

variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "use_localstack" {
  description = "Utiliser LocalStack au lieu d'AWS"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}