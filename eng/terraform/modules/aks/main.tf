resource "azurerm_resource_group" "main" {
  name     = var.azure_resource_group
  location = var.azure_location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-dns"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}