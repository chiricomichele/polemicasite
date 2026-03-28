output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "service_name" {
  description = "Jenkins service name"
  value       = helm_release.jenkins.name
}

output "port_forward_command" {
  description = "Command to expose Jenkins UI locally"
  value       = "kubectl port-forward -n ${kubernetes_namespace.jenkins.metadata[0].name} svc/${helm_release.jenkins.name} 8080:8080"
}
