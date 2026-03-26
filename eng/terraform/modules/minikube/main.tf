# modules/minikube/main.tf

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = "minikube start"
  }
}

output "kubeconfig" {
  value = "~/.kube/config"
}