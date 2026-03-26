# Configurazione e Setup

## 📋 Indice

1. [Prerequisiti](#prerequisiti)
2. [Installazione Locale](#installazione-locale)
3. [Configurazione Ambiente](#configurazione-ambiente)
4. [Setup Supabase](#setup-supabase)
5. [Comandi Disponibili](#comandi-disponibili)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisiti

### Software Richiesto

#### Node.js (v18.0.0 o superiore)
```bash
# Verifica versione installata
node --version

# Consigliato: usa nvm per gestire versioni Node
nvm install 18
nvm use 18
```

**Download**: [nodejs.org](https://nodejs.org/)

#### npm (v9.0.0 o superiore)
```bash
# Verifica versione
npm --version

# Aggiorna npm
npm install -g npm@latest
```

#### Git
```bash
# Verifica installazione
git --version
```

**Download**: [git-scm.com](https://git-scm.com/)

#### Supabase CLI (opzionale, per sviluppo locale)
```bash
# Installa Supabase CLI
npm install -g supabase

# Verifica installazione
supabase --version
```

**Documentazione**: [supabase.com/docs/guides/cli](https://supabase.com/docs/guides/cli)

### Account Necessari

1. **Supabase Account** (gratuito)
   - Registrati su [supabase.com](https://supabase.com)
   - Crea un nuovo progetto
   - Annota URL e anon key

2. **Netlify Account** (opzionale, per deployment)
   - Registrati su [netlify.com](https://netlify.com)
   - Collega il repository GitHub

---

## Installazione Locale

### 1. Clona il Repository

```bash
# HTTPS
git clone https://github.com/your-username/polemicasite.git

# SSH (consigliato)
git clone git@github.com:your-username/polemicasite.git

# Entra nella directory
cd polemicasite
```

### 2. Installa le Dipendenze

```bash
# Installa tutte le dipendenze
npm install

# Output atteso:
# added 234 packages in 15s
```

**Dipendenze principali installate**:
- `react` + `react-dom` (19.2.4)
- `@supabase/supabase-js` (2.100.0)
- `react-router-dom` (7.13.2)
- `framer-motion` (12.38.0)
- `recharts` (3.8.0)
- `zod` (4.3.6)
- `sonner` (2.0.7)

**Dev dependencies**:
- `vite` (8.0.1)
- `typescript` (5.9.3)
- `@vitejs/plugin-react` (6.0.1)
- `eslint` + plugins

### 3. Verifica Installazione

```bash
# Controlla che non ci siano vulnerabilità
npm audit

# Se ci sono vulnerabilità risolvibili
npm audit fix
```

---

## Configurazione Ambiente

### 1. Crea File Environment

```bash
# Crea file .env nella root del progetto
touch .env
```

### 2. Configura Variabili d'Ambiente

Apri `.env` e aggiungi:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here

# Optional: Development settings
VITE_DEV_MODE=true
```

### 3. Ottieni Credenziali Supabase

#### Opzione A: Progetto Esistente

1. Vai su [app.supabase.com](https://app.supabase.com)
2. Seleziona il tuo progetto
3. Vai su **Settings** → **API**
4. Copia:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon public** key → `VITE_SUPABASE_ANON_KEY`

#### Opzione B: Nuovo Progetto

1. Vai su [app.supabase.com](https://app.supabase.com)
2. Click **New Project**
3. Compila:
   - **Name**: `polemica-league`
   - **Database Password**: (genera password sicura)
   - **Region**: Scegli più vicino (es. `eu-central-1`)
4. Click **Create new project**
5. Attendi ~2 minuti per provisioning
6. Segui "Opzione A" per ottenere credenziali

### 4. Verifica Configurazione

```bash
# Avvia il server di sviluppo
npm run dev

# Output atteso:
# VITE v8.0.1  ready in 234 ms
# ➜  Local:   http://localhost:5173/
# ➜  Network: use --host to expose
```

Apri [http://localhost:5173](http://localhost:5173) nel browser.

**✅ Se vedi la homepage, la configurazione è corretta!**

---

## Setup Supabase

### Opzione 1: Usa Progetto Cloud (Consigliato per Inizio)

Se hai già configurato le variabili d'ambiente, sei pronto! Il progetto si connetterà automaticamente al database cloud.

### Opzione 2: Setup Locale (Avanzato)

Per sviluppo completamente offline con database locale.

#### 1. Installa Docker

Supabase locale richiede Docker Desktop.

**Download**: [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

```bash
# Verifica installazione
docker --version
docker-compose --version
```

#### 2. Inizializza Supabase Locale

```bash
# Nella root del progetto
supabase init

# Output: Supabase CLI is now set up
```

Questo crea la cartella `supabase/` con configurazione.

#### 3. Avvia Supabase Locale

```bash
# Avvia tutti i servizi Supabase
supabase start

# Prima volta: scarica immagini Docker (~2-3 GB)
# Tempo: 5-10 minuti

# Output finale:
# Started supabase local development setup.
# 
#          API URL: http://localhost:54321
#           DB URL: postgresql://postgres:postgres@localhost:54322/postgres
#       Studio URL: http://localhost:54323
#     Inbucket URL: http://localhost:54324
#         anon key: eyJhbGc...
# service_role key: eyJhbGc...
```

#### 4. Configura .env per Locale

```env
# .env.local (crea questo file per override locale)
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=eyJhbGc... # copia da output supabase start
```

#### 5. Applica Migrations

```bash
# Applica tutte le migrations al database locale
supabase db reset

# Output: Database reset successfully
```

#### 6. Accedi a Supabase Studio

Apri [http://localhost:54323](http://localhost:54323) per:
- Visualizzare tabelle
- Eseguire query SQL
- Gestire dati
- Testare API

### Gestione Database Locale

```bash
# Ferma Supabase
supabase stop

# Riavvia Supabase
supabase start

# Reset database (cancella tutti i dati)
supabase db reset

# Crea nuova migration
supabase migration new migration_name

# Applica migrations
supabase db push
```

---

## Comandi Disponibili

### Development

```bash
# Avvia dev server con HMR
npm run dev

# Server disponibile su http://localhost:5173
# Hot reload automatico su modifiche file
```

### Build

```bash
# Build per produzione
npm run build

# Output in dist/
# - HTML, CSS, JS minificati
# - Assets ottimizzati
# - Source maps generate

# Verifica build
ls -lh dist/
```

### Preview

```bash
# Preview build di produzione localmente
npm run preview

# Server su http://localhost:4173
# Simula ambiente produzione
```

### Linting

```bash
# Esegui ESLint
npm run lint

# Fix automatico problemi risolvibili
npm run lint -- --fix
```

### Type Checking

```bash
# Verifica tipi TypeScript
npx tsc --noEmit

# Build con type checking
npm run build
```

### Supabase (se setup locale)

```bash
# Avvia Supabase locale
supabase start

# Ferma Supabase
supabase stop

# Reset database
supabase db reset

# Genera types TypeScript da database
supabase gen types typescript --local > src/types/supabase.ts

# Crea nuova migration
supabase migration new add_new_feature

# Applica migrations
supabase db push

# Pull schema da remoto
supabase db pull
```

---

## Troubleshooting

### Problema: `npm install` fallisce

**Errore**: `ERESOLVE unable to resolve dependency tree`

**Soluzione**:
```bash
# Pulisci cache npm
npm cache clean --force

# Rimuovi node_modules e package-lock.json
rm -rf node_modules package-lock.json

# Reinstalla
npm install
```

### Problema: Porta 5173 già in uso

**Errore**: `Port 5173 is already in use`

**Soluzione**:
```bash
# Opzione 1: Usa porta diversa
npm run dev -- --port 3000

# Opzione 2: Trova e termina processo
# Windows
netstat -ano | findstr :5173
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:5173 | xargs kill -9
```

### Problema: Errori di connessione Supabase

**Errore**: `Failed to fetch` o `Network error`

**Verifica**:
```bash
# 1. Controlla variabili d'ambiente
cat .env

# 2. Verifica URL Supabase
curl https://your-project-id.supabase.co

# 3. Testa connessione da browser
# Apri: https://your-project-id.supabase.co/rest/v1/
# Dovresti vedere: {"message":"Welcome to PostgREST"}
```

**Soluzioni**:
- Verifica che `VITE_SUPABASE_URL` sia corretto
- Verifica che `VITE_SUPABASE_ANON_KEY` sia corretto
- Controlla che il progetto Supabase sia attivo
- Verifica connessione internet

### Problema: TypeScript errors

**Errore**: `Cannot find module` o `Type errors`

**Soluzione**:
```bash
# Reinstalla types
npm install --save-dev @types/react @types/react-dom @types/node

# Pulisci cache TypeScript
rm -rf node_modules/.cache

# Riavvia TypeScript server in VSCode
# Cmd/Ctrl + Shift + P → "TypeScript: Restart TS Server"
```

### Problema: Build fallisce

**Errore**: `Build failed` o `Out of memory`

**Soluzione**:
```bash
# Aumenta memoria Node.js
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build

# Windows
set NODE_OPTIONS=--max-old-space-size=4096
npm run build
```

### Problema: Supabase locale non si avvia

**Errore**: `Docker daemon not running`

**Soluzione**:
1. Avvia Docker Desktop
2. Attendi che Docker sia completamente avviato
3. Riprova `supabase start`

**Errore**: `Port already allocated`

**Soluzione**:
```bash
# Ferma tutti i container
docker stop $(docker ps -aq)

# Rimuovi container
docker rm $(docker ps -aq)

# Riavvia Supabase
supabase start
```

### Problema: Hot reload non funziona

**Soluzione**:
```bash
# 1. Verifica che il file sia nella cartella src/
# 2. Riavvia dev server
npm run dev

# 3. Se persiste, pulisci cache Vite
rm -rf node_modules/.vite
npm run dev
```

### Problema: CSS non si applica

**Verifica**:
1. Controlla che `index.css` sia importato in `main.tsx`
2. Verifica sintassi CSS (niente errori)
3. Controlla DevTools per errori CSS
4. Hard refresh: `Ctrl+Shift+R` (Windows) o `Cmd+Shift+R` (Mac)

### Problema: Variabili d'ambiente non caricate

**Verifica**:
```typescript
// In qualsiasi file .tsx
console.log('Supabase URL:', import.meta.env.VITE_SUPABASE_URL)
```

**Soluzioni**:
- Variabili devono iniziare con `VITE_`
- Riavvia dev server dopo modifiche a `.env`
- Non committare `.env` (deve essere in `.gitignore`)

---

## Struttura File Configurazione

```
polemicasite/
├── .env                    # Variabili d'ambiente (NON committare)
├── .env.example           # Template variabili (committare)
├── .gitignore             # File da ignorare in Git
├── package.json           # Dipendenze e scripts
├── package-lock.json      # Lock file dipendenze
├── tsconfig.json          # Config TypeScript root
├── tsconfig.app.json      # Config TypeScript app
├── tsconfig.node.json     # Config TypeScript Node
├── vite.config.ts         # Config Vite
├── netlify.toml           # Config Netlify deployment
└── supabase/
    ├── config.toml        # Config Supabase locale
    ├── migrations/        # Database migrations
    └── functions/         # Edge Functions
```

### File da NON Committare

Già configurati in `.gitignore`:
- `.env` (credenziali sensibili)
- `node_modules/` (dipendenze)
- `dist/` (build output)
- `.vite/` (cache Vite)
- `.supabase/` (dati Supabase locale)

---

## Best Practices Setup

### 1. Usa .env.example

Crea `.env.example` con template:
```env
# Supabase Configuration
VITE_SUPABASE_URL=your_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

Committa questo file per documentare variabili necessarie.

### 2. Usa nvm per Node.js

```bash
# Crea .nvmrc nella root
echo "18" > .nvmrc

# Altri sviluppatori possono fare:
nvm use
```

### 3. Setup Git Hooks (opzionale)

```bash
# Installa husky per pre-commit hooks
npm install --save-dev husky

# Inizializza husky
npx husky init

# Aggiungi pre-commit hook
echo "npm run lint" > .husky/pre-commit
```

### 4. VSCode Extensions Consigliate

Crea `.vscode/extensions.json`:
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "supabase.supabase-vscode"
  ]
}
```

### 5. VSCode Settings

Crea `.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

---

## Prossimi Passi

Ora che hai configurato l'ambiente:

1. **Esplora il codice**: Inizia da [`src/App.tsx`](../src/App.tsx)
2. **Studia il database**: Leggi [Schema Database](./03-database.md)
3. **Comprendi le API**: Consulta [API Documentation](./04-api.md)
4. **Inizia a sviluppare**: Segui [Workflow di Sviluppo](./06-workflow.md)

---

## Risorse Utili

- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://react.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Router Documentation](https://reactrouter.com/)

---

**Ultima modifica**: 2026-03-26