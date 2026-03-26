# Deployment

## 📋 Indice

1. [Panoramica Deployment](#panoramica-deployment)
2. [Deployment Frontend (Netlify)](#deployment-frontend-netlify)
3. [Deployment Backend (Supabase)](#deployment-backend-supabase)
4. [Variabili d'Ambiente](#variabili-dambiente)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Monitoring e Logs](#monitoring-e-logs)
7. [Rollback e Recovery](#rollback-e-recovery)

---

## Panoramica Deployment

**Polemica League** utilizza un'architettura **JAMstack** con deployment separato per frontend e backend:

```
┌─────────────────────────────────────────────────────────┐
│                    PRODUCTION STACK                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────┐        ┌──────────────────┐    │
│  │   NETLIFY CDN      │        │   SUPABASE       │    │
│  │                    │        │                  │    │
│  │  • Static hosting  │◄──────►│  • PostgreSQL    │    │
│  │  • Auto SSL        │        │  • Edge Functions│    │
│  │  • Global CDN      │        │  • Auth          │    │
│  │  • Auto deploy     │        │  • Storage       │    │
│  └────────────────────┘        └──────────────────┘    │
│           │                             │               │
│           │                             │               │
│           ▼                             ▼               │
│    React App (SPA)              PostgreSQL + API        │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Vantaggi Architettura

**Frontend (Netlify)**:
- ✅ Deploy automatico da Git
- ✅ CDN globale per performance
- ✅ SSL automatico
- ✅ Preview deployments per PR
- ✅ Rollback istantaneo
- ✅ Redirects e rewrites

**Backend (Supabase)**:
- ✅ Database managed PostgreSQL
- ✅ Backup automatici
- ✅ Scaling automatico
- ✅ Edge Functions serverless
- ✅ Auth integrato
- ✅ Storage per file

---

## Deployment Frontend (Netlify)

### Setup Iniziale

#### 1. Crea Account Netlify

1. Vai su [netlify.com](https://netlify.com)
2. Sign up con GitHub
3. Autorizza accesso ai repository

#### 2. Collega Repository

1. Click **Add new site** → **Import an existing project**
2. Scegli **GitHub**
3. Seleziona repository `polemicasite`
4. Configura build settings:

```yaml
# Build settings
Build command: npm run build
Publish directory: dist
```

#### 3. Configura Variabili d'Ambiente

In Netlify Dashboard:
1. Vai su **Site settings** → **Environment variables**
2. Aggiungi variabili:

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

#### 4. Deploy

Click **Deploy site** - Netlify:
1. Clona il repository
2. Installa dipendenze (`npm install`)
3. Esegue build (`npm run build`)
4. Pubblica `dist/` su CDN
5. Assegna URL: `https://random-name.netlify.app`

### Configurazione netlify.toml

Il file [`netlify.toml`](../netlify.toml) nella root configura il deployment:

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

**Spiegazione**:
- `command`: Comando per build produzione
- `publish`: Directory da pubblicare
- `redirects`: SPA routing - tutte le route → `index.html`

### Custom Domain

#### 1. Aggiungi Dominio

1. **Site settings** → **Domain management**
2. Click **Add custom domain**
3. Inserisci dominio (es. `polemicaleague.com`)

#### 2. Configura DNS

**Opzione A: Netlify DNS** (consigliato)
1. Netlify fornisce nameservers
2. Aggiorna nameservers presso registrar
3. Netlify gestisce tutto automaticamente

**Opzione B: DNS Esterno**
1. Crea record A:
   ```
   @ → 75.2.60.5
   ```
2. Crea record CNAME:
   ```
   www → your-site.netlify.app
   ```

#### 3. SSL Automatico

Netlify provisiona automaticamente certificato SSL Let's Encrypt:
- Attivo entro 24h
- Rinnovo automatico
- HTTPS forzato

### Deploy Automatico

#### Trigger Deploy

**Automatic** (consigliato):
- Push su branch `main` → deploy automatico
- Netlify monitora repository GitHub
- Build e deploy in ~2-3 minuti

**Manual**:
```bash
# Installa Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy manuale
netlify deploy --prod
```

#### Deploy Previews

Per ogni Pull Request, Netlify crea automaticamente:
- **Preview URL**: `https://deploy-preview-123--your-site.netlify.app`
- Ambiente isolato per testing
- Commento automatico su PR con link

### Build Optimization

#### 1. Build Cache

Netlify cachea automaticamente `node_modules/`:
- Primo build: ~2-3 minuti
- Build successivi: ~30-60 secondi

#### 2. Build Plugins

Aggiungi in `netlify.toml`:

```toml
[[plugins]]
  package = "@netlify/plugin-lighthouse"

[[plugins]]
  package = "netlify-plugin-cache"
```

#### 3. Split Chunks

Vite già ottimizza automaticamente:
```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'router': ['react-router-dom'],
          'charts': ['recharts']
        }
      }
    }
  }
})
```

---

## Deployment Backend (Supabase)

### Setup Progetto Supabase

#### 1. Crea Progetto

1. Vai su [app.supabase.com](https://app.supabase.com)
2. Click **New project**
3. Compila form:
   - **Name**: `polemica-league`
   - **Database Password**: (genera password sicura)
   - **Region**: `eu-central-1` (o più vicino)
   - **Pricing Plan**: Free (o Pro per produzione)
4. Click **Create new project**
5. Attendi ~2 minuti per provisioning

#### 2. Ottieni Credenziali

1. Vai su **Settings** → **API**
2. Copia:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon public key**: `eyJhbGc...`
   - **service_role key**: `eyJhbGc...` (solo per Edge Functions)

### Database Migrations

#### Opzione A: Supabase Dashboard (Manuale)

1. Vai su **SQL Editor**
2. Click **New query**
3. Copia contenuto migration file
4. Click **Run**
5. Ripeti per ogni migration in ordine

#### Opzione B: Supabase CLI (Automatico)

```bash
# Link progetto locale a remoto
supabase link --project-ref your-project-ref

# Push tutte le migrations
supabase db push

# Verifica stato
supabase db diff
```

#### Ordine Migrations

Esegui in questo ordine:
1. `20250101000000_init.sql` - Schema base
2. `20250102000000_public_read.sql` - RLS pubblico
3. `20250103000000_grant_views.sql` - Permessi views
4. `20250104000000_player_avatar_nickname.sql` - Avatar/nickname
5. `20250105000000_remove_gcp.sql` - Cleanup
6. `20250106000000_home_widgets.sql` - Widget homepage
7. `20250107000000_instagram_widget.sql` - Widget Instagram

### Edge Functions Deployment

#### 1. Deploy Singola Function

```bash
# Deploy function specifica
supabase functions deploy get-classifiche

# Con secrets
supabase functions deploy get-classifiche \
  --project-ref your-project-ref
```

#### 2. Deploy Tutte le Functions

```bash
# Deploy tutte insieme
supabase functions deploy
```

#### 3. Verifica Deployment

```bash
# Lista functions deployate
supabase functions list

# Test function
curl https://your-project.supabase.co/functions/v1/get-classifiche \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Storage Setup

#### 1. Crea Bucket per Avatar

1. Vai su **Storage**
2. Click **New bucket**
3. Nome: `avatars`
4. Public: ✅ (per accesso pubblico)
5. Click **Create bucket**

#### 2. Configura Policies

```sql
-- Policy per upload (solo admin)
CREATE POLICY "Admin can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Policy per lettura pubblica
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

#### 3. Upload Avatar

```typescript
// Frontend code
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${playerId}.jpg`, file, {
    cacheControl: '3600',
    upsert: true
  })

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${playerId}.jpg`)
```

### Database Backup

#### Automatico (Supabase)

**Free Plan**:
- Backup giornaliero
- Retention: 7 giorni
- Restore via dashboard

**Pro Plan**:
- Backup ogni 6 ore
- Retention: 30 giorni
- Point-in-time recovery

#### Manuale

```bash
# Export database
supabase db dump -f backup.sql

# Import database
psql -h db.xxx.supabase.co -U postgres -d postgres -f backup.sql
```

---

## Variabili d'Ambiente

### Frontend (Netlify)

```bash
# Production
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...

# Optional
VITE_ENVIRONMENT=production
```

**Configurazione**:
1. Netlify Dashboard → **Site settings** → **Environment variables**
2. Aggiungi variabili
3. Redeploy per applicare

### Backend (Supabase)

Edge Functions hanno accesso automatico a:
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
```

**Custom Secrets**:
```bash
# Set secret
supabase secrets set MY_SECRET=value

# List secrets
supabase secrets list

# Unset secret
supabase secrets unset MY_SECRET
```

---

## CI/CD Pipeline

### GitHub Actions (Opzionale)

Crea `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run lint
      - run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run build
      - uses: netlify/actions/cli@master
        with:
          args: deploy --prod
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### Workflow

```
┌──────────────┐
│  Git Push    │
│  to main     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  GitHub      │
│  detects     │
│  push        │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Netlify     │
│  webhook     │
│  triggered   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Clone repo  │
│  Install deps│
│  Run build   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Deploy to   │
│  CDN         │
│  ✅ Live     │
└──────────────┘
```

---

## Monitoring e Logs

### Netlify Monitoring

#### Deploy Logs

1. **Deploys** tab
2. Click su deploy specifico
3. Visualizza:
   - Build logs
   - Deploy summary
   - Function logs

#### Analytics

**Site settings** → **Analytics**:
- Page views
- Unique visitors
- Top pages
- Bandwidth usage

#### Function Logs

```bash
# Real-time logs
netlify functions:log

# Specific function
netlify functions:log function-name
```

### Supabase Monitoring

#### Database Logs

1. **Logs** → **Postgres Logs**
2. Filtra per:
   - Slow queries
   - Errors
   - Connections

#### Edge Function Logs

1. **Edge Functions** → Select function
2. **Logs** tab
3. Real-time streaming
4. Filtra per severity

#### Performance Metrics

**Reports** → **Database**:
- Query performance
- Connection pool
- Cache hit rate
- Disk usage

### Error Tracking (Opzionale)

#### Sentry Integration

```bash
npm install @sentry/react
```

```typescript
// src/main.tsx
import * as Sentry from '@sentry/react'

Sentry.init({
  dsn: 'your-sentry-dsn',
  environment: import.meta.env.MODE,
  tracesSampleRate: 1.0,
})
```

---

## Rollback e Recovery

### Frontend Rollback (Netlify)

#### Instant Rollback

1. **Deploys** tab
2. Trova deploy precedente funzionante
3. Click **Publish deploy**
4. Conferma
5. ✅ Rollback istantaneo (< 1 minuto)

#### CLI Rollback

```bash
# Lista deploys
netlify deploy:list

# Rollback a deploy specifico
netlify deploy:publish --deploy-id DEPLOY_ID
```

### Database Recovery (Supabase)

#### Point-in-Time Recovery (Pro Plan)

1. **Database** → **Backups**
2. Scegli timestamp
3. Click **Restore**
4. Conferma

#### Manual Restore

```bash
# Restore da backup
psql -h db.xxx.supabase.co \
     -U postgres \
     -d postgres \
     -f backup.sql
```

### Disaster Recovery Plan

#### 1. Database Backup

```bash
# Backup automatico giornaliero
# Retention: 7 giorni (Free) / 30 giorni (Pro)

# Backup manuale prima di modifiche critiche
supabase db dump -f backup-$(date +%Y%m%d).sql
```

#### 2. Code Backup

```bash
# Git è il backup
# Tutti i commit sono recuperabili

# Tag release importanti
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

#### 3. Environment Variables

```bash
# Backup variabili Netlify
netlify env:list > netlify-env-backup.txt

# Backup secrets Supabase
supabase secrets list > supabase-secrets-backup.txt
```

---

## Checklist Pre-Deploy

### Frontend

- [ ] Build locale funziona (`npm run build`)
- [ ] Nessun errore TypeScript (`npx tsc --noEmit`)
- [ ] Nessun errore ESLint (`npm run lint`)
- [ ] Variabili d'ambiente configurate
- [ ] Test su build di produzione (`npm run preview`)

### Backend

- [ ] Migrations testate localmente
- [ ] Edge Functions testate localmente
- [ ] Database backup recente
- [ ] RLS policies verificate
- [ ] Secrets configurati

### Post-Deploy

- [ ] Verifica homepage carica
- [ ] Test login admin
- [ ] Verifica API endpoints
- [ ] Check console browser per errori
- [ ] Test su mobile
- [ ] Verifica SSL attivo

---

## Troubleshooting Deploy

### Build Fallisce su Netlify

**Errore**: `Command failed with exit code 1`

**Soluzioni**:
```bash
# 1. Verifica build locale
npm run build

# 2. Controlla Node version
# Netlify usa Node 18 di default
# Specifica in netlify.toml:
[build.environment]
  NODE_VERSION = "18"

# 3. Pulisci cache Netlify
# Dashboard → Deploys → Deploy settings → Clear cache
```

### Variabili d'Ambiente Non Caricate

**Problema**: `undefined` per `import.meta.env.VITE_*`

**Soluzioni**:
1. Verifica prefisso `VITE_`
2. Redeploy dopo aggiunta variabili
3. Controlla typo nei nomi

### Edge Function Timeout

**Errore**: `Function execution timed out`

**Soluzioni**:
```typescript
// Ottimizza query
// ❌ Lento
const { data } = await supabase.from('table').select('*')

// ✅ Veloce
const { data } = await supabase
  .from('table')
  .select('id, nome')
  .limit(100)
```

### Database Connection Issues

**Errore**: `Connection refused`

**Soluzioni**:
1. Verifica progetto Supabase attivo
2. Controlla URL e keys corretti
3. Verifica IP whitelist (se configurato)

---

## Prossimi Passi

Continua con:
- [Workflow di Sviluppo](./06-workflow.md) per contribuire al progetto
- [Setup](./02-setup.md) per ambiente locale
- [API](./04-api.md) per integrazioni

---

**Ultima modifica**: 2026-03-26