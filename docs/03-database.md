# Schema Database

## 📋 Indice

1. [Panoramica Database](#panoramica-database)
2. [Modello Dati](#modello-dati)
3. [Tabelle Principali](#tabelle-principali)
4. [Relazioni](#relazioni)
5. [Views e Funzioni](#views-e-funzioni)
6. [Row Level Security](#row-level-security)
7. [Migrations](#migrations)
8. [Query Comuni](#query-comuni)

---

## Panoramica Database

**Polemica League** utilizza **PostgreSQL 17** tramite Supabase come database principale.

### Caratteristiche

- **Database Relazionale**: Schema normalizzato con foreign keys
- **Type-Safe**: Tipi PostgreSQL mappati a TypeScript
- **Row Level Security**: Controllo accessi granulare
- **Real-time**: Subscriptions per aggiornamenti live
- **Full-text Search**: Ricerca testuale avanzata
- **JSON Support**: Campi JSONB per dati flessibili

### Architettura Dati

```
┌─────────────────────────────────────────────────────────┐
│                    DIMENSION TABLES                      │
│  (Entità principali - dati relativamente statici)       │
├─────────────────────────────────────────────────────────┤
│  • players           - Anagrafica giocatori             │
│  • player_roles      - Ruoli giocatori (1-4 per player) │
│  • rivalries         - Rivalità tra giocatori           │
│  • news              - Articoli e notizie               │
│  • manifesto         - Articoli del manifesto           │
│  • home_widgets      - Widget homepage                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      FACT TABLES                         │
│  (Eventi e transazioni - dati in crescita continua)     │
├─────────────────────────────────────────────────────────┤
│  • match_details     - Dettagli partite (fact table)    │
│  • player_er_history - Storico ER per giornata          │
└─────────────────────────────────────────────────────────┘
```

---

## Modello Dati

### Entity Relationship Diagram

```
┌──────────────┐
│   players    │
│──────────────│
│ id (PK)      │◄─────┐
│ nome         │      │
│ soprannome   │      │
│ avatar_url   │      │
│ er           │      │
│ tratto       │      │
│ tenore_fisico│      │
│ base_rating  │      │
│ last_er      │      │
│ delta_rating │      │
└──────────────┘      │
       │              │
       │ 1:N          │
       ▼              │
┌──────────────┐      │
│ player_roles │      │
│──────────────│      │
│ id (PK)      │      │
│ player_id(FK)│──────┘
│ ruolo        │
│ ordine       │
└──────────────┘

┌──────────────┐      ┌──────────────────┐
│   players    │      │  match_details   │
│──────────────│      │──────────────────│
│ id (PK)      │◄─────│ player_id (FK)   │
└──────────────┘  1:N │ id (PK)          │
                      │ data             │
                      │ giornata         │
                      │ squadra          │
                      │ er               │
                      │ gol              │
                      │ assist           │
                      │ voto             │
                      │ risultato        │
                      └──────────────────┘

┌──────────────┐      ┌────────────────────┐
│   players    │      │ player_er_history  │
│──────────────│      │────────────────────│
│ id (PK)      │◄─────│ player_id (FK)     │
└──────────────┘  1:N │ id (PK)            │
                      │ giornata           │
                      │ er                 │
                      └────────────────────┘

┌──────────────┐      ┌──────────────┐
│   players    │      │  rivalries   │
│──────────────│      │──────────────│
│ id (PK)      │◄─────│ player1_id   │
│              │      │ player2_id   │
│              │◄─────│ tag          │
└──────────────┘  N:N │ stats...     │
                      └──────────────┘
```

---

## Tabelle Principali

### 1. players

Tabella dimensionale principale per i giocatori.

```sql
CREATE TABLE players (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome          TEXT NOT NULL UNIQUE,
  soprannome    TEXT,
  avatar_url    TEXT,
  er            NUMERIC,           -- Efficiency Rating corrente
  tratto        TEXT,              -- Tratto distintivo
  tenore_fisico TEXT,              -- Condizione fisica
  base_rating   NUMERIC,           -- Rating base
  last_er       NUMERIC,           -- ER giornata precedente
  delta_rating  NUMERIC,           -- Variazione rating
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Campi**:
- `id`: UUID univoco generato automaticamente
- `nome`: Nome completo giocatore (UNIQUE)
- `soprannome`: Nickname opzionale
- `avatar_url`: URL immagine profilo (Supabase Storage)
- `er`: Efficiency Rating attuale (calcolato)
- `tratto`: Caratteristica distintiva (es. "Il Bomber")
- `tenore_fisico`: Stato forma fisica
- `base_rating`: Rating iniziale del giocatore
- `last_er`: ER della giornata precedente
- `delta_rating`: Differenza tra ER attuale e precedente

**Indici**:
```sql
-- Automatico su PRIMARY KEY (id)
-- Automatico su UNIQUE (nome)
```

**Esempio dati**:
```sql
INSERT INTO players (nome, er, tratto, tenore_fisico) VALUES
  ('Mario Rossi', 85.5, 'Il Capitano', 'Ottima'),
  ('Luigi Verdi', 78.2, 'Il Bomber', 'Buona'),
  ('Paolo Bianchi', 92.1, 'Il Regista', 'Eccellente');
```

---

### 2. player_roles

Ruoli di un giocatore (fino a 4 ruoli per giocatore).

```sql
CREATE TABLE player_roles (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  ruolo      TEXT NOT NULL CHECK (ruolo IN ('CC','TD','ATT','TS','DC','CS','POR','CD')),
  ordine     INT  NOT NULL CHECK (ordine BETWEEN 1 AND 4),
  UNIQUE (player_id, ordine)
);
```

**Ruoli disponibili**:
- `CC`: Centro Campo
- `TD`: Trequartista/Difensore
- `ATT`: Attaccante
- `TS`: Terzino Sinistro
- `DC`: Difensore Centrale
- `CS`: Centrocampista Sinistro
- `POR`: Portiere
- `CD`: Centrocampista Destro

**Vincoli**:
- Ogni giocatore può avere max 4 ruoli
- `ordine` indica priorità (1 = primario, 4 = quaternario)
- Constraint UNIQUE su `(player_id, ordine)`

**Esempio dati**:
```sql
INSERT INTO player_roles (player_id, ruolo, ordine) VALUES
  ('uuid-mario', 'CC', 1),
  ('uuid-mario', 'TD', 2),
  ('uuid-luigi', 'ATT', 1);
```

---

### 3. match_details

Tabella fact principale - dettagli di ogni partita per ogni giocatore.

```sql
CREATE TABLE match_details (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  data              DATE NOT NULL,
  giornata          INT  NOT NULL,
  campo             TEXT,
  ora               TIME,
  squadra           TEXT NOT NULL CHECK (squadra IN ('A','B')),
  player_id         UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  er                NUMERIC,          -- NULL se non disponibile
  gol               INT  NOT NULL DEFAULT 0,
  autogol           INT  NOT NULL DEFAULT 0,
  assist            INT  NOT NULL DEFAULT 0,
  voto              NUMERIC,          -- NULL se non disponibile
  gol_squadra       INT  NOT NULL,
  gol_avversari     INT  NOT NULL,
  risultato         TEXT NOT NULL CHECK (risultato IN ('V','P','S')),
  differenza_reti   INT  NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Campi chiave**:
- `giornata`: Numero giornata (1, 2, 3, ...)
- `squadra`: Squadra A o B
- `player_id`: Riferimento al giocatore
- `er`: Efficiency Rating della partita
- `gol`, `autogol`, `assist`: Statistiche individuali
- `voto`: Voto prestazione (1-10)
- `risultato`: V (Vittoria), P (Pareggio), S (Sconfitta)
- `differenza_reti`: Goal difference della partita

**Indici**:
```sql
CREATE INDEX idx_match_details_player   ON match_details(player_id);
CREATE INDEX idx_match_details_giornata ON match_details(giornata);
CREATE INDEX idx_match_details_squadra  ON match_details(squadra);
```

**Esempio dati**:
```sql
INSERT INTO match_details (
  data, giornata, squadra, player_id, 
  gol, assist, voto, gol_squadra, gol_avversari, risultato, differenza_reti
) VALUES (
  '2025-01-15', 1, 'A', 'uuid-mario',
  2, 1, 8.5, 5, 3, 'V', 2
);
```

---

### 4. player_er_history

Storico ER per giornata (per grafici trend).

```sql
CREATE TABLE player_er_history (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  giornata   INT  NOT NULL,
  er         NUMERIC,
  UNIQUE (player_id, giornata)
);
```

**Utilizzo**:
- Traccia evoluzione ER nel tempo
- Alimenta grafici trend nei profili giocatori
- Aggiornato automaticamente dopo ogni giornata

**Indici**:
```sql
CREATE INDEX idx_player_er_history_player ON player_er_history(player_id);
```

---

### 5. rivalries

Rivalità tra coppie di giocatori.

```sql
CREATE TABLE rivalries (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player1_id        UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  player2_id        UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  tag               TEXT CHECK (tag IN ('LA SFIDA MAESTRA','DERBY D''ITALIA')),
  partite_insieme   INT NOT NULL DEFAULT 0,
  vittorie_insieme  INT NOT NULL DEFAULT 0,
  sconfitte_insieme INT NOT NULL DEFAULT 0,
  partite_contro    INT NOT NULL DEFAULT 0,
  vittorie_g1       INT NOT NULL DEFAULT 0,
  vittorie_g2       INT NOT NULL DEFAULT 0,
  totale_partite    INT NOT NULL DEFAULT 0,
  UNIQUE (player1_id, player2_id),
  CHECK  (player1_id <> player2_id)
);
```

**Statistiche**:
- `partite_insieme`: Partite nella stessa squadra
- `vittorie_insieme`: Vittorie insieme
- `sconfitte_insieme`: Sconfitte insieme
- `partite_contro`: Partite in squadre opposte
- `vittorie_g1`: Vittorie giocatore 1 contro giocatore 2
- `vittorie_g2`: Vittorie giocatore 2 contro giocatore 1
- `totale_partite`: Totale partite (insieme + contro)

**Tag speciali**:
- `LA SFIDA MAESTRA`: Rivalità epica
- `DERBY D'ITALIA`: Derby storico

**Indici**:
```sql
CREATE INDEX idx_rivalries_player1 ON rivalries(player1_id);
CREATE INDEX idx_rivalries_player2 ON rivalries(player2_id);
```

---

### 6. news

Articoli e notizie della lega.

```sql
CREATE TABLE news (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  giornata   INT  NOT NULL,
  data       DATE,
  posizione  INT,              -- Ordine visualizzazione
  titolo     TEXT NOT NULL,
  corpo      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Campi**:
- `giornata`: Giornata di riferimento
- `posizione`: Ordine di visualizzazione (opzionale)
- `titolo`: Titolo articolo
- `corpo`: Contenuto completo (supporta markdown)

**Indici**:
```sql
CREATE INDEX idx_news_giornata ON news(giornata);
```

---

### 7. manifesto

Articoli del manifesto della lega.

```sql
CREATE TABLE manifesto (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  articolo        TEXT NOT NULL UNIQUE,   -- es. '3bis', '7'
  nome_articolo   TEXT NOT NULL,
  corpo           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Esempio**:
```sql
INSERT INTO manifesto (articolo, nome_articolo, corpo) VALUES
  ('1', 'Principio di Fair Play', 'Il fair play è fondamentale...'),
  ('3bis', 'Regola del Fuorigioco', 'Il fuorigioco si applica...');
```

---

### 8. home_widgets

Widget configurabili per la homepage.

```sql
CREATE TABLE home_widgets (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo       TEXT NOT NULL UNIQUE,  -- es. 'prossima_partita'
  attivo     BOOLEAN NOT NULL DEFAULT false,
  payload    JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Tipi widget**:
- `prossima_partita`: Info prossima partita

**Payload esempio**:
```json
{
  "data": "2025-02-15",
  "ora": "20:30",
  "luogo": "Campo Comunale",
  "nome": "Giornata 15"
}
```

---

## Relazioni

### One-to-Many (1:N)

```sql
-- Un giocatore ha molti ruoli
players (1) ──< (N) player_roles

-- Un giocatore ha molte partite
players (1) ──< (N) match_details

-- Un giocatore ha molti record storici ER
players (1) ──< (N) player_er_history
```

### Many-to-Many (N:N)

```sql
-- Giocatori hanno rivalità con altri giocatori
players (N) ──< rivalries >── (N) players
```

### Cascade Delete

Tutte le foreign keys usano `ON DELETE CASCADE`:
```sql
-- Se elimini un giocatore, vengono eliminati:
- Tutti i suoi ruoli (player_roles)
- Tutte le sue partite (match_details)
- Tutto il suo storico ER (player_er_history)
- Tutte le sue rivalità (rivalries)
```

---

## Views e Funzioni

### Views Materializzate (Future)

Potenziali views per performance:

```sql
-- Classifica generale
CREATE MATERIALIZED VIEW classifica_generale AS
SELECT 
  p.id,
  p.nome,
  COUNT(md.id) as presenze,
  SUM(md.gol) as gol_totali,
  SUM(md.assist) as assist_totali,
  AVG(md.voto) as media_voto,
  SUM(CASE WHEN md.risultato = 'V' THEN 1 ELSE 0 END) as vittorie
FROM players p
LEFT JOIN match_details md ON p.id = md.player_id
GROUP BY p.id, p.nome;

-- Refresh periodico
REFRESH MATERIALIZED VIEW classifica_generale;
```

### Stored Procedures

```sql
-- Calcola ER per un giocatore
CREATE OR REPLACE FUNCTION calculate_player_er(player_uuid UUID)
RETURNS NUMERIC AS $$
DECLARE
  avg_er NUMERIC;
BEGIN
  SELECT AVG(er) INTO avg_er
  FROM match_details
  WHERE player_id = player_uuid AND er IS NOT NULL;
  
  RETURN COALESCE(avg_er, 0);
END;
$$ LANGUAGE plpgsql;
```

### Triggers

```sql
-- Aggiorna timestamp su modifica
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_home_widgets_updated_at
  BEFORE UPDATE ON home_widgets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

---

## Row Level Security

### Politiche di Sicurezza

#### Public Read (Utenti Anonimi)

```sql
-- Tutti possono leggere dati pubblici
CREATE POLICY "Public read" ON players
  FOR SELECT TO anon USING (true);

CREATE POLICY "Public read" ON match_details
  FOR SELECT TO anon USING (true);

-- Applicato a tutte le tabelle pubbliche
```

#### Authenticated Read (Utenti Autenticati)

```sql
-- Utenti autenticati possono leggere tutto
CREATE POLICY "Authenticated read" ON players
  FOR SELECT TO authenticated USING (true);
```

#### Admin Write (Solo Admin)

```sql
-- Solo admin possono modificare dati
CREATE POLICY "Admin insert" ON players
  FOR INSERT TO authenticated
  WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

CREATE POLICY "Admin update" ON players
  FOR UPDATE TO authenticated
  USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

CREATE POLICY "Admin delete" ON players
  FOR DELETE TO authenticated
  USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
```

### Verifica Ruolo Admin

Il ruolo admin è verificato tramite JWT:
```sql
(auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
```

Questo controlla il campo `role` nei metadata dell'utente Supabase.

---

## Migrations

### Struttura Migrations

```
supabase/migrations/
├── 20250101000000_init.sql              # Schema iniziale
├── 20250102000000_public_read.sql       # RLS pubblico
├── 20250103000000_grant_views.sql       # Permessi views
├── 20250104000000_player_avatar_nickname.sql  # Avatar e nickname
├── 20250105000000_remove_gcp.sql        # Rimozione GCP
├── 20250106000000_home_widgets.sql      # Widget homepage
└── 20250107000000_instagram_widget.sql  # Widget Instagram
```

### Applicare Migrations

```bash
# Locale (Supabase CLI)
supabase db reset

# Produzione (Supabase Dashboard)
# Settings → Database → Migrations → Run migration
```

### Creare Nuova Migration

```bash
# Crea file migration
supabase migration new add_new_feature

# Edita file creato
# supabase/migrations/TIMESTAMP_add_new_feature.sql

# Applica migration
supabase db push
```

---

## Query Comuni

### Ottenere Giocatori con Ruoli

```sql
SELECT 
  p.id,
  p.nome,
  p.er,
  json_agg(
    json_build_object('ruolo', pr.ruolo, 'ordine', pr.ordine)
    ORDER BY pr.ordine
  ) as ruoli
FROM players p
LEFT JOIN player_roles pr ON p.id = pr.player_id
GROUP BY p.id, p.nome, p.er
ORDER BY p.nome;
```

### Classifica Generale

```sql
SELECT 
  p.id,
  p.nome,
  COUNT(md.id) as presenze,
  SUM(md.gol) as gol_totali,
  SUM(md.assist) as assist_totali,
  AVG(md.voto) as media_voto,
  SUM(CASE 
    WHEN md.risultato = 'V' THEN md.differenza_reti 
    WHEN md.risultato = 'S' THEN -md.differenza_reti 
    ELSE 0 
  END) as plus_minus
FROM players p
LEFT JOIN match_details md ON p.id = md.player_id
GROUP BY p.id, p.nome
ORDER BY plus_minus DESC;
```

### Storico Partite Giocatore

```sql
SELECT 
  md.data,
  md.giornata,
  md.squadra,
  md.gol,
  md.assist,
  md.voto,
  md.risultato,
  md.gol_squadra,
  md.gol_avversari
FROM match_details md
WHERE md.player_id = 'uuid-giocatore'
ORDER BY md.giornata DESC;
```

### Trend ER Giocatore

```sql
SELECT 
  giornata,
  er
FROM player_er_history
WHERE player_id = 'uuid-giocatore'
ORDER BY giornata ASC;
```

### Top Scorer

```sql
SELECT 
  p.nome,
  SUM(md.gol) as gol_totali
FROM players p
JOIN match_details md ON p.id = md.player_id
GROUP BY p.id, p.nome
ORDER BY gol_totali DESC
LIMIT 10;
```

### Rivalità Giocatore

```sql
SELECT 
  CASE 
    WHEN r.player1_id = 'uuid-giocatore' THEN p2.nome
    ELSE p1.nome
  END as avversario,
  r.tag,
  r.totale_partite,
  r.partite_insieme,
  r.partite_contro,
  CASE 
    WHEN r.player1_id = 'uuid-giocatore' THEN r.vittorie_g1
    ELSE r.vittorie_g2
  END as mie_vittorie
FROM rivalries r
JOIN players p1 ON r.player1_id = p1.id
JOIN players p2 ON r.player2_id = p2.id
WHERE r.player1_id = 'uuid-giocatore' 
   OR r.player2_id = 'uuid-giocatore'
ORDER BY r.totale_partite DESC;
```

### Ultime News

```sql
SELECT 
  id,
  giornata,
  data,
  titolo,
  corpo,
  created_at
FROM news
ORDER BY giornata DESC, posizione ASC
LIMIT 10;
```

---

## Best Practices

### 1. Usa Transazioni per Operazioni Multiple

```sql
BEGIN;
  INSERT INTO players (nome, er) VALUES ('Nuovo Giocatore', 75.0);
  INSERT INTO player_roles (player_id, ruolo, ordine) 
    VALUES (lastval(), 'ATT', 1);
COMMIT;
```

### 2. Valida Dati a Livello Database

```sql
-- Usa CHECK constraints
CHECK (ordine BETWEEN 1 AND 4)
CHECK (squadra IN ('A','B'))
CHECK (risultato IN ('V','P','S'))
```

### 3. Usa Indici per Query Frequenti

```sql
-- Indici su foreign keys
CREATE INDEX idx_match_details_player ON match_details(player_id);

-- Indici su campi filtrati spesso
CREATE INDEX idx_match_details_giornata ON match_details(giornata);
```

### 4. Normalizza Dati

- Evita duplicazione dati
- Usa foreign keys per integrità referenziale
- Separa entità in tabelle distinte

### 5. Documenta Schema

```sql
COMMENT ON TABLE players IS 'Anagrafica giocatori della lega';
COMMENT ON COLUMN players.er IS 'Efficiency Rating calcolato';
```

---

## Prossimi Passi

Continua con:
- [API Documentation](./04-api.md) per capire come interrogare il database
- [Deployment](./05-deployment.md) per pubblicare il database
- [Workflow](./06-workflow.md) per contribuire allo schema

---

**Ultima modifica**: 2026-03-26