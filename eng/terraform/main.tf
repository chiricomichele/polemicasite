# main.tf

module "aks_cluster" {
  source = "./modules/aks"
  count  = var.cloud_provider == "azure" ? 1 : 0

  azure_resource_group = var.azure_resource_group
  azure_location       = var.azure_location
  aks_cluster_name     = var.aks_cluster_name
  aks_node_count       = var.aks_node_count
  aks_node_vm_size     = var.aks_node_vm_size
}

module "minikube_cluster" {
  source = "./modules/minikube"
  count  = var.cloud_provider == "minikube" ? 1 : 0

  minikube_profile = var.minikube_profile

  providers = {
    kubernetes = kubernetes
  }
}

module "tekton" {
  source                   = "./modules/tekton"
  depends_on               = [module.aks_cluster, module.minikube_cluster]
  tekton_version           = var.tekton_version
  tekton_dashboard_version = var.tekton_dashboard_version
}

module "tekton-tasks" {
  source     = "./modules/tekton-tasks"
  depends_on = [module.tekton]

  providers = {
    kubectl = kubectl
  }
}

module "argocd" {
  source         = "./modules/argocd"
  depends_on     = [module.aks_cluster, module.minikube_cluster]
  argocd_version = var.argocd_version
}

module "postgresql" {
  source     = "./modules/postgresql"
  depends_on = [module.aks_cluster, module.minikube_cluster]

  postgresql_namespace           = var.postgresql_namespace
  postgresql_release_name        = var.postgresql_release_name
  postgresql_version             = var.postgresql_version
  postgresql_username            = var.postgresql_username
  postgresql_password            = var.postgresql_password
  postgresql_database            = var.postgresql_database
  postgresql_persistence_enabled = var.postgresql_persistence_enabled
  postgresql_storage_size        = var.postgresql_storage_size
  postgresql_storage_class       = var.postgresql_storage_class
  postgresql_metrics_enabled     = var.postgresql_metrics_enabled
  postgresql_cpu_request         = var.postgresql_cpu_request
  postgresql_memory_request      = var.postgresql_memory_request
  postgresql_cpu_limit           = var.postgresql_cpu_limit
  postgresql_memory_limit        = var.postgresql_memory_limit
}

output "kubeconfig" {
  value     = var.cloud_provider == "azure" ? module.aks_cluster[0].kubeconfig : module.minikube_cluster[0].kubeconfig
  sensitive = true
}

output "postgresql_connection" {
  description = "PostgreSQL connection details"
  value = {
    host              = module.postgresql.postgresql_host
    port              = module.postgresql.postgresql_port
    database          = module.postgresql.postgresql_database
    username          = module.postgresql.postgresql_username
    connection_string = module.postgresql.postgresql_connection_string
  }
  sensitive = true
}