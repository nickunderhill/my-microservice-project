variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Cкануванням образів"
  type        = bool
  default     = true
}
