# Create a namespace for Tekton Tasks
resource "kubernetes_namespace" "tekton_tasks" {
  metadata {
    name = "tekton-tasks"
  }
}

# ServiceAccount for pipeline execution
resource "kubernetes_service_account" "git_credentials_sa" {
  metadata {
    name      = "git-credentials-sa"
    namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
    annotations = {
      "tekton.dev/git-0" = "github.com"
    }
  }
  depends_on = [kubernetes_namespace.tekton_tasks]
}

# Role with minimum required permissions for Tekton pipeline
resource "kubernetes_role" "tekton_pipeline_runner" {
  metadata {
    name      = "tekton-pipeline-runner"
    namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
  }

  # Read secrets (git-credentials, docker-credentials)
  rule {
    api_groups = [""]
    resources  = ["secrets", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  # Manage pods created by Tekton tasks
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch"]
  }

  # PersistentVolumeClaims for workspaces
  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  # Tekton resources
  rule {
    api_groups = ["tekton.dev"]
    resources  = ["tasks", "taskruns", "pipelines", "pipelineruns"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["tekton.dev"]
    resources  = ["taskruns/status", "pipelineruns/status"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }

  depends_on = [kubernetes_namespace.tekton_tasks]
}

# RoleBinding: assign the Role to the ServiceAccount
resource "kubernetes_role_binding" "tekton_pipeline_runner_binding" {
  metadata {
    name      = "tekton-pipeline-runner-binding"
    namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tekton_pipeline_runner.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.git_credentials_sa.metadata[0].name
    namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
  }
  depends_on = [kubernetes_service_account.git_credentials_sa, kubernetes_role.tekton_pipeline_runner]
}

# Fetch the Tekton git-clone task YAML from the remote URL
data "http" "tekton_git_clone_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml"
}

resource "kubectl_manifest" "tekton_git_clone_task" {
  yaml_body          = data.http.tekton_git_clone_task.response_body
  override_namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
}

# Fetch the Tekton buildah task YAML from the remote URL
data "http" "tekton_buildah_task" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildah/0.9/buildah.yaml"
}

resource "kubectl_manifest" "tekton_buildah_task" {
  yaml_body          = data.http.tekton_buildah_task.response_body
  override_namespace = kubernetes_namespace.tekton_tasks.metadata[0].name
}