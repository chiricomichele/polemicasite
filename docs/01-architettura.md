# Architettura e Framework

## 📋 Indice

1. [Panoramica Architetturale](#panoramica-architetturale)
2. [Stack Tecnologico](#stack-tecnologico)
3. [Struttura del Progetto](#struttura-del-progetto)
4. [Pattern Architetturali](#pattern-architetturali)
5. [Flusso dei Dati](#flusso-dei-dati)
6. [Componenti Principali](#componenti-principali)

---

## Panoramica Architetturale

**Polemica League** è costruita seguendo un'architettura **client-server moderna** con separazione netta tra frontend e backend:

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT (Browser)                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │         React 19 + TypeScript + Vite              │  │
│  │  ┌─────────────┐  ┌──────────────┐               │  │
│  │  │   Pages     │  │  Components  │               │  │
│  │  └─────────────┘  └──────────────┘               │  │
│  │  ┌─────────────┐  ┌──────────────┐               │  │
│  │  │  API Layer  │  │  State Mgmt  │               │  │
│  │  └─────────────┘  └──────────────┘               │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS/REST
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  SUPABASE (Backend)                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database + PostgREST API              │  │
│  │  ┌─────────────┐  ┌──────────────┐               │  │
│  │  │   Tables    │  │    Views     │               │  │
│  │  └─────────────┘  └──────────────┘               │  │
│  │  ┌─────────────┐  ┌──────────────┐               │  │
│  │  │ Edge Funcs  │  │     Auth     │               │  │
│  │  └─────────────┘  └──────────────┘               │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Caratteristiche Architetturali

- **SPA (Single Page Application)**: Navigazione client-side senza ricaricamenti
- **JAMstack**: JavaScript, APIs, Markup - deployment statico con API dinamiche
- **Serverless**: Edge Functions per logica backend complessa
- **Type-Safe**: TypeScript end-to-end con validazione Zod
- **Mobile-First**: Design responsive ottimizzato per dispositivi mobili

---

## Stack Tecnologico

### Frontend Core

#### React 19.2.4
- **Perché React 19**: Ultima versione stabile con miglioramenti di performance
- **Concurrent Features**: Rendering ottimizzato e Suspense
- **Hooks**: Gestione stato e side effects moderna
- **StrictMode**: Abilitato per identificare problemi in sviluppo

#### TypeScript 5.9.3
- **Type Safety**: Prevenzione errori a compile-time
- **IntelliSense**: Autocompletamento e documentazione inline
- **Strict Mode**: Configurazione strict per massima sicurezza
- **Zod Integration**: Validazione runtime con inferenza tipi

#### Vite 8.0.1
- **Build Tool**: Bundler ultra-veloce basato su ESBuild
- **HMR**: Hot Module Replacement istantaneo
- **Dev Server**: Server di sviluppo con proxy integrato
- **Ottimizzazioni**: Tree-shaking, code-splitting automatico

### Routing e Navigazione

#### React Router v7.13.2
```typescript
// Routing structure
<BrowserRouter>
  <Routes>
    {/* Public routes */}
    <Route element={<Layout />}>
      <Route path="/" element={<Home />} />
      <Route path="/giocatori" element={<Giocatori />} />
      <Route path="/profilo/:id" element={<Profilo />} />
      {/* ... */}
    </Route>
    
    {/* Admin routes */}
    <Route path="/admin" element={<AdminLayout />}>
      <Route path="home" element={<AdminHome />} />
      {/* ... */}
    </Route>
  </Routes>
</BrowserRouter>
```

**Features utilizzate**:
- Nested routes con layout condivisi
- Dynamic routing con parametri (`:id`)
- Protected routes per area admin
- Outlet per rendering nested components

### UI e Styling

#### CSS Custom Properties
```css
:root {
  --bg: #121212;           /* Background principale */
  --surface: #1e1e1e;      /* Superfici elevate */
  --accent: #d4ff00;       /* Colore accent (giallo-verde) */
  --danger: #ff3333;       /* Errori e azioni distruttive */
  --text-primary: #ffffff; /* Testo principale */
  --text-secondary: #aaa;  /* Testo secondario */
  --radius: 12px;          /* Border radius standard */
  --max-width: 430px;      /* Larghezza massima mobile */
}
```

**Design System**:
- Dark theme nativo
- Design tokens per consistenza
- Mobile-first approach (max-width: 430px)
- Font: Barlow Condensed (Google Fonts)

#### Framer Motion 12.38.0
- **Animazioni dichiarative**: Transizioni fluide tra stati
- **Layout animations**: Animazioni automatiche su cambio layout
- **Gesture handling**: Swipe, drag, tap
- **Performance**: Ottimizzato per 60fps

#### Recharts 3.8.0
- **Grafici statistici**: Line charts per trend giocatori
- **Responsive**: Adattamento automatico alle dimensioni
- **Customizzabile**: Styling completo dei componenti

### Backend e Database

#### Supabase
**Componenti utilizzati**:

1. **PostgreSQL Database**
   - Database relazionale completo
   - Views materializzate per performance
   - Triggers e stored procedures
   - Full-text search

2. **PostgREST API**
   - API REST auto-generata dal database
   - Row Level Security (RLS)
   - Filtering, sorting, pagination
   - Real-time subscriptions

3. **Edge Functions (Deno)**
   - Logica backend serverless
   - Aggregazioni complesse
   - Calcoli statistici
   - CORS handling

4. **Authentication**
   - Email/password authentication
   - Session management
   - Protected routes

#### Supabase Client (@supabase/supabase-js 2.100.0)
```typescript
// Configurazione client
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

### Validazione e Type Safety

#### Zod 4.3.6
```typescript
// Schema validation example
export const playerSchema = z.object({
  id: z.string(),
  nome: z.string(),
  er: z.number().nullable(),
  tratto: z.string().nullable(),
  player_roles: z.array(playerRoleSchema)
})

export type Player = z.infer<typeof playerSchema>
```

**Utilizzo**:
- Validazione API responses
- Type inference automatica
- Runtime type checking
- Error handling strutturato

### UI Components e Utilities

#### Sonner 2.0.7
- **Toast notifications**: Feedback utente elegante
- **Promise handling**: Toast automatici per operazioni async
- **Customizzabile**: Styling e posizionamento
- **Accessible**: ARIA compliant

---

## Struttura del Progetto

```
polemicasite/
├── public/                    # Asset statici
│   ├── favicon.svg
│   ├── icons.svg             # Sprite SVG icons
│   └── logo.jpeg
│
├── src/
│   ├── main.tsx              # Entry point
│   ├── App.tsx               # Root component con routing
│   ├── index.css             # Global styles e design tokens
│   ├── vite-env.d.ts         # Vite type definitions
│   │
│   ├── api/                  # API layer (data fetching)
│   │   ├── 1vs1.ts          # Rivalità tra giocatori
│   │   ├── admin.ts         # Operazioni admin
│   │   ├── classifiche.ts   # Classifiche e ranking
│   │   ├── news.ts          # Gestione news
│   │   ├── players.ts       # CRUD giocatori
│   │   └── trend.ts         # Trend storici
│   │
│   ├── components/           # Componenti riutilizzabili
│   │   ├── BottomNav.tsx    # Navigazione mobile
│   │   ├── ErrorBoundary.tsx # Error handling
│   │   ├── Layout.tsx       # Layout pubblico
│   │   ├── NewsCard.tsx     # Card per news
│   │   ├── Skeleton.tsx     # Loading states
│   │   └── admin/
│   │       ├── CsvImportModal.tsx
│   │       └── Sidebar.tsx
│   │
│   ├── lib/                  # Utilities e configurazioni
│   │   ├── schemas.ts       # Zod schemas e types
│   │   ├── supabase.ts      # Supabase client
│   │   └── useAuth.ts       # Authentication hook
│   │
│   └── pages/                # Route components
│       ├── Home.tsx
│       ├── Stats.tsx
│       ├── OneVsOne.tsx
│       ├── Profilo.tsx
│       ├── Partite.tsx
│       ├── NewsArchive.tsx
│       ├── Giocatori.tsx
│       ├── Manifesto.tsx
│       └── admin/           # Area amministrativa
│           ├── Layout.tsx
│           ├── Login.tsx
│           ├── Home.tsx
│           ├── Partite.tsx
│           ├── Giocatori.tsx
│           ├── News.tsx
│           ├── Manifesto.tsx
│           └── Rivalita.tsx
│
├── supabase/                 # Backend configuration
│   ├── config.toml          # Supabase local config
│   ├── functions/           # Edge Functions
│   │   ├── _shared/
│   │   │   ├── cors.ts
│   │   │   └── types.ts
│   │   ├── get-1vs1/
│   │   ├── get-classifiche/
│   │   ├── get-player-trend/
│   │   └── import-csv/
│   └── migrations/          # Database migrations
│       ├── 20250101000000_init.sql
│       ├── 20250102000000_public_read.sql
│       └── ...
│
├── docs/                     # Documentazione (questa!)
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── vite.config.ts
└── netlify.toml             # Netlify deployment config
```

### Convenzioni di Naming

- **Componenti**: PascalCase (`PlayerCard.tsx`)
- **Utilities**: camelCase (`useAuth.ts`)
- **API modules**: camelCase (`players.ts`)
- **CSS files**: kebab-case o match component name
- **Types**: PascalCase (`Player`, `Match`)
- **Constants**: UPPER_SNAKE_CASE

---

## Pattern Architetturali

### 1. Separation of Concerns

**API Layer** (`src/api/`)
```typescript
// Responsabilità: Data fetching e trasformazione
export async function getPlayers(): Promise<Player[]> {
  const { data, error } = await supabase
    .from('players')
    .select('id, nome, er, player_roles(ruolo, ordine)')
    .order('nome')
  
  if (error) throw error
  return data as Player[]
}
```

**Components** (`src/components/`, `src/pages/`)
```typescript
// Responsabilità: UI e interazione utente
export function Giocatori() {
  const [players, setPlayers] = useState<Player[]>([])
  
  useEffect(() => {
    getPlayers().then(setPlayers)
  }, [])
  
  return <div>{/* Render UI */}</div>
}
```

### 2. Type Safety End-to-End

```typescript
// 1. Database schema (SQL)
CREATE TABLE players (
  id UUID PRIMARY KEY,
  nome TEXT NOT NULL,
  er NUMERIC
);

// 2. Zod schema (runtime validation)
export const playerSchema = z.object({
  id: z.string(),
  nome: z.string(),
  er: z.number().nullable()
})

// 3. TypeScript type (compile-time)
export type Player = z.infer<typeof playerSchema>

// 4. API function (type-safe)
export async function getPlayer(id: string): Promise<Player> {
  const { data } = await supabase
    .from('players')
    .select('*')
    .eq('id', id)
    .single()
  
  return playerSchema.parse(data) // Runtime validation
}
```

### 3. Component Composition

```typescript
// Layout component con Outlet
export function Layout() {
  return (
    <div className="layout">
      <header>{/* Header */}</header>
      <main>
        <Outlet /> {/* Nested routes render here */}
      </main>
      <BottomNav />
    </div>
  )
}

// Nested routing
<Route element={<Layout />}>
  <Route path="/" element={<Home />} />
  <Route path="/giocatori" element={<Giocatori />} />
</Route>
```

### 4. Error Boundary Pattern

```typescript
export class ErrorBoundary extends Component<Props, State> {
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }
  
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught:', error, errorInfo)
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />
    }
    return this.props.children
  }
}
```

### 5. Custom Hooks Pattern

```typescript
// useAuth hook per gestione autenticazione
export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })
    
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => setUser(session?.user ?? null)
    )
    
    return () => subscription.unsubscribe()
  }, [])
  
  return { user, loading, signIn, signOut }
}
```

---

## Flusso dei Dati

### 1. Data Fetching Flow

```
User Action → Component → API Layer → Supabase Client → PostgreSQL
                ↓                                            ↓
            Loading State                              Query Execution
                ↓                                            ↓
            Skeleton UI                                  Response
                ↓                                            ↓
            Data Received ← Zod Validation ← API Response ←─┘
                ↓
            State Update
                ↓
            UI Render
```

### 2. Authentication Flow

```
Login Form → signIn() → Supabase Auth → Session Created
                                              ↓
                                        Cookie Stored
                                              ↓
                                    onAuthStateChange
                                              ↓
                                        User State Update
                                              ↓
                                    Protected Route Access
```

### 3. Admin Operations Flow

```
Admin Action → Validation → API Call → Edge Function → Database
                                            ↓
                                    Business Logic
                                            ↓
                                    Database Update
                                            ↓
                                    Response
                                            ↓
                                    Toast Notification
                                            ↓
                                    UI Refresh
```

---

## Componenti Principali

### Public Area

#### Home (`src/pages/Home.tsx`)
- Dashboard principale
- Widget news recenti
- Widget Instagram
- Statistiche rapide
- Link navigazione rapida

#### Giocatori (`src/pages/Giocatori.tsx`)
- Lista completa giocatori
- Filtri e ricerca
- Card giocatore con stats
- Link a profilo dettagliato

#### Profilo (`src/pages/Profilo.tsx`)
- Dettagli giocatore
- Grafico trend ER
- Storico partite
- Statistiche aggregate

#### Stats (`src/pages/Stats.tsx`)
- Classifiche generali
- Top scorer
- Top assist
- Migliori medie voto

#### OneVsOne (`src/pages/OneVsOne.tsx`)
- Rivalità tra giocatori
- Head-to-head statistics
- Tag speciali (Derby, Sfida Maestra)

### Admin Area

#### AdminLayout (`src/pages/admin/Layout.tsx`)
- Sidebar navigazione
- Protected routes
- Auth check

#### AdminPartite (`src/pages/admin/Partite.tsx`)
- Import CSV partite
- Gestione match details
- Validazione dati

#### AdminGiocatori (`src/pages/admin/Giocatori.tsx`)
- CRUD giocatori
- Upload avatar
- Gestione ruoli

#### AdminNews (`src/pages/admin/News.tsx`)
- Creazione news
- Editor rich text
- Pubblicazione/draft

---

## Performance Considerations

### Code Splitting
```typescript
// Lazy loading per route pesanti
const AdminLayout = lazy(() => import('./pages/admin/Layout'))

<Suspense fallback={<Skeleton />}>
  <AdminLayout />
</Suspense>
```

### Memoization
```typescript
// Evita re-render non necessari
const MemoizedPlayerCard = memo(PlayerCard)

// Memoizza calcoli costosi
const sortedPlayers = useMemo(
  () => players.sort((a, b) => b.er - a.er),
  [players]
)
```

### Debouncing
```typescript
// Search input con debounce
const debouncedSearch = useMemo(
  () => debounce((value: string) => {
    setSearchTerm(value)
  }, 300),
  []
)
```

---

## Security

### Row Level Security (RLS)
```sql
-- Public read access
CREATE POLICY "Public read access" ON players
  FOR SELECT USING (true);

-- Admin write access
CREATE POLICY "Admin write access" ON players
  FOR ALL USING (auth.role() = 'authenticated');
```

### Environment Variables
```typescript
// Variabili sensibili mai committate
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJxxx...
```

### CORS Configuration
```typescript
// Edge Functions con CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

---

## Prossimi Passi

Continua con:
- [Configurazione e Setup](./02-setup.md) per iniziare lo sviluppo
- [Schema Database](./03-database.md) per comprendere il modello dati
- [API Documentation](./04-api.md) per integrare nuove funzionalità

---

**Ultima modifica**: 2026-03-26