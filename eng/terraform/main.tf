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

module "jenkins" {
  source     = "./modules/jenkins"
  count      = var.jenkins_enabled ? 1 : 0
  depends_on = [module.aks_cluster, module.minikube_cluster]

  jenkins_namespace                = var.jenkins_namespace
  jenkins_release_name             = var.jenkins_release_name
  jenkins_chart_version            = var.jenkins_chart_version
  jenkins_service_type             = var.jenkins_service_type
  jenkins_persistence_enabled      = var.jenkins_persistence_enabled
  jenkins_persistence_size         = var.jenkins_persistence_size
  jenkins_admin_existing_secret    = var.jenkins_admin_existing_secret
  jenkins_pipeline_job_name        = var.jenkins_pipeline_job_name
  jenkins_pipeline_repo_url        = var.jenkins_pipeline_repo_url
  jenkins_pipeline_branch          = var.jenkins_pipeline_branch
  jenkins_pipeline_script_path     = var.jenkins_pipeline_script_path
  jenkins_image_base               = var.jenkins_image_base
  jenkins_git_credentials_id       = var.jenkins_git_credentials_id
  jenkins_dockerhub_credentials_id = var.jenkins_dockerhub_credentials_id
  jenkins_git_ssh_username         = var.jenkins_git_ssh_username
  jenkins_git_ssh_private_key      = var.jenkins_git_ssh_private_key
  jenkins_dockerhub_username       = var.jenkins_dockerhub_username
  jenkins_dockerhub_password       = var.jenkins_dockerhub_password
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

output "jenkins_info" {
  description = "Jenkins release information (null when Jenkins is disabled)"
  value = var.jenkins_enabled ? {
    namespace            = module.jenkins[0].namespace
    release_name         = module.jenkins[0].release_name
    service_name         = module.jenkins[0].service_name
    port_forward_command = module.jenkins[0].port_forward_command
  } : null
}