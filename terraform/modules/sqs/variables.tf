variable "queue_name" {
  description = "Nom de la queue SQS"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Timeout de visibilité (doit être >= au timeout de la Lambda)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Durée de rétention des messages (4 jours par défaut)"
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Nombre max de tentatives avant DLQ"
  type        = number
  default     = 3
}

variable "delay_seconds" {
  description = "Délai avant que le message soit visible"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time"
  type        = number
  default     = 10
}

variable "enable_dlq" {
  description = "Activer la Dead Letter Queue"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}