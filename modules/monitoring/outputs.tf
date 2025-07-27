output "grafana_service_name" {
  value       = helm_release.kube_prometheus_stack.name
  description = "Grafana release name (used to construct service name)"
}