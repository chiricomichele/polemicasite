# 📱 Progressive Web App (PWA) Setup

## ✅ Configurazione Completata

**Polemica League** è ora una **Progressive Web App (PWA)** completamente funzionale e installabile su qualsiasi dispositivo!

## 🚀 Come Testare l'Installabilità

### 1. Build dell'Applicazione
Prima di testare, devi fare il build della PWA:

```bash
npm run build
```

### 2. Avvia il Server di Preview
Dopo il build, avvia il server di anteprima:

```bash
npm run preview
```

### 3. Testa su Desktop (Chrome/Edge)

1. Apri l'applicazione nel browser (solitamente `http://localhost:4173`)
2. Cerca l'icona di installazione nella barra degli indirizzi (icona con freccia verso il basso o "+")
3. Clicca su "Installa" o "Installa Polemica League"
4. L'app verrà installata come applicazione standalone

**Oppure:**
- Apri il menu del browser (⋮)
- Seleziona "Installa Polemica League" o "Installa app"

### 4. Testa su Mobile (Android/iOS)

#### Android (Chrome/Edge):
1. Apri l'app nel browser mobile
2. Tocca il menu (⋮) in alto a destra
3. Seleziona "Installa app" o "Aggiungi a schermata Home"
4. Conferma l'installazione
5. L'icona apparirà nella schermata home

#### iOS (Safari):
1. Apri l'app in Safari
2. Tocca il pulsante "Condividi" (quadrato con freccia verso l'alto)
3. Scorri e seleziona "Aggiungi a Home"
4. Personalizza il nome se necessario
5. Tocca "Aggiungi"

## 🎯 Funzionalità PWA Implementate

### ✨ Caratteristiche Principali

- **📲 Installabile**: L'app può essere installata su qualsiasi dispositivo
- **🔄 Offline First**: Funziona anche senza connessione internet (cache intelligente)
- **⚡ Caricamento Veloce**: Risorse cachate per prestazioni ottimali
- **📱 Esperienza Nativa**: Si comporta come un'app nativa
- **🔔 Aggiornamenti Automatici**: Il service worker si aggiorna automaticamente

### 🎨 Icone e Branding

- Icone generate in formato 192x192 e 512x512
- Icone "maskable" per Android adaptive icons
- Theme color personalizzato (#1a1a1a)
- Splash screen automatico su iOS

### 💾 Strategia di Cache

1. **Font Google**: Cache-first (1 anno)
2. **API Supabase**: Network-first con fallback cache (5 minuti)
3. **Risorse statiche**: Pre-cachate durante l'installazione

## 🛠️ File Creati/Modificati

### Nuovi File:
- `public/manifest.json` - Manifest della PWA
- `public/pwa-192x192.png` - Icona 192x192
- `public/pwa-512x512.png` - Icona 512x512
- `public/pwa-maskable-192x192.png` - Icona maskable 192x192
- `public/pwa-maskable-512x512.png` - Icona maskable 512x512
- `scripts/generate-pwa-icons.js` - Script per generare icone

### File Modificati:
- `vite.config.ts` - Configurazione plugin PWA
- `index.html` - Meta tag PWA
- `src/main.tsx` - Registrazione service worker
- `package.json` - Dipendenze PWA

## 🔍 Verifica Installazione

### DevTools Chrome/Edge:
1. Apri DevTools (F12)
2. Vai alla tab "Application"
3. Controlla:
   - **Manifest**: Verifica che sia caricato correttamente
   - **Service Workers**: Deve essere "activated and running"
   - **Cache Storage**: Verifica le risorse cachate

### Lighthouse:
1. Apri DevTools (F12)
2. Vai alla tab "Lighthouse"
3. Seleziona "Progressive Web App"
4. Clicca "Generate report"
5. Dovresti ottenere un punteggio alto (90+)

## 📦 Deploy in Produzione

Quando fai il deploy su Netlify (o altro hosting):

1. Il build automatico includerà tutti i file PWA
2. Il service worker sarà attivo automaticamente
3. Gli utenti vedranno il prompt di installazione
4. L'app funzionerà offline dopo la prima visita

### Netlify (già configurato):
```bash
npm run build
# Netlify farà il deploy automatico della cartella dist/
```

## 🎉 Vantaggi per gli Utenti

- ✅ **Nessun App Store**: Installazione diretta dal browser
- ✅ **Aggiornamenti Istantanei**: Nessun download manuale
- ✅ **Spazio Ridotto**: Più leggera di un'app nativa
- ✅ **Funziona Offline**: Accesso anche senza internet
- ✅ **Cross-Platform**: Stessa app su tutti i dispositivi
- ✅ **Nessuna Commissione**: Nessun costo per store

## 🔧 Manutenzione

### Rigenerare le Icone:
Se modifichi il logo, rigenera le icone PWA:

```bash
node scripts/generate-pwa-icons.js
```

### Aggiornare il Service Worker:
Il plugin Vite PWA gestisce automaticamente gli aggiornamenti. Ogni nuovo build creerà una nuova versione del service worker.

## 📱 Test Consigliati

Prima del deploy in produzione, testa su:
- ✅ Chrome Desktop
- ✅ Edge Desktop
- ✅ Chrome Android
- ✅ Safari iOS
- ✅ Modalità offline (DevTools → Network → Offline)

## 🆘 Troubleshooting

### L'icona di installazione non appare:
- Verifica che l'app sia servita via HTTPS (o localhost)
- Controlla che il manifest.json sia accessibile
- Verifica che le icone esistano in public/

### Service Worker non si registra:
- Controlla la console del browser per errori
- Verifica che il file sw.js sia generato nel build
- Prova a pulire la cache del browser

### L'app non funziona offline:
- Verifica che il service worker sia attivo in DevTools
- Controlla la strategia di cache in vite.config.ts
- Assicurati di aver visitato l'app almeno una volta online

## 📚 Risorse Utili

- [PWA Documentation](https://web.dev/progressive-web-apps/)
- [Vite PWA Plugin](https://vite-pwa-org.netlify.app/)
- [Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)

---

**🎊 Congratulazioni! La tua app è ora installabile come una PWA!**