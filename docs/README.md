# Polemica League - Documentazione Tecnica

Benvenuto nella documentazione tecnica di **Polemica League**, un'applicazione web per la gestione di una lega calcistica amatoriale con statistiche, classifiche, rivalità e molto altro.

## 📚 Indice della Documentazione

1. [**Architettura e Framework**](./01-architettura.md) - Panoramica dell'architettura tecnica e delle tecnologie utilizzate
2. [**Configurazione e Setup**](./02-setup.md) - Guida completa per configurare l'ambiente di sviluppo
3. [**Schema Database**](./03-database.md) - Documentazione dettagliata dello schema del database
4. [**API e Integrazioni**](./04-api.md) - Documentazione delle API e delle integrazioni esterne
5. [**Deployment**](./05-deployment.md) - Guida al deployment su Netlify e Supabase
6. [**Workflow di Sviluppo**](./06-workflow.md) - Best practices e workflow per lo sviluppo

## 🎯 Panoramica del Progetto

**Polemica League** è un'applicazione moderna per la gestione di una lega calcistica che include:

- 📊 **Statistiche dettagliate** dei giocatori e delle partite
- 🏆 **Classifiche dinamiche** con ranking e performance
- ⚔️ **Sistema di rivalità** tra giocatori
- 📰 **Gestione news** e aggiornamenti
- 👤 **Profili giocatori** con storico prestazioni
- 🔐 **Area amministrativa** per la gestione dei contenuti
- 📱 **Design responsive** ottimizzato per mobile

## 🛠️ Stack Tecnologico

- **Frontend**: React 19 + TypeScript + Vite
- **Routing**: React Router v7
- **Styling**: CSS custom con design tokens
- **Database**: PostgreSQL (Supabase)
- **Backend**: Supabase (Auth, Database, Edge Functions)
- **Deployment**: Netlify (frontend) + Supabase (backend)
- **Validazione**: Zod
- **Animazioni**: Framer Motion
- **Grafici**: Recharts

## 🚀 Quick Start

```bash
# Clona il repository
git clone <repository-url>
cd polemicasite

# Installa le dipendenze
npm install

# Configura le variabili d'ambiente
cp .env.example .env

# Avvia il server di sviluppo
npm run dev
```

Per maggiori dettagli, consulta la [Guida al Setup](./02-setup.md).

## 📖 Come Usare Questa Documentazione

Questa documentazione è organizzata in modo progressivo:

1. **Inizia con l'Architettura** per comprendere la struttura generale
2. **Segui il Setup** per configurare il tuo ambiente
3. **Studia il Database** per capire il modello dati
4. **Esplora le API** per integrare nuove funzionalità
5. **Consulta il Deployment** quando sei pronto per pubblicare
6. **Segui il Workflow** per contribuire al progetto

## 🤝 Contribuire

Per contribuire al progetto, consulta la sezione [Workflow di Sviluppo](./06-workflow.md) che include:

- Convenzioni di codice
- Processo di review
- Best practices
- Testing guidelines

## 📝 Note

Questa documentazione è in continuo aggiornamento. Se trovi errori o vuoi suggerire miglioramenti, apri una issue o una pull request.

---

**Ultima modifica**: 2026-03-26