variable "cloud_provider" {
  description = "Cloud provider to use (azure or minikube)"
  type        = string
  default     = "minikube"
}

variable "azure_resource_group" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "polemicasite-rg"
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "polemicasite-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2als_v6"
}

variable "minikube_profile" {
  description = "Name of the Minikube profile"
  type        = string
  default     = "minikube"
}

variable "argocd_version" {
  description = "Version of ArgoCD Helm chart"
  type        = string
  default     = "9.4.16"
}

variable "jenkins_enabled" {
  description = "Install Jenkins using Terraform"
  type        = bool
  default     = false
}

variable "jenkins_namespace" {
  description = "Namespace where Jenkins will be installed"
  type        = string
  default     = "jenkins"
}

variable "jenkins_release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  description = "Jenkins Helm chart version. Leave empty to use chart default/latest"
  type        = string
  default     = ""
}

variable "jenkins_service_type" {
  description = "Kubernetes service type for Jenkins controller"
  type        = string
  default     = "ClusterIP"
}

variable "jenkins_persistence_enabled" {
  description = "Enable persistence for Jenkins"
  type        = bool
  default     = true
}

variable "jenkins_persistence_size" {
  description = "Persistent volume size for Jenkins"
  type        = string
  default     = "8Gi"
}

variable "jenkins_admin_existing_secret" {
  description = "Optional existing secret for Jenkins admin credentials"
  type        = string
  default     = null
}

# PostgreSQL Configuration
variable "postgresql_namespace" {
  description = "Kubernetes namespace for PostgreSQL"
  type        = string
  default     = "postgresql"
}

variable "postgresql_release_name" {
  description = "Helm release name for PostgreSQL"
  type        = string
  default     = "postgresql"
}

variable "postgresql_version" {
  description = "PostgreSQL Helm chart version"
  type        = string
  default     = "18.5.14"
}

variable "postgresql_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "polemicasite"
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgresql_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "polemicasite"
}

variable "postgresql_persistence_enabled" {
  description = "Enable persistent storage for PostgreSQL"
  type        = bool
  default     = true
}

variable "postgresql_storage_size" {
  description = "Size of PostgreSQL persistent volume"
  type        = string
  default     = "20Gi"
}

variable "postgresql_storage_class" {
  description = "Storage class for PostgreSQL persistence"
  type        = string
  default     = null
}

variable "postgresql_metrics_enabled" {
  description = "Enable PostgreSQL metrics (prometheus)"
  type        = bool
  default     = false
}

variable "postgresql_cpu_request" {
  description = "CPU request for PostgreSQL pod"
  type        = string
  default     = "250m"
}

variable "postgresql_memory_request" {
  description = "Memory request for PostgreSQL pod"
  type        = string
  default     = "256Mi"
}

variable "postgresql_cpu_limit" {
  description = "CPU limit for PostgreSQL pod"
  type        = string
  default     = "500m"
}

variable "postgresql_memory_limit" {
  description = "Memory limit for PostgreSQL pod"
  type        = string
  default     = "512Mi"
}
