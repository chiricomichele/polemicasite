# 🔐 Configurazione Variabili d'Ambiente

## Quick Setup

### 1. Crea il file .env

Nella root del progetto, copia il file template:

```bash
cp .env.example .env
```

### 2. Ottieni le Credenziali Supabase

#### Opzione A: Progetto Esistente

1. Vai su [app.supabase.com](https://app.supabase.com)
2. Seleziona il tuo progetto **polemica-league**
3. Vai su **Settings** → **API**
4. Copia le credenziali:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Opzione B: Nuovo Progetto

Se non hai ancora un progetto Supabase:

1. Vai su [app.supabase.com](https://app.supabase.com)
2. Click **New Project**
3. Compila:
   - **Name**: `polemica-league`
   - **Database Password**: (genera una password sicura e salvala!)
   - **Region**: `Europe (Frankfurt)` o più vicino a te
   - **Pricing Plan**: Free (per iniziare)
4. Click **Create new project**
5. Attendi ~2 minuti per il provisioning
6. Vai su **Settings** → **API** per ottenere le credenziali

### 3. Configura il file .env

Apri il file `.env` e sostituisci i valori:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxxxxxxxxxxxxxx...
```

**⚠️ IMPORTANTE**: 
- NON committare mai il file `.env` su Git
- Il file `.env` è già in `.gitignore`
- Usa solo `.env.example` per documentazione

### 4. Verifica la Configurazione

```bash
# Avvia il server di sviluppo
npm run dev
```

Se tutto è configurato correttamente:
- ✅ L'app si avvia senza errori
- ✅ Puoi vedere i dati (se il database è popolato)
- ✅ Non ci sono errori di connessione nella console

## 🔍 Troubleshooting

### Errore: "Invalid API key"

**Problema**: La chiave API non è corretta

**Soluzione**:
1. Verifica di aver copiato la **anon public key** (non la service_role key)
2. Controlla che non ci siano spazi extra all'inizio o alla fine
3. Assicurati che il progetto Supabase sia attivo

### Errore: "Failed to fetch"

**Problema**: URL Supabase non corretto o progetto non raggiungibile

**Soluzione**:
1. Verifica che l'URL sia nel formato: `https://xxxxx.supabase.co`
2. Controlla che il progetto Supabase sia attivo (non in pausa)
3. Verifica la connessione internet

### Variabili non caricate

**Problema**: `import.meta.env.VITE_SUPABASE_URL` è `undefined`

**Soluzione**:
1. Verifica che le variabili inizino con `VITE_`
2. Riavvia il server di sviluppo (`npm run dev`)
3. Controlla che il file `.env` sia nella root del progetto

## 📝 Variabili Disponibili

### Obbligatorie

```env
VITE_SUPABASE_URL=          # URL del progetto Supabase
VITE_SUPABASE_ANON_KEY=     # Chiave pubblica anonima
```

### Opzionali

```env
VITE_DEV_MODE=true          # Abilita modalità sviluppo
VITE_ENVIRONMENT=development # Nome ambiente (development/staging/production)
```

## 🚀 Ambienti Multipli

### Development (.env)
```env
VITE_SUPABASE_URL=https://dev-project.supabase.co
VITE_SUPABASE_ANON_KEY=dev-key...
VITE_ENVIRONMENT=development
```

### Production (Netlify)
Le variabili di produzione vanno configurate su Netlify:

1. Netlify Dashboard → **Site settings**
2. **Environment variables**
3. Aggiungi:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_ENVIRONMENT=production`

## 🔒 Sicurezza

### ✅ Best Practices

- ✅ Usa `.env.example` per documentazione
- ✅ Aggiungi `.env` a `.gitignore`
- ✅ Non condividere mai le credenziali
- ✅ Usa chiavi diverse per dev/staging/prod
- ✅ Rigenera le chiavi se compromesse

### ❌ Da Evitare

- ❌ Non committare `.env` su Git
- ❌ Non condividere `.env` via email/chat
- ❌ Non usare credenziali di produzione in sviluppo
- ❌ Non hardcodare credenziali nel codice

## 📚 Risorse

- [Supabase API Settings](https://app.supabase.com/project/_/settings/api)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Supabase Documentation](https://supabase.com/docs)

---

**Hai problemi?** Controlla la [documentazione completa](./02-setup.md) o apri una issue.