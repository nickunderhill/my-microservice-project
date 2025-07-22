variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_user" {
  description = "GitHub username"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}