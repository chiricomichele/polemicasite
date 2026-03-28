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

variable "jenkins_pipeline_job_name" {
  description = "Name of the Jenkins release pipeline job"
  type        = string
}

variable "jenkins_pipeline_repo_url" {
  description = "Git repository URL used by the Jenkins release pipeline"
  type        = string
}

variable "jenkins_pipeline_branch" {
  description = "Default Git branch used by the Jenkins release pipeline"
  type        = string
}

variable "jenkins_pipeline_script_path" {
  description = "Path to the Jenkinsfile inside the repository"
  type        = string
}

variable "jenkins_image_base" {
  description = "Default image repository used by the Jenkins release pipeline"
  type        = string
}

variable "jenkins_git_credentials_id" {
  description = "Credential ID used by Jenkins for Git SSH authentication"
  type        = string
}

variable "jenkins_dockerhub_credentials_id" {
  description = "Credential ID used by Jenkins for Docker Hub authentication"
  type        = string
}

variable "jenkins_git_ssh_username" {
  description = "SSH username stored in Jenkins Git credentials"
  type        = string
}

variable "jenkins_git_ssh_private_key" {
  description = "Optional Git SSH private key to inject into Jenkins credentials via Terraform"
  type        = string
  default     = null
  sensitive   = true
}

variable "jenkins_dockerhub_username" {
  description = "Optional Docker Hub username to inject into Jenkins credentials via Terraform"
  type        = string
  default     = null
  sensitive   = true
}

variable "jenkins_dockerhub_password" {
  description = "Optional Docker Hub password or token to inject into Jenkins credentials via Terraform"
  type        = string
  default     = null
  sensitive   = true
}
