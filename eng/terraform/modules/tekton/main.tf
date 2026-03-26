terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

locals {
  tekton_dashboard_release_url = "https://infra.tekton.dev/tekton-releases/dashboard/previous/${var.tekton_dashboard_version}/release-full.yaml"
}

# Explicitly create the namespace with Helm labels and annotations
resource "kubernetes_namespace" "tekton_pipelines" {
  metadata {
    name = "tekton-pipelines"

    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }

    annotations = {
      "meta.helm.sh/release-name"      = "tekton-pipelines"
      "meta.helm.sh/release-namespace" = "tekton-pipelines"
    }
  }
}

# Tekton Pipelines Helm release
resource "helm_release" "tekton_pipelines" {
  atomic     = true
  name       = "tekton-pipelines"
  repository = "https://cdfoundation.github.io/tekton-helm-chart/"
  chart      = "tekton-pipeline"
  namespace  = kubernetes_namespace.tekton_pipelines.metadata[0].name
  version    = var.tekton_version
}

# Download official Tekton Dashboard release manifest from upstream releases.
data "http" "tekton_dashboard_release" {
  url = local.tekton_dashboard_release_url
}

# Split multi-document YAML into individual manifests consumable by kubectl provider.
data "kubectl_file_documents" "tekton_dashboard_release" {
  content = data.http.tekton_dashboard_release.response_body
}

# Install Tekton Dashboard from the official release manifest.
resource "kubectl_manifest" "tekton_dashboard" {
  for_each  = data.kubectl_file_documents.tekton_dashboard_release.manifests
  yaml_body = each.value

  depends_on = [helm_release.tekton_pipelines]
}