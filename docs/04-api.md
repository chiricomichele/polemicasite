# API e Integrazioni

## 📋 Indice

1. [Panoramica API](#panoramica-api)
2. [Supabase Client API](#supabase-client-api)
3. [Edge Functions](#edge-functions)
4. [API Layer Frontend](#api-layer-frontend)
5. [Autenticazione](#autenticazione)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)

---

## Panoramica API

**Polemica League** utilizza un'architettura API ibrida:

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  API LAYER (src/api/)                    │
│  • players.ts    • classifiche.ts    • news.ts          │
│  • 1vs1.ts       • trend.ts          • admin.ts         │
└─────────────────────────────────────────────────────────┘
                          │
            ┌─────────────┴─────────────┐
            ▼                           ▼
┌─────────────────────┐    ┌─────────────────────────┐
│  SUPABASE CLIENT    │    │   EDGE FUNCTIONS        │
│  (PostgREST API)    │    │   (Deno Runtime)        │
│                     │    │                         │
│  • Direct queries   │    │  • Complex aggregations │
│  • CRUD operations  │    │  • Business logic       │
│  • Real-time subs   │    │  • Custom endpoints     │
└─────────────────────┘    └─────────────────────────┘
            │                           │
            └─────────────┬─────────────┘
                          ▼
            ┌─────────────────────────┐
            │   POSTGRESQL DATABASE   │
            └─────────────────────────┘
```

### Quando Usare Cosa

**Supabase Client (PostgREST)**:
- ✅ Query semplici (SELECT, INSERT, UPDATE, DELETE)
- ✅ Filtri e ordinamenti standard
- ✅ Relazioni con JOIN automatici
- ✅ Real-time subscriptions
- ✅ Row Level Security automatico

**Edge Functions**:
- ✅ Aggregazioni complesse
- ✅ Calcoli statistici avanzati
- ✅ Logica business custom
- ✅ Operazioni su più tabelle
- ✅ Trasformazioni dati complesse

---

## Supabase Client API

### Configurazione

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

### Query Base

#### SELECT

```typescript
// Tutti i giocatori
const { data, error } = await supabase
  .from('players')
  .select('*')

// Con filtri
const { data, error } = await supabase
  .from('players')
  .select('*')
  .eq('nome', 'Mario Rossi')
  .gte('er', 80)
  .order('er', { ascending: false })

// Con JOIN (relazioni)
const { data, error } = await supabase
  .from('players')
  .select(`
    id,
    nome,
    er,
    player_roles (
      ruolo,
      ordine
    )
  `)
  .order('nome')
```

#### INSERT

```typescript
// Singolo record
const { data, error } = await supabase
  .from('players')
  .insert({
    nome: 'Nuovo Giocatore',
    er: 75.0,
    tratto: 'Il Veloce'
  })
  .select()

// Multipli record
const { data, error } = await supabase
  .from('player_roles')
  .insert([
    { player_id: 'uuid', ruolo: 'ATT', ordine: 1 },
    { player_id: 'uuid', ruolo: 'CC', ordine: 2 }
  ])
```

#### UPDATE

```typescript
// Update con filtro
const { data, error } = await supabase
  .from('players')
  .update({ er: 85.5 })
  .eq('id', playerId)
  .select()

// Update multipli
const { data, error } = await supabase
  .from('players')
  .update({ tenore_fisico: 'Buona' })
  .in('id', [id1, id2, id3])
```

#### DELETE

```typescript
// Delete con filtro
const { data, error } = await supabase
  .from('players')
  .delete()
  .eq('id', playerId)

// Delete con CASCADE automatico
// (elimina anche player_roles, match_details, etc.)
```

### Operatori Avanzati

```typescript
// Operatori di confronto
.eq('campo', valore)        // uguale
.neq('campo', valore)       // diverso
.gt('campo', valore)        // maggiore
.gte('campo', valore)       // maggiore o uguale
.lt('campo', valore)        // minore
.lte('campo', valore)       // minore o uguale

// Operatori di pattern
.like('nome', '%Mario%')    // LIKE SQL
.ilike('nome', '%mario%')   // LIKE case-insensitive
.match({ nome: 'Mario', er: 85 })  // AND multipli

// Operatori di array
.in('id', [id1, id2, id3])  // IN
.contains('tags', ['tag1']) // array contains

// Operatori NULL
.is('campo', null)          // IS NULL
.not('campo', 'is', null)   // IS NOT NULL

// Operatori logici
.or('er.gt.80,gol_totali.gt.10')  // OR
```

### Paginazione

```typescript
const page = 1
const limit = 20
const from = (page - 1) * limit
const to = from + limit - 1

const { data, error, count } = await supabase
  .from('players')
  .select('*', { count: 'exact' })
  .range(from, to)
  .order('nome')

// count contiene il totale record
// data contiene solo i record della pagina
```

### Real-time Subscriptions

```typescript
// Subscribe a cambiamenti
const channel = supabase
  .channel('players-changes')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE, o '*' per tutti
      schema: 'public',
      table: 'players'
    },
    (payload) => {
      console.log('Change received!', payload)
      // Aggiorna UI
    }
  )
  .subscribe()

// Cleanup
channel.unsubscribe()
```

---

## Edge Functions

### Architettura Edge Functions

```
supabase/functions/
├── _shared/
│   ├── cors.ts          # CORS handling
│   └── types.ts         # TypeScript types
├── get-classifiche/
│   └── index.ts         # Classifiche aggregate
├── get-1vs1/
│   └── index.ts         # Rivalità head-to-head
├── get-player-trend/
│   └── index.ts         # Trend giocatore
└── import-csv/
    └── index.ts         # Import CSV partite
```

### 1. get-classifiche

**Endpoint**: `https://[project].supabase.co/functions/v1/get-classifiche`

**Parametri**:
- `type`: `gcp` | `voto` | `marcatori` (default: `gcp`)
- `page`: numero pagina (default: `1`)
- `limit`: record per pagina (default: `50`, max: `100`)

**Esempio Request**:
```typescript
const response = await fetch(
  `${supabaseUrl}/functions/v1/get-classifiche?type=marcatori&page=1&limit=20`,
  {
    headers: {
      'Authorization': `Bearer ${anonKey}`
    }
  }
)
const data = await response.json()
```

**Response**:
```typescript
{
  data: [
    {
      id: "uuid",
      nome: "Mario Rossi",
      presenze: 15,
      gol_totali: 12,
      assist_totali: 8,
      media_voto: 7.5,
      plus_minus: 10,
      streak: "3V",        // 3 vittorie consecutive
      last_5: ["V","V","V","P","S"]
    },
    // ...
  ],
  page: 1,
  limit: 20,
  total: 45
}
```

**Logica**:
1. Query view `v_gcp` per dati aggregati
2. Ordina per metrica richiesta (gcp/voto/marcatori)
3. Calcola streak da ultimi 5 risultati
4. Applica paginazione
5. Ritorna dati formattati

### 2. get-1vs1

**Endpoint**: `https://[project].supabase.co/functions/v1/get-1vs1`

**Parametri**:
- `id1`: UUID primo giocatore (required)
- `id2`: UUID secondo giocatore (required)

**Esempio Request**:
```typescript
const response = await fetch(
  `${supabaseUrl}/functions/v1/get-1vs1?id1=${player1Id}&id2=${player2Id}`,
  {
    headers: {
      'Authorization': `Bearer ${anonKey}`
    }
  }
)
const data = await response.json()
```

**Response**:
```typescript
{
  player1: {
    id: "uuid1",
    nome: "Mario Rossi"
  },
  player2: {
    id: "uuid2",
    nome: "Luigi Verdi"
  },
  tag: "LA SFIDA MAESTRA",  // o null
  stats: {
    partite_insieme: 10,
    vittorie_insieme: 7,
    sconfitte_insieme: 2,
    partite_contro: 5,
    vittorie_g1: 3,
    vittorie_g2: 2,
    totale_partite: 15
  }
}
```

**Logica**:
1. Verifica esistenza entrambi giocatori
2. Cerca rivalità esistente in tabella `rivalries`
3. Calcola statistiche da `match_details`:
   - Trova giornate dove entrambi hanno giocato
   - Conta partite insieme (stessa squadra)
   - Conta partite contro (squadre opposte)
   - Calcola vittorie per ciascuno
4. Ritorna dati con tag se presente

### 3. get-player-trend

**Endpoint**: `https://[project].supabase.co/functions/v1/get-player-trend`

**Parametri**:
- `id`: UUID giocatore (required)

**Esempio Request**:
```typescript
const response = await fetch(
  `${supabaseUrl}/functions/v1/get-player-trend?id=${playerId}`,
  {
    headers: {
      'Authorization': `Bearer ${anonKey}`
    }
  }
)
const data = await response.json()
```

**Response**:
```typescript
{
  player: {
    id: "uuid",
    nome: "Mario Rossi",
    er: 85.5,
    tratto: "Il Capitano",
    player_roles: [
      { ruolo: "CC", ordine: 1 },
      { ruolo: "TD", ordine: 2 }
    ]
  },
  stats: {
    presenze: 15,
    gol_totali: 12,
    assist_totali: 8,
    media_voto: 7.5,
    gcp: 0.234,
    plus_minus: 10
  },
  streak: ["V","V","P","S","V"],
  trend: [
    {
      player_id: "uuid",
      giornata: 1,
      data: "2025-01-15",
      er: 82.0,
      voto: 7.0,
      gol: 1,
      assist: 0,
      risultato: "V",
      differenza_reti: 2
    },
    // ... una entry per giornata
  ]
}
```

**Logica**:
1. Query view `v_player_trend` per storico
2. Query tabella `players` per info giocatore
3. Calcola aggregati:
   - Presenze totali
   - Gol e assist totali
   - Media voto (esclude NULL)
   - GCP: (gol + assist) / sum(er)
   - Plus/minus: somma differenze reti
4. Estrae ultimi 5 risultati per streak
5. Ritorna tutto insieme

### 4. import-csv

**Endpoint**: `https://[project].supabase.co/functions/v1/import-csv`

**Method**: POST

**Body**:
```typescript
{
  csv: "data,giornata,campo,ora,squadra,nome,er,gol,autogol,assist,voto,gol_squadra,gol_avversari,risultato,differenza_reti\n2025-01-15,1,Campo A,20:30,A,Mario Rossi,85.5,2,0,1,8.5,5,3,V,2\n...",
  tipo: "dettaglio" | "rating" | "voti" | "1vs1"
}
```

**Response**:
```typescript
{
  success: true,
  inserted: 45,
  errors: []
}
```

**Logica**:
1. Parse CSV
2. Valida formato e dati
3. Match nomi giocatori con database
4. Insert batch in tabella appropriata
5. Ritorna risultato con eventuali errori

---

## API Layer Frontend

### Struttura

```
src/api/
├── players.ts       # CRUD giocatori
├── classifiche.ts   # Classifiche e ranking
├── 1vs1.ts          # Rivalità
├── trend.ts         # Trend giocatori
├── news.ts          # Gestione news
└── admin.ts         # Operazioni admin
```

### players.ts

```typescript
import { supabase } from '../lib/supabase'
import type { Player } from '../lib/schemas'

// Get all players
export async function getPlayers(): Promise<Player[]> {
  const { data, error } = await supabase
    .from('players')
    .select('id, nome, soprannome, avatar_url, er, tratto, tenore_fisico, base_rating, last_er, delta_rating, player_roles(ruolo, ordine)')
    .order('nome')

  if (error) throw error
  return data as Player[]
}

// Get single player
export async function getPlayer(id: string): Promise<Player> {
  const { data, error } = await supabase
    .from('players')
    .select('id, nome, soprannome, avatar_url, er, tratto, tenore_fisico, base_rating, last_er, delta_rating, player_roles(ruolo, ordine)')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as Player
}

// Create player (admin only)
export async function createPlayer(player: Partial<Player>): Promise<Player> {
  const { data, error } = await supabase
    .from('players')
    .insert(player)
    .select()
    .single()

  if (error) throw error
  return data as Player
}

// Update player (admin only)
export async function updatePlayer(id: string, updates: Partial<Player>): Promise<Player> {
  const { data, error } = await supabase
    .from('players')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as Player
}

// Delete player (admin only)
export async function deletePlayer(id: string): Promise<void> {
  const { error } = await supabase
    .from('players')
    .delete()
    .eq('id', id)

  if (error) throw error
}
```

### classifiche.ts

```typescript
import { supabase } from '../lib/supabase'
import type { ClassificaRow } from '../lib/schemas'

export type ClassificheResult = {
  data: ClassificaRow[]
  total: number
}

export async function getClassifiche(
  type: 'marcatori' | 'assist' | 'voto'
): Promise<ClassificheResult> {
  // Fetch from view
  const { data: rows, error } = await supabase
    .from('v_gcp')
    .select('*')

  if (error) throw new Error(error.message)
  if (!rows || rows.length === 0) return { data: [], total: 0 }

  // Fetch last 5 results for streak
  const playerIds = rows.map((r: any) => r.id)
  const { data: matchRows } = await supabase
    .from('match_details')
    .select('player_id, giornata, risultato')
    .in('player_id', playerIds)
    .order('giornata', { ascending: false })

  // Calculate streaks
  const streakMap = new Map<string, string[]>()
  for (const m of matchRows ?? []) {
    const arr = streakMap.get(m.player_id) ?? []
    if (arr.length < 5) arr.push(m.risultato)
    streakMap.set(m.player_id, arr)
  }

  // Sort by metric
  const sortKey = type === 'marcatori' ? 'gol_totali' : 
                  type === 'assist' ? 'assist_totali' : 'media_voto'
  
  const sorted = (rows as any[]).sort((a, b) => {
    const va = a[sortKey] as number | null
    const vb = b[sortKey] as number | null
    if (va === null && vb === null) return 0
    if (va === null) return 1
    if (vb === null) return -1
    return vb - va
  })

  const data: ClassificaRow[] = sorted.map((r) => ({
    id: r.id,
    nome: r.nome,
    presenze: Number(r.presenze),
    gol_totali: Number(r.gol_totali),
    assist_totali: Number(r.assist_totali),
    media_voto: r.media_voto !== null ? Number(r.media_voto) : null,
    plus_minus: Number(r.plus_minus),
    streak: computeStreak(streakMap.get(r.id) ?? []),
    last_5: streakMap.get(r.id) ?? [],
  }))

  return { data, total: data.length }
}

function computeStreak(results: string[]): string | null {
  if (!results || results.length === 0) return null
  const first = results[0]
  let count = 0
  for (const r of results) {
    if (r === first) count++
    else break
  }
  return `${count}${first}`
}
```

### 1vs1.ts

```typescript
import { supabase } from '../lib/supabase'

export async function get1vs1Stats(id1: string, id2: string) {
  const url = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/get-1vs1?id1=${id1}&id2=${id2}`
  
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`
    }
  })

  if (!response.ok) {
    throw new Error('Failed to fetch 1vs1 stats')
  }

  return response.json()
}
```

---

## Autenticazione

### Setup Auth

```typescript
// src/lib/useAuth.ts
import { useState, useEffect } from 'react'
import { supabase } from './supabase'
import type { User } from '@supabase/supabase-js'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })
    if (error) throw error
    return data
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return { user, loading, signIn, signOut }
}
```

### Protected Routes

```typescript
// src/pages/admin/Layout.tsx
import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '../../lib/useAuth'

export function AdminLayout() {
  const { user, loading } = useAuth()

  if (loading) return <div>Loading...</div>

  if (!user) {
    return <Navigate to="/admin/login" replace />
  }

  return (
    <div>
      <Sidebar />
      <main>
        <Outlet />
      </main>
    </div>
  )
}
```

### Check Admin Role

```typescript
// Verifica ruolo admin da user metadata
function isAdmin(user: User | null): boolean {
  if (!user) return false
  return user.user_metadata?.role === 'admin'
}

// Uso in componenti
const { user } = useAuth()
const canEdit = isAdmin(user)
```

---

## Error Handling

### Pattern Standard

```typescript
// API function con error handling
export async function getPlayers(): Promise<Player[]> {
  try {
    const { data, error } = await supabase
      .from('players')
      .select('*')

    if (error) throw error
    
    return data as Player[]
  } catch (error) {
    console.error('Error fetching players:', error)
    throw new Error('Failed to fetch players')
  }
}

// Uso in componente
function PlayersList() {
  const [players, setPlayers] = useState<Player[]>([])
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    getPlayers()
      .then(setPlayers)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <Skeleton />
  if (error) return <ErrorMessage message={error} />
  
  return <div>{/* Render players */}</div>
}
```

### Toast Notifications

```typescript
import { toast } from 'sonner'

// Success
async function handleSave() {
  try {
    await updatePlayer(id, updates)
    toast.success('Giocatore aggiornato con successo')
  } catch (error) {
    toast.error('Errore durante l\'aggiornamento')
  }
}

// Promise toast (auto success/error)
toast.promise(
  updatePlayer(id, updates),
  {
    loading: 'Salvataggio in corso...',
    success: 'Giocatore aggiornato!',
    error: 'Errore durante il salvataggio'
  }
)
```

---

## Best Practices

### 1. Type Safety

```typescript
// Usa Zod per validazione runtime
import { z } from 'zod'

const playerSchema = z.object({
  id: z.string(),
  nome: z.string(),
  er: z.number().nullable()
})

// Valida response
const data = await supabase.from('players').select('*')
const validated = playerSchema.array().parse(data)
```

### 2. Caching

```typescript
// React Query per caching automatico
import { useQuery } from '@tanstack/react-query'

function usePlayer(id: string) {
  return useQuery({
    queryKey: ['player', id],
    queryFn: () => getPlayer(id),
    staleTime: 5 * 60 * 1000, // 5 minuti
  })
}
```

### 3. Batch Operations

```typescript
// Batch insert invece di loop
const roles = [
  { player_id: id, ruolo: 'ATT', ordine: 1 },
  { player_id: id, ruolo: 'CC', ordine: 2 }
]

await supabase.from('player_roles').insert(roles)

// ❌ NON fare:
for (const role of roles) {
  await supabase.from('player_roles').insert(role)
}
```

### 4. Optimistic Updates

```typescript
// Update UI immediatamente, rollback se errore
async function handleUpdate(id: string, updates: Partial<Player>) {
  const oldData = players.find(p => p.id === id)
  
  // Update UI
  setPlayers(prev => prev.map(p => 
    p.id === id ? { ...p, ...updates } : p
  ))

  try {
    await updatePlayer(id, updates)
  } catch (error) {
    // Rollback on error
    setPlayers(prev => prev.map(p => 
      p.id === id ? oldData : p
    ))
    toast.error('Errore durante l\'aggiornamento')
  }
}
```

### 5. Debounce Search

```typescript
import { useMemo } from 'react'
import { debounce } from 'lodash'

function SearchPlayers() {
  const [search, setSearch] = useState('')

  const debouncedSearch = useMemo(
    () => debounce((value: string) => {
      // Esegui ricerca
      searchPlayers(value)
    }, 300),
    []
  )

  return (
    <input
      onChange={(e) => debouncedSearch(e.target.value)}
      placeholder="Cerca giocatore..."
    />
  )
}
```

---

## Prossimi Passi

Continua con:
- [Deployment](./05-deployment.md) per pubblicare le API
- [Workflow](./06-workflow.md) per contribuire alle API
- [Database](./03-database.md) per comprendere lo schema

---

**Ultima modifica**: 2026-03-26