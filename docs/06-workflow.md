# Workflow di Sviluppo

## 📋 Indice

1. [Git Workflow](#git-workflow)
2. [Convenzioni di Codice](#convenzioni-di-codice)
3. [Struttura Commit](#struttura-commit)
4. [Pull Request Process](#pull-request-process)
5. [Code Review](#code-review)
6. [Testing](#testing)
7. [Best Practices](#best-practices)

---

## Git Workflow

### Branch Strategy

**Polemica League** utilizza un workflow semplificato basato su **GitHub Flow**:

```
main (production)
  │
  ├─── feature/add-player-stats
  │
  ├─── fix/login-error
  │
  └─── refactor/api-layer
```

### Branch Types

#### main
- **Scopo**: Branch di produzione
- **Protezione**: ✅ Protected
- **Deploy**: Automatico su Netlify
- **Regole**:
  - No direct push
  - Richiede PR approval
  - CI deve passare

#### feature/*
- **Scopo**: Nuove funzionalità
- **Naming**: `feature/nome-funzionalita`
- **Esempi**:
  - `feature/add-rivalry-page`
  - `feature/player-search`
  - `feature/export-stats`

#### fix/*
- **Scopo**: Bug fixes
- **Naming**: `fix/descrizione-bug`
- **Esempi**:
  - `fix/login-redirect`
  - `fix/chart-rendering`
  - `fix/mobile-layout`

#### refactor/*
- **Scopo**: Refactoring codice
- **Naming**: `refactor/area-refactoring`
- **Esempi**:
  - `refactor/api-layer`
  - `refactor/component-structure`
  - `refactor/database-queries`

### Workflow Completo

```bash
# 1. Aggiorna main locale
git checkout main
git pull origin main

# 2. Crea nuovo branch
git checkout -b feature/add-stats-page

# 3. Sviluppa e committa
git add .
git commit -m "feat: add stats page with charts"

# 4. Push branch
git push origin feature/add-stats-page

# 5. Apri Pull Request su GitHub

# 6. Dopo approval e merge
git checkout main
git pull origin main
git branch -d feature/add-stats-page
```

---

## Convenzioni di Codice

### TypeScript

#### Naming Conventions

```typescript
// ✅ Componenti: PascalCase
export function PlayerCard() {}
export function StatsPage() {}

// ✅ Functions: camelCase
export function getPlayers() {}
export function calculateER() {}

// ✅ Variables: camelCase
const playerData = []
const isLoading = false

// ✅ Constants: UPPER_SNAKE_CASE
const MAX_PLAYERS = 100
const API_ENDPOINT = '/api/players'

// ✅ Types/Interfaces: PascalCase
type Player = {}
interface PlayerStats {}

// ✅ Private: prefix con _
class Service {
  private _cache = new Map()
}
```

#### File Naming

```
✅ Componenti:     PlayerCard.tsx
✅ Pages:          Home.tsx, Stats.tsx
✅ Utilities:      useAuth.ts, supabase.ts
✅ API modules:    players.ts, classifiche.ts
✅ Types:          schemas.ts, types.ts
```

#### Import Order

```typescript
// 1. React imports
import { useState, useEffect } from 'react'

// 2. External libraries
import { motion } from 'framer-motion'
import { toast } from 'sonner'

// 3. Internal utilities
import { supabase } from '../lib/supabase'
import { useAuth } from '../lib/useAuth'

// 4. Components
import { PlayerCard } from '../components/PlayerCard'
import { Skeleton } from '../components/Skeleton'

// 5. Types
import type { Player } from '../lib/schemas'

// 6. Styles (se necessario)
import './styles.css'
```

### React Components

#### Functional Components

```typescript
// ✅ Preferisci function declaration
export function PlayerCard({ player }: Props) {
  return <div>{player.nome}</div>
}

// ❌ Evita arrow function per componenti
export const PlayerCard = ({ player }: Props) => {
  return <div>{player.nome}</div>
}
```

#### Props Types

```typescript
// ✅ Definisci type per props
type PlayerCardProps = {
  player: Player
  onSelect?: (id: string) => void
  className?: string
}

export function PlayerCard({ player, onSelect, className }: PlayerCardProps) {
  // ...
}
```

#### Hooks Order

```typescript
export function PlayersList() {
  // 1. State hooks
  const [players, setPlayers] = useState<Player[]>([])
  const [loading, setLoading] = useState(true)
  
  // 2. Context hooks
  const { user } = useAuth()
  
  // 3. Ref hooks
  const inputRef = useRef<HTMLInputElement>(null)
  
  // 4. Effect hooks
  useEffect(() => {
    loadPlayers()
  }, [])
  
  // 5. Custom hooks
  const { data, error } = usePlayerData()
  
  // 6. Callbacks
  const handleSelect = useCallback((id: string) => {
    // ...
  }, [])
  
  // 7. Memoized values
  const sortedPlayers = useMemo(() => {
    return players.sort((a, b) => b.er - a.er)
  }, [players])
  
  // 8. Render
  return <div>{/* ... */}</div>
}
```

### CSS

#### Design Tokens

```css
/* ✅ Usa CSS variables */
.card {
  background: var(--surface);
  color: var(--text-primary);
  border-radius: var(--radius);
}

/* ❌ Evita valori hardcoded */
.card {
  background: #1e1e1e;
  color: #ffffff;
  border-radius: 12px;
}
```

#### Class Naming

```css
/* ✅ BEM-like naming */
.player-card {}
.player-card__header {}
.player-card__stats {}
.player-card--highlighted {}

/* ✅ Utility classes */
.flex {}
.grid {}
.text-center {}
```

---

## Struttura Commit

### Conventional Commits

Usa il formato [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

```bash
feat:     # Nuova funzionalità
fix:      # Bug fix
docs:     # Documentazione
style:    # Formattazione, missing semi colons, etc
refactor: # Refactoring codice
perf:     # Performance improvements
test:     # Aggiunta test
chore:    # Maintenance tasks
```

### Esempi

```bash
# Feature
feat(players): add player search functionality

# Bug fix
fix(auth): resolve login redirect issue

# Documentation
docs: update API documentation

# Refactoring
refactor(api): simplify player data fetching

# Performance
perf(charts): optimize rendering with memoization

# Multiple files
feat(stats): add new statistics page
- Add Stats component
- Create stats API endpoint
- Update navigation

# Breaking change
feat(api)!: change player schema structure

BREAKING CHANGE: player.roles is now player.player_roles
```

### Commit Best Practices

```bash
# ✅ Atomic commits
git commit -m "feat: add player card component"
git commit -m "style: add player card styles"

# ❌ Evita commit troppo grandi
git commit -m "add everything"

# ✅ Commit frequenti
# Committa ogni logical change

# ✅ Messaggi descrittivi
git commit -m "fix: resolve null pointer in player stats calculation"

# ❌ Messaggi vaghi
git commit -m "fix stuff"
```

---

## Pull Request Process

### 1. Crea Pull Request

#### Template PR

```markdown
## Descrizione
Breve descrizione delle modifiche

## Tipo di Change
- [ ] Bug fix
- [ ] Nuova feature
- [ ] Breaking change
- [ ] Documentazione

## Checklist
- [ ] Il codice compila senza errori
- [ ] Ho testato le modifiche localmente
- [ ] Ho aggiornato la documentazione
- [ ] Ho seguito le convenzioni di codice
- [ ] Non ci sono console.log dimenticati

## Screenshot (se applicabile)
[Aggiungi screenshot]

## Note Aggiuntive
Eventuali note per i reviewer
```

### 2. PR Title

```bash
# ✅ Segui conventional commits
feat: add player statistics page
fix: resolve login redirect issue
docs: update deployment guide

# ❌ Evita titoli vaghi
Update files
Fix bug
Changes
```

### 3. PR Description

```markdown
## Cosa fa questa PR?
Aggiunge una nuova pagina per visualizzare statistiche dettagliate dei giocatori.

## Come è stato implementato?
- Creato componente `Stats.tsx`
- Aggiunto endpoint API `getPlayerStats()`
- Integrato con Recharts per grafici

## Testing
- ✅ Testato su Chrome, Firefox, Safari
- ✅ Testato su mobile (iOS, Android)
- ✅ Verificato con dati reali

## Screenshots
[Aggiungi screenshot della nuova pagina]
```

### 4. Link Issues

```markdown
Closes #123
Fixes #456
Related to #789
```

---

## Code Review

### Reviewer Checklist

#### Funzionalità
- [ ] Il codice fa quello che dovrebbe fare?
- [ ] Ci sono edge cases non gestiti?
- [ ] L'UX è intuitiva?

#### Codice
- [ ] Il codice è leggibile e manutenibile?
- [ ] Segue le convenzioni del progetto?
- [ ] Ci sono duplicazioni evitabili?
- [ ] Le funzioni sono troppo lunghe?

#### Performance
- [ ] Ci sono operazioni costose non necessarie?
- [ ] I componenti sono memoizzati dove serve?
- [ ] Le query database sono ottimizzate?

#### Sicurezza
- [ ] Input utente è validato?
- [ ] Dati sensibili sono protetti?
- [ ] RLS policies sono corrette?

#### Testing
- [ ] Il codice è testabile?
- [ ] Ci sono test per i casi critici?
- [ ] I test passano?

### Review Comments

```typescript
// ✅ Commenti costruttivi
// Suggestion: Considera di estrarre questa logica in una funzione separata
// per migliorare la leggibilità

// Question: Questo gestisce il caso in cui player è null?

// Nit: Typo nel nome della variabile (palyer → player)

// ❌ Commenti non costruttivi
// Questo fa schifo
// Non mi piace
```

### Approval Process

```
┌─────────────────┐
│  PR Created     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  CI Checks      │
│  - Lint         │
│  - Build        │
│  - Tests        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Code Review    │
│  - 1+ approvals │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Merge to main  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Auto Deploy    │
│  to Production  │
└─────────────────┘
```

---

## Testing

### Manual Testing

#### Checklist Pre-Commit

```bash
# 1. Build locale
npm run build

# 2. Lint
npm run lint

# 3. Type check
npx tsc --noEmit

# 4. Test in browser
npm run dev
# Testa funzionalità modificate

# 5. Test su mobile
# Usa DevTools responsive mode
```

#### Browser Testing

```
✅ Chrome (latest)
✅ Firefox (latest)
✅ Safari (latest)
✅ Mobile Safari (iOS)
✅ Chrome Mobile (Android)
```

### Unit Testing (Future)

```typescript
// Esempio con Vitest
import { describe, it, expect } from 'vitest'
import { calculateER } from './utils'

describe('calculateER', () => {
  it('calculates ER correctly', () => {
    const result = calculateER(10, 5, 100)
    expect(result).toBe(0.15)
  })

  it('handles zero ER sum', () => {
    const result = calculateER(10, 5, 0)
    expect(result).toBe(null)
  })
})
```

### E2E Testing (Future)

```typescript
// Esempio con Playwright
import { test, expect } from '@playwright/test'

test('user can view player profile', async ({ page }) => {
  await page.goto('/giocatori')
  await page.click('text=Mario Rossi')
  await expect(page).toHaveURL(/\/profilo\//)
  await expect(page.locator('h1')).toContainText('Mario Rossi')
})
```

---

## Best Practices

### 1. Keep It Simple

```typescript
// ✅ Semplice e leggibile
function getPlayerName(player: Player): string {
  return player.nome
}

// ❌ Over-engineered
function getPlayerName(player: Player): string {
  return player?.nome ?? player?.soprannome ?? 'Unknown'
}
// (se non serve tutta questa logica)
```

### 2. Single Responsibility

```typescript
// ✅ Una responsabilità per funzione
function fetchPlayers() {
  return supabase.from('players').select('*')
}

function sortPlayers(players: Player[]) {
  return players.sort((a, b) => b.er - a.er)
}

// ❌ Troppe responsabilità
function fetchAndSortPlayers() {
  const players = supabase.from('players').select('*')
  return players.sort((a, b) => b.er - a.er)
}
```

### 3. DRY (Don't Repeat Yourself)

```typescript
// ✅ Estrai logica comune
function formatDate(date: string) {
  return new Date(date).toLocaleDateString('it-IT')
}

// Usa ovunque
const formattedDate = formatDate(player.created_at)

// ❌ Duplicazione
const date1 = new Date(player1.created_at).toLocaleDateString('it-IT')
const date2 = new Date(player2.created_at).toLocaleDateString('it-IT')
```

### 4. Error Handling

```typescript
// ✅ Gestisci errori appropriatamente
async function loadPlayers() {
  try {
    const players = await getPlayers()
    setPlayers(players)
  } catch (error) {
    console.error('Failed to load players:', error)
    toast.error('Errore nel caricamento giocatori')
    setError(error.message)
  } finally {
    setLoading(false)
  }
}

// ❌ Ignora errori
async function loadPlayers() {
  const players = await getPlayers()
  setPlayers(players)
}
```

### 5. Type Safety

```typescript
// ✅ Usa tipi specifici
type PlayerStatus = 'active' | 'inactive' | 'injured'

function updateStatus(status: PlayerStatus) {
  // TypeScript previene errori
}

// ❌ Usa any o string generici
function updateStatus(status: string) {
  // Nessuna type safety
}
```

### 6. Performance

```typescript
// ✅ Memoizza calcoli costosi
const sortedPlayers = useMemo(
  () => players.sort((a, b) => b.er - a.er),
  [players]
)

// ✅ Usa callback per evitare re-render
const handleClick = useCallback((id: string) => {
  selectPlayer(id)
}, [selectPlayer])

// ✅ Lazy load componenti pesanti
const AdminPanel = lazy(() => import('./AdminPanel'))
```

### 7. Accessibility

```typescript
// ✅ Usa semantic HTML
<button onClick={handleClick}>Click me</button>

// ❌ Evita div clickabili
<div onClick={handleClick}>Click me</div>

// ✅ Aggiungi ARIA labels
<button aria-label="Chiudi modale" onClick={close}>
  ×
</button>

// ✅ Gestisci keyboard navigation
<div
  role="button"
  tabIndex={0}
  onKeyDown={(e) => e.key === 'Enter' && handleClick()}
  onClick={handleClick}
>
  Click me
</div>
```

### 8. Documentation

```typescript
/**
 * Calcola l'Efficiency Rating di un giocatore
 * 
 * @param gol - Numero di gol segnati
 * @param assist - Numero di assist
 * @param erSum - Somma degli ER delle partite
 * @returns ER calcolato o null se erSum è 0
 * 
 * @example
 * ```ts
 * const er = calculateER(10, 5, 100)
 * // Returns: 0.15
 * ```
 */
export function calculateER(
  gol: number,
  assist: number,
  erSum: number
): number | null {
  if (erSum === 0) return null
  return (gol + assist) / erSum
}
```

---

## Risorse Utili

### Documentazione
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Supabase Docs](https://supabase.com/docs)
- [Vite Guide](https://vitejs.dev/guide/)

### Tools
- [ESLint](https://eslint.org/) - Linting
- [Prettier](https://prettier.io/) - Code formatting
- [TypeScript](https://www.typescriptlang.org/) - Type checking

### Git
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Best Practices](https://git-scm.com/book/en/v2)

---

## Conclusione

Seguendo questo workflow:
- ✅ Codice consistente e manutenibile
- ✅ Review process efficiente
- ✅ Deploy sicuri e tracciabili
- ✅ Team collaboration fluida

Per domande o suggerimenti, apri una issue su GitHub!

---

**Ultima modifica**: 2026-03-26