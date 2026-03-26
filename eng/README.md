# Engineering Manifests

Questa cartella contiene i manifest Kubernetes, ArgoCD, Tekton e i moduli Terraform per il deploy self-hosted di Polemica League.

⚠️ **Nessuna credenziale va committata** in questa cartella. Chiavi SSH, password e token vanno gestiti tramite Kubernetes secrets o secret manager esterni.

📚 **Documentazione completa**: [docs/12-infrastruttura-k8s.md](../docs/12-infrastruttura-k8s.md)

## Struttura

```
eng/
├── argocd/          # ArgoCD Application + Repository secret
├── k8s/             # Manifest Kubernetes (Namespace, Deployment, Service, RBAC)
├── tekton/          # Pipeline, Tasks, PipelineRun
└── terraform/       # Moduli IaC (AKS, Minikube, Tekton, ArgoCD, PostgreSQL)
```

## Quick Reference

```bash
# Provisioning cluster
terraform apply -var-file=terraform.tfvars.azure    # Azure
terraform apply -var-file=terraform.tfvars.minikube # Minikube

# Deploy Tekton tasks + pipeline (primo setup)
kubectl apply -f eng/tekton/task-compute-semver.yaml
kubectl apply -f eng/tekton/task-update-deployment.yaml
kubectl apply -f eng/tekton/task-git-tag-push.yaml
kubectl apply -f eng/tekton/pipeline.yaml

# Setup ArgoCD
kubectl apply -f eng/argocd/repositories.yaml
kubectl apply -f eng/argocd/application.yaml

# Lanciare una release
kubectl create -f eng/tekton/pipeline-run.yaml
```


## Avvertenze Critiche

⚠️ **Repository PRIVATO**: `polemicaleague-source/polemicasite` è privato su GitHub.

- **ArgoCD** e **Tekton** richiedono una **deploy key SSH valida** per clonare il repo.
- Senza la chiave SSH, il deployment fallirà con errori di autenticazione.
- Vedi [SSH-SETUP.md](SSH-SETUP.md) per **generare, aggiungere e iniettare** la chiave nel cluster.

⚠️ **MAI committare** stringhe di credenziali, chiavi private, o token nel repository.

---

- Nessuna chiave privata o token reale è presente nei manifest.
- Argo CD e Tekton usano autenticazione SSH (URL placeholder `ssh://git@github.com/<org>/<repo>.git`).
- La chiave SSH privata va gestita **fuori da git** (CI, secret manager, o manuale via kubectl).
  - Vedi [SSH-SETUP.md](SSH-SETUP.md) per istruzioni.
- Deployment web con hardening base:
  - `runAsNonRoot`
  - `seccompProfile: RuntimeDefault`
  - `allowPrivilegeEscalation: false`
  - `readOnlyRootFilesystem: true`
  - drop di tutte le capabilities Linux
  - resource requests/limits
- Namespace dedicato in `eng/k8s/namespace.yaml`.

## Terraform

- **Dualità Azure/Minikube**: sceglie provider in base a `cloud_provider` var
- **Rimossi**: Prometheus, Grafana, OpenTelemetry
- **Mantenuti**: Tekton, ArgoCD, AKS, Minikube
- **Aggiunto**: PostgreSQL (Bitnami Helm chart)

### Moduli disponibili

- `aks/` - Azure Kubernetes Service cluster
- `minikube/` - Minikube local cluster
- `tekton/` - Tekton Pipelines (CI/CD)
- `argocd/` - ArgoCD GitOps
- `postgresql/` - PostgreSQL relational database

### PostgreSQL

PostgreSQL è deployato via Helm chart (Bitnami) nel namespace `postgresql` di default.

**Configurazione in tfvars**:
```hcl
postgresql_password          = "your-secure-password-here"  # MUST CHANGE
postgresql_storage_size      = "20Gi"                       # Persistent volume size
postgresql_persistence_enabled = true                       # Use persistent storage
postgresql_database          = "polemicasite"               # Default database name
```

**Connection string** (esposto in `terraform outputs`):
```
postgresql://polemicasite:password@postgresql.postgresql.svc.cluster.local:5432/polemicasite
```

Accessi dal pod Web tramite hostname `postgresql.postgresql.svc.cluster.local` (Kubernetes DNS).

### Variabili e defaults

- `azure_resource_group` (default: `polemicasite-rg`)
- `aks_cluster_name` (default: `polemicasite-aks`)
- `postgresql_password` (**CHANGE THIS** - required, marked as sensitive)
- ecc

Usa: `terraform apply -var-file=terraform.tfvars.azure` o `.minikube`

## Release Workflow Completo

Questo progetto implementa un **CI/CD completo** per deploy automatico:

```
User: manuale quando pronto
  ↓
Lancia PipelineRun con versione (es. v1.0.0)
  ↓
Tekton Pipeline:
  1. Clone repo
  2. Build immagine Docker: michelechirico/polemicasite:v1.0.0
  3. Push a DockerHub
  4. Aggiorna deployment-webapp.yaml con nuovo tag
  5. Git commit + push a main
  6. Crea git tag v1.0.0 e pushes
  ↓
ArgoCD monitora main branch
  ↓
ArgoCD sincronizza automaticamente il deployment
  ↓
K8s aggiorna il Deployment con nuova immagine
```

**Dettagli**: vedi [RELEASE-WORKFLOW.md](RELEASE-WORKFLOW.md)

### Configurazione Tekton

La pipeline è **manuale** (niente webhook):

1. Modifica `eng/tekton/pipeline-run.yaml` con la versione desiderata
2. Lancia: `kubectl apply -f eng/tekton/pipeline-run.yaml -n tekton-tasks`
3. Monitora i log della pipeline
4. Pipeline auto-aggiorna manifest e crea git tag
5. ArgoCD sincronizza automaticamente

**Deploy richiesti (nell'ordine):**
```bash
kubectl apply -f eng/tekton/task-update-deployment.yaml
kubectl apply -f eng/tekton/task-git-tag-push.yaml
kubectl apply -f eng/tekton/pipeline.yaml
```
Secrets necessari nel namespace `tekton-tasks`: SSH (`git-credentials`) e Docker (`docker-credentials`)

Dettagli: [RELEASE-WORKFLOW.md](RELEASE-WORKFLOW.md)

### Configurazione ArgoCD

ArgoCD sincronizza automaticamente i manifest da GitHub a Kubernetes:

```bash
# Crea secret SSH per repo privato
kubectl create secret generic polemicasite-repo \
  --from-file=ssh-privatekey=deploy_key \
  -n argocd

# Apply la Repository Secret
kubectl apply -f eng/argocd/repositories.yaml -n argocd

# Apply l'Application
kubectl apply -f eng/argocd/application.yaml -n argocd
```

**Sync Policy**: Automatico con `selfHeal: true` e `prune: true`
- Se qualcuno modifica K8s manualmente, ArgoCD ripristina dallo git
- Se un file è eliminato da git, ArgoCD elimina la risorsa da K8s

Dettagli: [ARGOCD-SETUP.md](ARGOCD-SETUP.md)

## Tekton - Auto-trigger su GitHub Push

La pipeline Tekton è configurata per **auto-triggerarsi** al push nel branch `main` quando vengono modificati file rilevanti alla build:

**File che triggerano la pipeline:**
- `Dockerfile`, `package.json`, `.dockerignore`
- Qualsiasi file in `src/`
- `tsconfig.json`, `vite.config.ts`

**Come funziona:**
1. GitHub invia webhook push al Tekton EventListener
2. EventListener filtra su `main` branch + file rilevanti
3. Se match, crea un nuovo PipelineRun
4. Pipeline clona il repo, buildera l'immagine Docker, pushera a DockerHub

**Setup richiesto:**
- Crea GitHub webhook secret: `kubectl create secret generic github-webhook-secret ...`
- Applicare Tekton Trigger manifests: `kubectl apply -f eng/tekton/trigger-*.yaml`
- Configurare webhook in GitHub repo settings (vedi [WEBHOOK-SETUP.md](WEBHOOK-SETUP.md))

Dettagli completi: [WEBHOOK-SETUP.md](WEBHOOK-SETUP.md)

## Da personalizzare PRIMA di deploy

- `eng/argocd/application.yaml`
  - `spec.source.repoURL`
  - `spec.destination.namespace` (se diversa da `polemicasite`)
- `eng/argocd/repositories.yaml`
  - `stringData.url` (to your actual repo SSH URL)
  - `stringData.sshPrivateKey` (generate & inject via secret manager, non committare)
- `eng/k8s/deployment-webapp.yaml`
  - Image già impostata a `michelechirico/polemicasite:latest` (DockerHub)
- `eng/tekton/pipeline-run.yaml`
  - `params.repo-url` (to your actual SSH repo URL)
  - `params.web-reference-image` già impostato a `michelechirico/polemicasite:latest` (DockerHub)

## Cosa NON è implementato (da valutare)

- **Container registry auth**: imagePullSecrets per registri privati (quando decidi il registry)
- **Ingress/External exposure**: servizi rimangono ClusterIP
- **RBAC/NetworkPolicy**: security policies specifiche del cluster
- **Monitoring/Alerting vero**: rimosso dalla baseline, puoi aggiungere Prometheus+Grafana+OpenTelemetry se servono

## Note

- ArgoCD e Tekton hanno bisogno della chiave SSH privata gestionata via CI o secret manager.
- I file erano adattati da un vecchio repository e sono stati sanitizzati.
- Gli artefatti locali Terraform (`.terraform/`, `terraform.tfstate*`) sono ignorati in `.gitignore`.
