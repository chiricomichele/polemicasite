variable "azure_resource_group" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
}