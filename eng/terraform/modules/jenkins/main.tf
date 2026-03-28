resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
  }
}

locals {
  jenkins_install_plugins = [
    "kubernetes",
    "workflow-aggregator",
    "git",
    "configuration-as-code",
    "credentials-binding",
    "ssh-agent",
    "docker-workflow",
    "job-dsl"
  ]

  jenkins_controller = merge(
    {
      serviceType                   = var.jenkins_service_type
      initConfigMap                 = kubernetes_config_map.jenkins_init.metadata[0].name
      installPlugins                = local.jenkins_install_plugins
      initializeOnce                = true
      installLatestPlugins          = false
      installLatestSpecifiedPlugins = false
      overwritePluginsFromImage     = true
      javaOpts = "-Xmx1024m"
      containerEnvFrom = [
        {
          secretRef = {
            name = "git-credentials"
          }
        }
      ]
      containerSecurityContext = {
        allowPrivilegeEscalation = false
        runAsUser                = 1000
        runAsGroup               = 1000
        readOnlyRootFilesystem   = false
      }
      ingress = {
        enabled = false
      }
      additionalExistingSecrets = var.jenkins_additional_existing_secrets
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

resource "kubernetes_config_map" "jenkins_init" {
  metadata {
    name      = "${var.jenkins_release_name}-init-scripts"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "apply_config.sh" = <<-SCRIPT
      set -e
      echo "disable Setup Wizard"
      echo $JENKINS_VERSION > /var/jenkins_home/jenkins.install.UpgradeWizard.state
      echo $JENKINS_VERSION > /var/jenkins_home/jenkins.install.InstallUtil.lastExecVersion
      echo "download plugins"
      cp /var/jenkins_config/plugins.txt /var/jenkins_home
      rm -rf /var/jenkins_plugins/*.lock
      jenkins-plugin-cli --verbose --war "/usr/share/jenkins/jenkins.war" --plugin-file "/var/jenkins_home/plugins.txt" --latest false -d /var/jenkins_plugins
      echo "finished initialization"
    SCRIPT
    "plugins.txt"     = join("\n", local.jenkins_install_plugins)
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

  depends_on = [kubernetes_namespace.jenkins, kubernetes_config_map.jenkins_init]
}
