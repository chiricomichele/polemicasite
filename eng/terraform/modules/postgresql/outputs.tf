output "postgresql_host" {
  description = "PostgreSQL service hostname"
  value       = "${helm_release.postgresql.name}.${helm_release.postgresql.namespace}.svc.cluster.local"
}

output "postgresql_port" {
  description = "PostgreSQL service port"
  value       = 5432
}

output "postgresql_database" {
  description = "PostgreSQL database name"
  value       = var.postgresql_database
}

output "postgresql_username" {
  description = "PostgreSQL username"
  value       = var.postgresql_username
  sensitive   = true
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgresql_username}:${var.postgresql_password}@${helm_release.postgresql.name}.${helm_release.postgresql.namespace}.svc.cluster.local:5432/${var.postgresql_database}"
  sensitive   = true
}

output "postgresql_namespace" {
  description = "Kubernetes namespace where PostgreSQL is deployed"
  value       = kubernetes_namespace.postgresql.metadata[0].name
}
