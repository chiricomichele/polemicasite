# Infrastruttura Kubernetes

## 📋 Indice

1. [Panoramica](#panoramica)
2. [Terraform - Provisioning Cluster](#terraform---provisioning-cluster)
3. [PostgreSQL](#postgresql)
4. [Tekton - CI Pipeline](#tekton---ci-pipeline)
5. [ArgoCD - GitOps CD](#argocd---gitops-cd)
6. [Release Workflow](#release-workflow)
7. [SSH Deploy Key Setup](#ssh-deploy-key-setup)
8. [Checklist di Deploy](#checklist-di-deploy)
9. [Struttura File](#struttura-file)

---

## Panoramica

Il deployment self-hosted di Polemica League usa uno stack **Kubernetes-native**:

```
GitHub repo (privato)
    │
    │  push a main con "+semver: patch|minor|major"
    │
    ▼
Tekton Pipeline (CI) ←── kubectl create -f pipeline-run.yaml (manuale)
    │
    ├── 1. Clone repo (SSH)
    ├── 2. Calcola versione semver dal commit message
    ├── 3. Build Docker image → push a DockerHub
    ├── 4. Aggiorna eng/k8s/deployment-webapp.yaml
    └── 5. Git commit + push + crea tag vX.Y.Z
                 │
                 ▼
         ArgoCD (GitOps CD) — monitora eng/k8s/ su main
                 │
                 ▼
         Kubernetes Deployment → rolling update
```

**Container registry**: DockerHub (`michelechirico/polemicasite`)
**Repository**: `git@github.com:polemicaleague-source/polemicasite.git` (privato, SSH)

---

## Terraform - Provisioning Cluster

Tutti i componenti del cluster sono definiti in `eng/terraform/`.

### Dual-cloud: Azure vs Minikube

```bash
# Azure AKS
terraform apply -var-file=terraform.tfvars.azure

# Minikube locale
terraform apply -var-file=terraform.tfvars.minikube
```

Il provider viene scelto dalla variabile `cloud_provider` nel tfvars.

### Moduli installati

| Modulo | Cosa fa |
|--------|---------|
| `aks/` | Cluster Azure AKS |
| `minikube/` | Cluster Minikube locale |
| `tekton/` + `tekton-tasks/` | Tekton Pipelines, ServiceAccount, RBAC |
| `argocd/` | ArgoCD GitOps |
| `postgresql/` | PostgreSQL (Bitnami Helm chart) |

### Variabili principali

| Variabile | Default | Note |
|-----------|---------|------|
| `cloud_provider` | `minikube` | `azure` o `minikube` |
| `azure_resource_group` | `polemicasite-rg` | Solo Azure |
| `aks_cluster_name` | `polemicasite-aks` | Solo Azure |
| `postgresql_password` | — | **OBBLIGATORIO**, genera prima di apply |

### Generare una password sicura per PostgreSQL

```bash
# Linux/WSL
openssl rand -base64 32

# PowerShell
-join ((48..57)+(65..90)+(97..122) | Get-Random -Count 32 | %{[char]$_})
```

Poi aggiornala nel tfvars:

```hcl
# terraform.tfvars.azure (o .minikube)
postgresql_password = "la-tua-password-sicura"
```

---

## PostgreSQL

Deployato via Helm (Bitnami) nel namespace `postgresql`.

**Connection string** (da dentro il cluster):
```
postgresql://polemicasite:password@postgresql.postgresql.svc.cluster.local:5432/polemicasite
```

**Output Terraform**:
```bash
terraform output postgresql_connection
```

**Accesso diretto** (port-forward):
```bash
kubectl port-forward -n postgresql svc/postgresql 5432:5432 &
psql -h localhost -U polemicasite -d polemicasite
```

Configurazione completa (storage, resources, ecc.) tramite variabili Terraform con prefisso `postgresql_*`.

---

## Tekton - CI Pipeline

### Tasks custom (in `eng/tekton/`)

| File | Funzione |
|------|----------|
| `task-compute-semver.yaml` | Legge commit message → calcola nuova versione semver |
| `task-update-deployment.yaml` | Aggiorna `deployment-webapp.yaml` con nuovo tag |
| `task-git-tag-push.yaml` | Push commit + crea git tag su GitHub |
| `pipeline.yaml` | Definizione pipeline completa |
| `pipeline-run.yaml` | Run istanza (unico file da applicare) |

### Flusso pipeline

```
fetch-source
     │
compute-version  ← legge "+semver: X" dall'ultimo commit message
     │
build-push-web   ← build michelechirico/polemicasite:vX.Y.Z → DockerHub
     │
update-deployment ← aggiorna deployment-webapp.yaml
     │
git-tag-and-push  ← commit + push + tag vX.Y.Z su GitHub
```

### Deploy delle tasks al primo setup

```bash
kubectl apply -f eng/tekton/task-compute-semver.yaml
kubectl apply -f eng/tekton/task-update-deployment.yaml
kubectl apply -f eng/tekton/task-git-tag-push.yaml
kubectl apply -f eng/tekton/pipeline.yaml
```

### Secrets necessari nel namespace `tekton-tasks`

**SSH per GitHub** (clone + push):
```bash
kubectl create secret generic git-credentials \
  --from-file=ssh-privatekey=deploy_key \
  -n tekton-tasks
kubectl patch serviceaccount git-credentials-sa \
  -n tekton-tasks \
  -p '{"secrets":[{"name":"git-credentials"}]}'
```

**Docker Hub** (push immagine):
```bash
# Opzione A: token Docker Hub
kubectl create secret docker-registry docker-credentials \
  --docker-server=docker.io \
  --docker-username=michelechirico \
  --docker-password=<TOKEN> \
  -n tekton-tasks

# Opzione B: da config.json locale (se hai già fatto docker login)
kubectl create secret generic docker-credentials \
  --from-file=config.json=$HOME/.docker/config.json \
  -n tekton-tasks
```

---

## ArgoCD - GitOps CD

ArgoCD monitora `eng/k8s/` sul branch `main` e sincronizza automaticamente qualsiasi cambio.

### Setup iniziale

```bash
# 1. Crea secret SSH per accesso al repo privato
kubectl create secret generic polemicasite-repo \
  --from-file=sshPrivateKey=deploy_key \
  -n argocd

# 2. Registra il repository
kubectl apply -f eng/argocd/repositories.yaml

# 3. Crea l'Application (inizia il sync)
kubectl apply -f eng/argocd/application.yaml
```

### Configurazione

```yaml
# eng/argocd/application.yaml
source:
  repoURL: ssh://git@github.com/polemicaleague-source/polemicasite.git
  path: eng/k8s          # Monitora questa cartella
syncPolicy:
  automated:
    prune: true           # Rimuove risorse eliminate da git
    selfHeal: true        # Ripristina modifiche manuali a K8s
```

### Monitorare ArgoCD

```bash
# Port-forward alla UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# → https://localhost:8080

# Password admin
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Sync manuale forzato
argocd app sync polemicasite

# Rollback a sync precedente
argocd app history polemicasite
argocd app rollback polemicasite <REVISION>
```

---

## Release Workflow

### Convenzione commit message (semver automatico)

Includi il tag nel messaggio di commit **prima di lanciare la pipeline**:

```bash
git commit -m "fix: corretto calcolo classifica +semver: patch"
git commit -m "feat: aggiunta pagina statistiche +semver: minor"
git commit -m "refactor: migrazione a nuovo stack +semver: major"
```

Se non c'è `+semver:` nel commit, la pipeline usa `patch` come default.

### Lanciare una release

```bash
kubectl create -f eng/tekton/pipeline-run.yaml
```

Nessun parametro da cambiare: la pipeline legge tutto dal commit.

### Monitorare la pipeline

```bash
# Elenco PipelineRun
kubectl get pipelinerun -n tekton-tasks

# Log della run
kubectl logs -f <pipelinerun-name> -n tekton-tasks
```

### Risultato di una release

- ✅ Immagine buildata e pushata: `michelechirico/polemicasite:v1.0.1`
- ✅ `eng/k8s/deployment-webapp.yaml` aggiornato con nuovo tag
- ✅ Commit pushato su `main`
- ✅ Git tag `v1.0.1` creato su GitHub
- ✅ ArgoCD sincronizza automaticamente
- ✅ K8s fa rolling update con la nuova immagine

---

## SSH Deploy Key Setup

⚠️ **CRITICO**: il repo è privato. Senza SSH deploy key, ArgoCD e Tekton non funzionano.

### 1. Genera la chiave

```bash
ssh-keygen -t ed25519 -f deploy_key -C "argocd" -N ""
```

Genera due file:
- `deploy_key` → chiave privata (non committare MAI)
- `deploy_key.pub` → chiave pubblica (va su GitHub)

### 2. Aggiungi a GitHub

`polemicaleague-source/polemicasite` → **Settings > Deploy keys > Add deploy key**

- Title: `argocd-polemicasite`
- Incolla il contenuto di `deploy_key.pub`
- **Allow write access**: ✅ (necessario per Tekton push)

### 3. Crea i secrets nel cluster

```bash
# Per ArgoCD
kubectl create secret generic polemicasite-repo \
  --from-file=sshPrivateKey=deploy_key \
  -n argocd

# Per Tekton
kubectl create secret generic git-credentials \
  --from-file=ssh-privatekey=deploy_key \
  -n tekton-tasks
kubectl patch serviceaccount git-credentials-sa \
  -n tekton-tasks \
  -p '{"secrets":[{"name":"git-credentials"}]}'
```

---

## Checklist di Deploy

Da eseguire in ordine alla prima creazione del cluster:

- [ ] Generare SSH deploy key (`ssh-keygen -t ed25519 -f deploy_key`)
- [ ] Aggiungere chiave pubblica a GitHub deploy keys (con write access)
- [ ] Impostare `postgresql_password` in `terraform.tfvars.*`
- [ ] `terraform apply -var-file=terraform.tfvars.<provider>`
- [ ] Creare secret SSH in ArgoCD e Tekton (vedi sopra)
- [ ] Creare secret Docker Hub in `tekton-tasks`
- [ ] Deploy tasks Tekton: `kubectl apply -f eng/tekton/task-*.yaml`
- [ ] Deploy pipeline: `kubectl apply -f eng/tekton/pipeline.yaml`
- [ ] Registrare repo in ArgoCD: `kubectl apply -f eng/argocd/repositories.yaml`
- [ ] Creare Application ArgoCD: `kubectl apply -f eng/argocd/application.yaml`
- [ ] Verificare sync: `argocd app get polemicasite`
- [ ] ⚠️ **MAI committare** `deploy_key` nel repository

---

## Struttura File

```
eng/
├── argocd/
│   ├── application.yaml        # ArgoCD Application (GitOps entry point)
│   └── repositories.yaml       # Credenziali SSH repo (sshPrivateKey = placeholder)
├── k8s/
│   ├── namespace.yaml           # Namespace polemicasite
│   ├── deployment-webapp.yaml   # Deployment web (immagine aggiornata dalla pipeline)
│   ├── service-webapp.yaml      # Service ClusterIP
│   └── tekton-rbac.yaml         # ServiceAccount + Role + RoleBinding Tekton
├── tekton/
│   ├── pipeline.yaml            # Pipeline definition
│   ├── pipeline-run.yaml        # Run istanza (l'unico file da applicare per release)
│   ├── task-compute-semver.yaml # Auto-calcola versione dal commit message
│   ├── task-update-deployment.yaml # Aggiorna deployment manifest
│   └── task-git-tag-push.yaml   # Push + git tag
└── terraform/
    ├── main.tf                  # Moduli: AKS/Minikube, Tekton, ArgoCD, PostgreSQL
    ├── variables.tf             # Tutte le variabili con defaults
    ├── terraform.tfvars.azure   # Valori per Azure (postgresql_password da impostare)
    ├── terraform.tfvars.minikube # Valori per Minikube
    └── modules/
        ├── aks/                 # Azure AKS cluster
        ├── minikube/            # Minikube cluster
        ├── tekton/              # Tekton Helm + installazione
        ├── tekton-tasks/        # Namespace, ServiceAccount, RBAC, tasks hub
        ├── argocd/              # ArgoCD Helm
        └── postgresql/          # PostgreSQL Bitnami Helm
```

### Cosa NON è implementato (deferred)

- **Ingress / TLS**: il service è ClusterIP, nessuna esposizione esterna
- **DNS**: dominio applicativo da configurare
- **Monitoring**: Prometheus/Grafana/OTel rimossi dalla baseline
- **Backup PostgreSQL**: nessun backup automatico
- **NetworkPolicy**: traffic isolation tra namespace
