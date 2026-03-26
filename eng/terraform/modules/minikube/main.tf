# modules/minikube/main.tf

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Start Minikube with the given profile and wait until it's ready.
# Prerequisito: minikube deve essere installato sulla macchina locale.
resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = <<-EOT
      minikube start --profile=${var.minikube_profile} --driver=docker --memory=4096 --cpus=2
      minikube update-context --profile=${var.minikube_profile}
      kubectl wait --for=condition=ready node --all --timeout=120s
    EOT
  }

  triggers = {
    # Ri-esegue solo se cambia il profilo
    profile = var.minikube_profile
  }
}

output "kubeconfig" {
  value      = "~/.kube/config"
  depends_on = [null_resource.minikube_start]
}