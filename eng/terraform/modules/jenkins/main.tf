resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
  }
}

locals {
  jenkins_controller = merge(
    {
      serviceType = var.jenkins_service_type
      installPlugins = [
        "kubernetes",
        "workflow-aggregator",
        "git",
        "configuration-as-code",
        "credentials-binding",
        "ssh-agent",
        "docker-workflow"
      ]
      javaOpts = "-Xmx1024m"
      ingress = {
        enabled = false
      }
    },
    var.jenkins_admin_existing_secret != null ? {
      admin = {
        existingSecret = var.jenkins_admin_existing_secret
        userKey        = "adminUser"
        passwordKey    = "adminPassword"
      }
    } : {}
  )

  jenkins_values = {
    controller = local.jenkins_controller
    persistence = {
      enabled = var.jenkins_persistence_enabled
      size    = var.jenkins_persistence_size
    }
    agent = {
      enabled = true
    }
    rbac = {
      create = true
    }
    serviceAccount = {
      create = true
      name   = "jenkins"
    }
  }
}

resource "helm_release" "jenkins" {
  name             = var.jenkins_release_name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.jenkins_chart_version != "" ? var.jenkins_chart_version : null
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 1200

  values = [yamlencode(local.jenkins_values)]

  depends_on = [kubernetes_namespace.jenkins]
}
