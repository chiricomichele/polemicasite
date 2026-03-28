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

  jenkins_git_credentials_enabled       = try(trimspace(var.jenkins_git_ssh_private_key) != "", false)
  jenkins_dockerhub_credentials_enabled = try(trimspace(var.jenkins_dockerhub_username) != "", false) && try(trimspace(var.jenkins_dockerhub_password) != "", false)

  jenkins_additional_secrets = concat(
    local.jenkins_git_credentials_enabled ? [
      {
        name  = "jenkins-git-ssh-private-key"
        value = var.jenkins_git_ssh_private_key
      }
    ] : [],
    local.jenkins_dockerhub_credentials_enabled ? [
      {
        name  = "jenkins-dockerhub-username"
        value = var.jenkins_dockerhub_username
      },
      {
        name  = "jenkins-dockerhub-password"
        value = var.jenkins_dockerhub_password
      }
    ] : []
  )

  jenkins_managed_credentials = concat(
    local.jenkins_git_credentials_enabled ? [
      {
        basicSSHUserPrivateKey = {
          scope       = "GLOBAL"
          id          = var.jenkins_git_credentials_id
          username    = var.jenkins_git_ssh_username
          description = "Git SSH private key managed by Terraform"
          privateKeySource = {
            directEntry = {
              privateKey = "$${jenkins-git-ssh-private-key}"
            }
          }
        }
      }
    ] : [],
    local.jenkins_dockerhub_credentials_enabled ? [
      {
        usernamePassword = {
          scope       = "GLOBAL"
          id          = var.jenkins_dockerhub_credentials_id
          username    = "$${jenkins-dockerhub-username}"
          password    = "$${jenkins-dockerhub-password}"
          description = "Docker Hub credentials managed by Terraform"
        }
      }
    ] : []
  )

  jenkins_jcasc_config_scripts = merge(
    {
      "welcome-message" = <<-YAML
        jenkins:
          systemMessage: "Jenkins is managed by Terraform and Configuration as Code for Polemica Site."
      YAML
      "release-job"     = <<-YAML
        jobs:
          - script: >
              pipelineJob('${var.jenkins_pipeline_job_name}') {
                description('Managed by Terraform and Jenkins Configuration as Code.')
                definition {
                  cpsScm {
                    lightweight(false)
                    scm {
                      git {
                        remote {
                          url('${var.jenkins_pipeline_repo_url}')
                          credentials('${var.jenkins_git_credentials_id}')
                        }
                        branch('*/${var.jenkins_pipeline_branch}')
                      }
                    }
                    scriptPath('${var.jenkins_pipeline_script_path}')
                  }
                }
                properties {
                  disableConcurrentBuilds()
                }
                parameters {
                  stringParam('GIT_BRANCH', '${var.jenkins_pipeline_branch}', 'Branch to build and update')
                  stringParam('REPO_URL', '${var.jenkins_pipeline_repo_url}', 'Git repository URL')
                  stringParam('IMAGE_BASE', '${var.jenkins_image_base}', 'Docker image repository')
                  stringParam('DOCKERFILE_PATH', './Dockerfile', 'Path to Dockerfile')
                  stringParam('DEPLOYMENT_PATH', 'eng/k8s/deployment-webapp.yaml', 'Path to deployment manifest')
                }
              }
      YAML
    },
    length(local.jenkins_managed_credentials) > 0 ? {
      "managed-credentials" = yamlencode({
        credentials = {
          system = {
            domainCredentials = [
              {
                credentials = local.jenkins_managed_credentials
              }
            ]
          }
        }
      })
    } : {}
  )

  jenkins_controller = merge(
    {
      serviceType                   = var.jenkins_service_type
      initConfigMap                 = kubernetes_config_map.jenkins_init.metadata[0].name
      installPlugins                = local.jenkins_install_plugins
      additionalSecrets             = local.jenkins_additional_secrets
      initializeOnce                = true
      installLatestPlugins          = false
      installLatestSpecifiedPlugins = false
      overwritePluginsFromImage     = false
      JCasC = {
        overwriteConfiguration = true
        configScripts          = local.jenkins_jcasc_config_scripts
      }
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
