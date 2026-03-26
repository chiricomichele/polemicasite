terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Create namespace for PostgreSQL
resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = var.postgresql_namespace
    labels = {
      "app.kubernetes.io/name" = "postgresql"
    }
  }
}

# Deploy PostgreSQL using Helm
resource "helm_release" "postgresql" {
  name             = var.postgresql_release_name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  namespace        = kubernetes_namespace.postgresql.metadata[0].name
  version          = var.postgresql_version
  create_namespace = false

  values = [
    yamlencode({
      auth = {
        username = var.postgresql_username
        password = var.postgresql_password
        database = var.postgresql_database
      }

      primary = {
        persistence = {
          enabled      = var.postgresql_persistence_enabled
          size         = var.postgresql_storage_size
          storageClass = var.postgresql_storage_class
        }

        resources = {
          requests = {
            cpu    = var.postgresql_cpu_request
            memory = var.postgresql_memory_request
          }
          limits = {
            cpu    = var.postgresql_cpu_limit
            memory = var.postgresql_memory_limit
          }
        }
      }

      metrics = {
        enabled = var.postgresql_metrics_enabled
      }
    })
  ]

  depends_on = [kubernetes_namespace.postgresql]
}
