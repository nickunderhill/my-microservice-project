variable "release_name" {
  type        = string
  default     = "kube-prometheus-stack"
  description = "Helm release name"
}

variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Kubernetes namespace for monitoring stack"
}

variable "chart_version" {
  type        = string
  default     = "55.5.0"
  description = "Helm chart version"
}