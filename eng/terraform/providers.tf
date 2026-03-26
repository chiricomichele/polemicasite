# provider.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = var.cloud_provider == "azure" ? "~/.kube/config" : "~/.kube/config"
}

provider "kubectl" {
  config_path = var.cloud_provider == "azure" ? "~/.kube/config" : "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = var.cloud_provider == "azure" ? "~/.kube/config" : "~/.kube/config"
  }
}