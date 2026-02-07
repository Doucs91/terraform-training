# Variables d'entrée du module Lambda

variable "function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "description" {
  description = "Description de la fonction"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Handler de la fonction (ex: index.handler)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime Lambda (ex: nodejs20.x)"
  type        = string
  default     = "nodejs20.x"
}

variable "timeout" {
  description = "Timeout en secondes"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Mémoire allouée en MB"
  type        = number
  default     = 256
}

variable "source_file" {
  description = "Chemin vers le fichier ZIP de la Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Variables d'environnement"
  type        = map(string)
  default     = {}
}

variable "iam_policy_statements" {
  description = "Statements IAM additionnels pour la Lambda"
  type        = any
  default     = []
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}