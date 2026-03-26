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
  atomic           = true
  name             = "tekton-pipelines"
  repository       = "https://cdfoundation.github.io/tekton-helm-chart/"
  chart            = "tekton-pipeline"
  namespace        = kubernetes_namespace.tekton_pipelines.metadata[0].name
  version          = var.tekton_version
}

# Tekton Dashboard Helm release
resource "helm_release" "tekton_dashboard" {
  atomic           = true
  name             = "tekton-dashboard"
  repository       = "https://jenkins-x.github.io/tekton-dashboard-helm-chart/"
  chart            = "tekton-dashboard"
  namespace        = kubernetes_namespace.tekton_pipelines.metadata[0].name
  version          = var.tekton_dashboard_version
}