variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "namespace" {
  description = "Назва простору імен Kubernetes для Jenkins"
  type        = string
  default     = "jenkins"
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера для IRSA"
  type        = string

}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера для IRSA"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_user" {
  description = "GitHub username"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch for Jenkins"
  type        = string
}