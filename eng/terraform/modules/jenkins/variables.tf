variable "jenkins_namespace" {
  description = "Namespace where Jenkins will be installed"
  type        = string
}

variable "jenkins_release_name" {
  description = "Helm release name for Jenkins"
  type        = string
}

variable "jenkins_chart_version" {
  description = "Jenkins Helm chart version. Leave empty to use chart default/latest"
  type        = string
  default     = ""
}

variable "jenkins_service_type" {
  description = "Kubernetes service type for Jenkins controller service"
  type        = string
}

variable "jenkins_persistence_enabled" {
  description = "Enable persistence for Jenkins controller"
  type        = bool
}

variable "jenkins_persistence_size" {
  description = "Persistent volume size for Jenkins controller"
  type        = string
}

variable "jenkins_admin_existing_secret" {
  description = "Optional existing secret containing admin credentials"
  type        = string
  default     = null
}

variable "jenkins_additional_existing_secrets" {
  description = "Additional Kubernetes secrets to mount under /run/secrets/additional for Jenkins"
  type = list(object({
    name    = string
    keyName = string
  }))
  default = [
    {
      name    = "git-credentials"
      keyName = "id_ed25519"
    },
    {
      name    = "docker-credentials"
      keyName = ".dockerconfigjson"
    }
  ]
}
