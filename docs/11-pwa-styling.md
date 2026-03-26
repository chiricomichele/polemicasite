# 🎨 PWA - Styling Personalizzato

## Design System Applicato

I componenti PWA sono stati completamente adattati al design system di Polemica League:

### 🎨 Colori Utilizzati

```css
--bg: #121212           /* Sfondo principale */
--surface: #1e1e1e      /* Superfici/card */
--accent: #d4ff00       /* Giallo neon - CTA e accenti */
--text-primary: #ffffff /* Testo principale */
--text-secondary: #aaaaaa /* Testo secondario */
--radius: 12px          /* Border radius */
```

## 📱 InstallPWA - Banner Installazione

### Design Caratteristiche:
- ✅ **Sfondo**: `var(--surface)` con bordo accent sottile
- ✅ **Posizione**: Bottom (sopra la nav), centrato, max-width 430px
- ✅ **Pulsante CTA**: Giallo neon (#d4ff00) su sfondo scuro
- ✅ **Animazione**: Spring smooth, non invasiva
- ✅ **Timing**: Appare dopo 60 secondi (non disturba subito)
- ✅ **Persistenza**: Ricorda se l'utente ha rifiutato

### Differenze iOS vs Android:
- **Android/Desktop**: Pulsante "Installa" con accent color
- **iOS**: Istruzioni compatte con emoji e accent color per highlight

### Esempio Visivo:
```
┌─────────────────────────────────────┐
│ 🖼️  📱 Installa l'app          ✕   │
│     Accesso rapido e offline        │
│                                     │
│ [  Installa  ]  [  Dopo  ]         │
└─────────────────────────────────────┘
```

## 🔔 PWAStatus - Indicatori di Stato

### 1. Banner Offline (Top)
- **Design**: Barra sottile in alto, semi-trasparente
- **Colore**: Surface scuro con bordo accent
- **Icona**: 📡 con accent color
- **Timing**: Appare dopo 2 secondi offline (evita flash)
- **Posizione**: Fixed top, full width

### 2. Banner Aggiornamento (Bottom)
- **Design**: Card elegante come InstallPWA
- **Icona**: Cerchio con icona refresh in accent color
- **Pulsanti**: Stesso stile di InstallPWA
- **Posizione**: Bottom, sopra nav

### 3. Indicatore Piccolo (Top Right)
- **Design**: Pillola piccola e discreta
- **Animazione**: Pulse sull'icona
- **Colore**: Surface con bordo accent
- **Posizione**: Fixed top-right

### Esempio Visivo:
```
Top:
┌─────────────────────────────────────┐
│ 📡 Modalità offline                 │
└─────────────────────────────────────┘

Top Right (piccolo):
                              ┌──────────┐
                              │ ● Offline│
                              └──────────┘

Bottom:
┌─────────────────────────────────────┐
│ 🔄  Aggiornamento disponibile  ✕   │
│     Nuove funzionalità              │
│                                     │
│ [Aggiorna ora]  [  Dopo  ]         │
└─────────────────────────────────────┘
```

## 🎯 Principi di Design Applicati

### 1. Non Invasivo
- ❌ NO popup centrali che bloccano
- ❌ NO animazioni aggressive
- ✅ Banner discreti ai bordi
- ✅ Facilmente dismissibili
- ✅ Timing ritardato (60s per install, 2s per offline)

### 2. Coerenza Visiva
- ✅ Stesso border-radius (12px)
- ✅ Stessi colori del design system
- ✅ Stesso font (Barlow Condensed)
- ✅ Stessa palette accent (giallo neon)
- ✅ Stesso stile pulsanti

### 3. Responsive
- ✅ Max-width 430px (come il layout)
- ✅ Padding laterale 1rem
- ✅ Centrato automaticamente
- ✅ Si adatta a schermi piccoli

### 4. Accessibilità
- ✅ Contrasto colori WCAG AA
- ✅ Pulsanti con area touch adeguata (min 44px)
- ✅ Aria-labels per screen reader
- ✅ Focus states visibili

## Perfetto! Ora creo un documento di riepilogo finale con tutte le modifiche fatte per adattare i banner al tuo stile:

<write_to_file>
<path>docs/11-pwa-styling.md</path>
<content>
# 🎨 PWA - Styling Personalizzato

## Design System Applicato

I componenti PWA sono stati completamente adattati al design system di Polemica League:

### 🎨 Colori Utilizzati

```css
--bg: #121212           /* Sfondo principale */
--surface: #1e1e1e      /* Superfici/card */
--accent: #d4ff00       /* Giallo neon - CTA e accenti */
--text-primary: #ffffff /* Testo principale */
--text-secondary: #aaaaaa /* Testo secondario */
--radius: 12px          /* Border radius */
```

## 📱 InstallPWA - Banner Installazione

### Design Caratteristiche:
- ✅ **Sfondo**: `var(--surface)` con bordo accent sottile
- ✅ **Posizione**: Bottom (sopra la nav), centrato, max-width 430px
- ✅ **Pulsante CTA**: Giallo neon (#d4ff00) su sfondo scuro
- ✅ **Animazione**: Spring smooth, non invasiva
- ✅ **Timing**: Appare dopo 60 secondi (non disturba subito)
- ✅ **Persistenza**: Ricorda se l'utente ha rifiutato

### Differenze iOS vs Android:
- **Android/Desktop**: Pulsante "Installa" con accent color
- **iOS**: Istruzioni compatte con emoji e accent color per highlight

### Esempio Visivo:
```
┌─────────────────────────────────────┐
│ 🖼️  📱 Installa l'app          ✕   │
│     Accesso rapido e offline        │
│                                     │
│ [  Installa  ]  [  Dopo  ]         │
└─────────────────────────────────────┘
```

## 🔔 PWAStatus - Indicatori di Stato

### 1. Banner Offline (Top)
- **Design**: Barra sottile in alto, semi-trasparente
- **Colore**: Surface scuro con bordo accent
- **Icona**: 📡 con accent color
- **Timing**: Appare dopo 2 secondi offline (evita flash)
- **Posizione**: Fixed top, full width

### 2. Banner Aggiornamento (Bottom)
- **Design**: Card elegante come InstallPWA
- **Icona**: Cerchio con icona refresh in accent color
- **Pulsanti**: Stesso stile di InstallPWA
- **Posizione**: Bottom, sopra nav

### 3. Indicatore Piccolo (Top Right)
- **Design**: Pillola piccola e discreta
- **Animazione**: Pulse sull'icona
- **Colore**: Surface con bordo accent
- **Posizione**: Fixed top-right

### Esempio Visivo:
```
Top:
┌─────────────────────────────────────┐
│ 📡 Modalità offline                 │
└─────────────────────────────────────┘

Top Right (piccolo):
                              ┌──────────┐
                              │ ● Offline│
                              └──────────┘

Bottom:
┌─────────────────────────────────────┐
│ 🔄  Aggiornamento disponibile  ✕   │
│     Nuove funzionalità              │
│                                     │
│ [Aggiorna ora]  [  Dopo  ]         │
└─────────────────────────────────────┘
```

## 🎯 Principi di Design Applicati

### 1. Non Invasivo
- ❌ NO popup centrali che bloccano
- ❌ NO animazioni aggressive
- ✅ Banner discreti ai bordi
- ✅ Facilmente dismissibili
- ✅ Timing ritardato (60s per install, 2s per offline)

### 2. Coerenza Visiva
- ✅ Stesso border-radius (12px)
- ✅ Stessi colori del design system
- ✅ Stesso font (Barlow Condensed)
- ✅ Stessa palette accent (giallo neon)
- ✅ Stesso stile pulsanti

### 3. Responsive
- ✅ Max-width 430px (come il layout)
- ✅ Padding laterale 1rem
- ✅ Centrato automaticamente
- ✅ Si adatta a schermi piccoli

### 4. Accessibilità
- ✅ Contrasto colori WCAG AA
- ✅ Pulsanti con area touch adeguata (min 44px)
- ✅ Aria-labels per screen reader
- ✅ Focus states visibili

## 🔧 Personalizzazione

### Come Modificare i Colori

```css
/* In src/index.css */
:root {
  --accent: #d4ff00; /* Cambia questo per modificare tutti i CTA */
  --surface: #1e1e1e; /* Cambia questo per sfondi */
}
```

### Come Modificare i Timing

```typescript
// In InstallPWA.tsx
// Cambia 60000 (60 secondi) per modificare quando appare
setTimeout(() => {
  if (!localStorage.getItem('pwa-prompt-dismissed')) {
    setShowPrompt(true);
  }
}, 60000); // 60 secondi
```

### Come Modificare le Posizioni

```typescript
// In InstallPWA.tsx
// Cambia bottom: '5.5rem' per modificare posizione verticale
style={{
  position: 'fixed',
  bottom: '5.5rem', // Alza/abbassa qui
  left: '1rem',
  right: '1rem',
  // ...
}}
```

## 📊 Confronto con Ads

### ❌ Cose che NON facciamo (come le ads):
- Animazioni lampeggianti
- Popup centrali che bloccano
- Suoni automatici
- Auto-play video
- Testo in grassetto rosso
- Timer di countdown
- Pulsanti "X" nascosti
- Testo "URGENTE" o "OFFERTA LIMITATA"

### ✅ Cose che facciamo (buon UX):
- Animazioni fluide e lente
- Posizionamento ai bordi
- Colori coerenti con l'app
- Testo informativo, non aggressivo
- Facilmente dismissibili
- Rispetto delle scelte utente
- Timing ritardato

## 🧪 Test di Usabilità

### 1. Test su Mobile
- Verifica che i banner non coprano contenuti importanti
- Verifica che siano facilmente chiudibili
- Verifica che non disturbino la navigazione

### 2. Test su Desktop
- Verifica che siano posizionati correttamente
- Verifica che non interferiscano con la nav
- Verifica che siano leggibili

### 3. Test Offline
- Verifica che il banner offline appaia correttamente
- Verifica che scompaia quando torna online
- Verifica che non ci siano flash

## 🎨 Esempi di Codice

### Pulsante CTA (Accent Color)
```typescript
<button style={{
  background: 'var(--accent)', // Giallo neon
  color: 'var(--bg)', // Testo scuro
  borderRadius: '8px', // Coerente con design
  fontWeight: 600, // Grassetto
  transition: 'opacity 0.2s', // Smooth hover
}}>
  Installa
</button>
```

### Card Surface
```typescript
<div style={{
  background: 'var(--surface)', // Sfondo scuro
  border: '1px solid rgba(212, 255, 0, 0.2)', // Bordo accent
  borderRadius: 'var(--radius)', // 12px
  boxShadow: '0 4px 20px rgba(0, 0, 0, 0.5)', // Ombra
}}>
  {/* Contenuto */}
</div>
```

## 📚 Risorse

- [MDN - CSS Variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)
- [Google - PWA UX Guidelines](https://web.dev/pwa-ux/)
- [Apple - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**✅ I banner sono ora completamente integrati nel design system di Polemica League!**

I componenti sono eleganti, discreti e seguono perfettamente lo stile dark con accenti giallo neon.