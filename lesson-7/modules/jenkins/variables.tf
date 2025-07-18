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