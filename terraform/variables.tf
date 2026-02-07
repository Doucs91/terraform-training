# Variables globales du projet

variable "project_name" {
  description = "Mcp-Fcc-Banking"
  type        = string
  default     = "mcp-fcc-banking"
}

variable "environment" {
  description = "Environnement (local, dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "ca-central-1"
}

variable "use_localstack" {
  description = "Utiliser LocalStack au lieu d'AWS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags communs pour toutes les ressources"
  type        = map(string)
  default     = {}
}