# 🎨 Componenti PWA Opzionali

## 📦 Componenti Creati

Sono stati creati due componenti React opzionali per migliorare l'esperienza PWA:

1. **InstallPWA** - Prompt personalizzato per installazione
2. **PWAStatus** - Indicatori per stato offline e aggiornamenti

## 🚀 Come Utilizzarli

### 1. Aggiungere i Componenti all'App

Apri [`src/App.tsx`](../src/App.tsx) e importa i componenti:

```typescript
import { InstallPWA } from './components/InstallPWA';
import { PWAStatus } from './components/PWAStatus';

function App() {
  return (
    <Router>
      {/* I tuoi componenti esistenti */}
      
      {/* Aggiungi questi componenti alla fine */}
      <InstallPWA />
      <PWAStatus />
    </Router>
  );
}
```

### 2. Posizionamento Consigliato

```typescript
// Esempio completo in App.tsx
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { InstallPWA } from './components/InstallPWA';
import { PWAStatus } from './components/PWAStatus';
import { Layout } from './components/Layout';
// ... altri import

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          {/* Le tue route */}
        </Route>
      </Routes>
      
      {/* Componenti PWA - sempre visibili */}
      <InstallPWA />
      <PWAStatus />
    </Router>
  );
}

export default App;
```

## 📱 InstallPWA - Prompt di Installazione

### Funzionalità:

- ✅ **Android/Desktop**: Mostra un banner elegante con pulsante "Installa"
- ✅ **iOS**: Mostra istruzioni passo-passo per installazione manuale
- ✅ **Smart**: Si nasconde automaticamente se l'app è già installata
- ✅ **Persistente**: Ricorda se l'utente ha rifiutato (localStorage)
- ✅ **Ritardato**: Appare dopo 30 secondi per non disturbare subito

### Personalizzazione:

```typescript
// Modifica il delay di apparizione (default: 30000ms = 30 secondi)
setTimeout(() => {
  if (!localStorage.getItem('pwa-prompt-dismissed')) {
    setShowPrompt(true);
  }
}, 10000); // 10 secondi

// Cambia la chiave localStorage per resettare il prompt
localStorage.getItem('pwa-prompt-dismissed-v2')
```

### Styling:

Il componente usa Tailwind CSS. Per personalizzare i colori:

```typescript
// Cambia il colore del pulsante principale
className="bg-black dark:bg-white text-white dark:text-black"
// in
className="bg-blue-600 dark:bg-blue-500 text-white"
```

## 🔔 PWAStatus - Indicatori di Stato

### Funzionalità:

1. **Banner Offline**
   - Appare quando la connessione si interrompe
   - Scompare automaticamente quando torna online
   - Posizionato in alto per massima visibilità

2. **Banner Aggiornamento**
   - Notifica quando è disponibile una nuova versione
   - Pulsante per aggiornare immediatamente
   - Opzione "Dopo" per rimandare

3. **Indicatore Piccolo**
   - Pallino "Offline" in alto a destra
   - Sempre visibile quando offline
   - Non invasivo

### Personalizzazione:

```typescript
// Cambia posizione banner offline
className="fixed top-0 left-0 right-0"
// in
className="fixed bottom-0 left-0 right-0"

// Cambia colore banner offline
className="bg-yellow-500"
// in
className="bg-orange-500"

// Cambia colore banner aggiornamento
className="bg-blue-600"
// in
className="bg-green-600"
```

## 🎨 Esempi di Integrazione

### Esempio 1: Solo Prompt Installazione

Se vuoi solo il prompt di installazione:

```typescript
import { InstallPWA } from './components/InstallPWA';

function App() {
  return (
    <>
      {/* La tua app */}
      <InstallPWA />
    </>
  );
}
```

### Esempio 2: Solo Indicatori Stato

Se vuoi solo gli indicatori di stato:

```typescript
import { PWAStatus } from './components/PWAStatus';

function App() {
  return (
    <>
      {/* La tua app */}
      <PWAStatus />
    </>
  );
}
```

### Esempio 3: Entrambi (Consigliato)

```typescript
import { InstallPWA } from './components/InstallPWA';
import { PWAStatus } from './components/PWAStatus';

function App() {
  return (
    <>
      {/* La tua app */}
      <InstallPWA />
      <PWAStatus />
    </>
  );
}
```

## 🔧 Configurazione Avanzata

### Disabilitare il Prompt su Certe Pagine

```typescript
import { useLocation } from 'react-router-dom';

function App() {
  const location = useLocation();
  const showInstallPrompt = !location.pathname.startsWith('/admin');

  return (
    <>
      {/* La tua app */}
      {showInstallPrompt && <InstallPWA />}
      <PWAStatus />
    </>
  );
}
```

### Trigger Manuale del Prompt

```typescript
// Crea un pulsante personalizzato per mostrare il prompt
import { useState } from 'react';

function CustomInstallButton() {
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);

  useEffect(() => {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      setDeferredPrompt(e);
    });
  }, []);

  const handleClick = async () => {
    if (!deferredPrompt) return;
    await deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    setDeferredPrompt(null);
  };

  if (!deferredPrompt) return null;

  return (
    <button onClick={handleClick}>
      📱 Installa App
    </button>
  );
}
```

### Analytics per Installazioni

```typescript
// In InstallPWA.tsx, aggiungi tracking
const handleInstall = async () => {
  if (!deferredPrompt) return;

  try {
    await deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;

    // Traccia l'evento
    if (outcome === 'accepted') {
      console.log('✅ PWA installata');
      // Aggiungi qui il tuo analytics
      // gtag('event', 'pwa_install', { outcome: 'accepted' });
    } else {
      // gtag('event', 'pwa_install', { outcome: 'dismissed' });
    }

    setDeferredPrompt(null);
    setShowPrompt(false);
    localStorage.setItem('pwa-prompt-dismissed', 'true');
  } catch (error) {
    console.error('Errore installazione PWA:', error);
  }
};
```

## 🎯 Best Practices

### 1. Timing del Prompt

```typescript
// ❌ Non mostrare subito
setTimeout(() => setShowPrompt(true), 0);

// ✅ Aspetta che l'utente esplori l'app
setTimeout(() => setShowPrompt(true), 30000); // 30 secondi

// ✅ Oppure dopo un'azione specifica
const handleUserEngagement = () => {
  if (!localStorage.getItem('pwa-prompt-dismissed')) {
    setShowPrompt(true);
  }
};
```

### 2. Rispetta le Scelte dell'Utente

```typescript
// ✅ Salva la preferenza
localStorage.setItem('pwa-prompt-dismissed', 'true');

// ✅ Opzionale: Mostra di nuovo dopo X giorni
const dismissedDate = localStorage.getItem('pwa-prompt-dismissed-date');
const daysSinceDismissed = (Date.now() - Number(dismissedDate)) / (1000 * 60 * 60 * 24);

if (daysSinceDismissed > 30) {
  // Mostra di nuovo dopo 30 giorni
  localStorage.removeItem('pwa-prompt-dismissed');
}
```

### 3. Test su Dispositivi Reali

```bash
# Build per produzione
npm run build

# Testa localmente
npm run preview

# Testa su mobile (usa ngrok o simili per HTTPS)
npx ngrok http 4173
```

## 🐛 Troubleshooting

### Il prompt non appare su Android

- Verifica che l'app sia servita via HTTPS
- Controlla che il manifest sia valido
- Verifica che le icone esistano
- Controlla la console per errori

### Il prompt non appare su iOS

- iOS non supporta `beforeinstallprompt`
- Il componente mostra automaticamente istruzioni manuali
- Verifica i meta tag apple in [`index.html`](../index.html)

### Gli aggiornamenti non funzionano

- Verifica che il service worker sia registrato
- Controlla che `registerType: 'autoUpdate'` sia in [`vite.config.ts`](../vite.config.ts)
- Pulisci la cache del browser e riprova

### Styling non corretto

- Verifica che Tailwind CSS sia configurato
- Controlla che framer-motion sia installato
- Verifica che non ci siano conflitti CSS

## 📚 Risorse

- [Web.dev - Install Prompt](https://web.dev/customize-install/)
- [MDN - beforeinstallprompt](https://developer.mozilla.org/en-US/docs/Web/API/BeforeInstallPromptEvent)
- [iOS PWA Guide](https://web.dev/apple-touch-icon/)

## ✅ Checklist Implementazione

- [ ] Importare i componenti in App.tsx
- [ ] Testare il prompt su Android/Desktop
- [ ] Testare le istruzioni iOS su Safari
- [ ] Verificare il banner offline
- [ ] Testare il banner aggiornamenti
- [ ] Personalizzare i colori se necessario
- [ ] Aggiungere analytics (opzionale)
- [ ] Testare su dispositivi reali

---

**💡 Nota**: Questi componenti sono completamente opzionali. La PWA funziona perfettamente anche senza di essi, ma migliorano significativamente l'esperienza utente.