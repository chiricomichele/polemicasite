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
