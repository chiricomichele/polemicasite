import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { supabase } from '../lib/supabase'
import { Skeleton } from '../components/Skeleton'
import { Link } from 'react-router-dom'

interface MatchPlayer {
  player_id: string
  nome: string
  squadra: string
  er: number | null
  gol: number
  autogol: number
  assist: number
  voto: number | null
}

interface MatchSummary {
  giornata: number
  data: string
  campo: string | null
  ora: string | null
  golA: number
  golB: number
  players: MatchPlayer[]
}

export function Partite() {
  const [matches, setMatches] = useState<MatchSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [expanded, setExpanded] = useState<Set<number>>(new Set())
  const [visible, setVisible] = useState(10)

  useEffect(() => {
    supabase
      .from('match_details')
      .select('giornata, data, campo, ora, squadra, gol_squadra, gol_avversari, er, gol, autogol, assist, voto, player_id, players(id, nome)')
      .order('giornata', { ascending: false })
      .order('squadra')
      .then(({ data: md, error: err }) => {
        if (err) { setError(err.message); setLoading(false); return }
        if (!md) { setLoading(false); return }

        const grouped: Record<number, MatchSummary> = {}
        for (const r of md as any[]) {
          if (!grouped[r.giornata]) {
            grouped[r.giornata] = {
              giornata: r.giornata,
              data: r.data,
              campo: r.campo,
              ora: r.ora,
              golA: -1,
              golB: -1,
              players: [],
            }
          }
          const m = grouped[r.giornata]
          if (r.squadra === 'A' && m.golA === -1) m.golA = r.gol_squadra
          if (r.squadra === 'B' && m.golB === -1) m.golB = r.gol_squadra
          m.players.push({
            player_id: r.player_id,
            nome: r.players?.nome ?? '??',
            squadra: r.squadra,
            er: r.er,
            gol: r.gol,
            autogol: r.autogol,
            assist: r.assist,
            voto: r.voto,
          })
        }

        const list = Object.values(grouped).map(m => ({ ...m, golA: m.golA === -1 ? 0 : m.golA, golB: m.golB === -1 ? 0 : m.golB }))
        setMatches(list.sort((a, b) => b.giornata - a.giornata))
        setLoading(false)
      })
  }, [])

  const toggle = (g: number) => setExpanded(prev => {
    const next = new Set(prev)
    if (next.has(g)) next.delete(g); else next.add(g)
    return next
  })

  const formatDate = (d: string) => {
    const [y, m, dd] = d.split('-')
    return `${dd}/${m}/${y}`
  }

  return (
    <div style={{ padding: '1rem' }}>
      <h1 style={{ fontSize: '1.8rem', fontWeight: 700, marginBottom: '1.5rem' }}>
        <span style={{ color: 'var(--accent)' }}>Partite</span>
      </h1>

      {loading && <Skeleton height="4rem" count={6} />}
      {error && <p style={{ color: 'var(--danger)' }}>{error}</p>}

      <AnimatePresence>
        {matches.slice(0, visible).map((m) => {
          const isOpen = expanded.has(m.giornata)
          const teamA = m.players.filter(p => p.squadra === 'A')
          const teamB = m.players.filter(p => p.squadra === 'B')
          const winner = m.golA > m.golB ? 'A' : m.golB > m.golA ? 'B' : null
          const maxVoto = Math.max(...m.players.map(p => p.voto ?? -1))
          const isMvp = (p: MatchPlayer) => p.voto != null && p.voto === maxVoto && maxVoto > 0

          return (
            <motion.div
              key={m.giornata}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              style={{
                background: 'var(--surface)',
                borderRadius: 'var(--radius)',
                marginBottom: '0.75rem',
                overflow: 'hidden',
              }}
            >
              {/* Match header - clickable */}
              <div
                onClick={() => toggle(m.giornata)}
                style={{
                  padding: '1rem',
                  cursor: 'pointer',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <div>
                  <div style={{
                    display: 'inline-block',
                    background: 'var(--accent)',
                    color: '#000',
                    padding: '0.15rem 0.5rem',
                    borderRadius: '4px',
                    fontSize: '0.7rem',
                    fontWeight: 700,
                    textTransform: 'uppercase',
                    marginRight: '0.75rem',
                  }}>
                    G{m.giornata}
                  </div>
                  <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                    {formatDate(m.data)}{m.campo ? ` — ${m.campo}` : ''}
                  </span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <span style={{
                    fontSize: '1.3rem',
                    fontWeight: 800,
                    fontVariantNumeric: 'tabular-nums',
                    letterSpacing: '1px',
                  }}>
                    <span style={{ color: winner === 'A' ? 'var(--accent)' : 'var(--text-secondary)' }}>{m.golA}</span>
                    <span style={{ color: '#555', margin: '0 0.3rem' }}>-</span>
                    <span style={{ color: winner === 'B' ? 'var(--accent)' : 'var(--text-secondary)' }}>{m.golB}</span>
                  </span>
                  <svg
                    width="16" height="16" viewBox="0 0 24 24" fill="none"
                    stroke="var(--text-secondary)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                    style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform 0.2s' }}
                  >
                    <polyline points="6 9 12 15 18 9" />
                  </svg>
                </div>
              </div>

              {/* Expanded detail */}
              {isOpen && (
                <div style={{ padding: '0 1rem 1rem' }}>
                  {[{ label: 'Squadra A', team: teamA, isWinner: winner === 'A' }, { label: 'Squadra B', team: teamB, isWinner: winner === 'B' }].map(({ label, team, isWinner }) => (
                    <div key={label} style={{ marginBottom: '0.75rem' }}>
                      <div style={{
                        fontSize: '0.75rem',
                        fontWeight: 700,
                        textTransform: 'uppercase',
                        color: isWinner ? 'var(--accent)' : 'var(--text-secondary)',
                        marginBottom: '0.4rem',
                        paddingBottom: '0.3rem',
                        borderBottom: '1px solid #333',
                      }}>
                        {label}
                      </div>
                      {team.map((p) => (
                        <Link
                          key={p.player_id}
                          to={`/profilo/${p.player_id}`}
                          style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            padding: '0.35rem 0',
                            borderBottom: '1px solid #1a1a1a',
                            textDecoration: 'none',
                            color: 'inherit',
                          }}
                        >
                          <span style={{ fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '4px' }}>
                            {isMvp(p) && <span style={{ fontSize: '0.75rem' }} title="MVP">👑</span>}
                            {p.nome}
                          </span>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                            {p.gol > 0 && (
                              <span title={`${p.gol} Gol`} style={{ display: 'flex', gap: '2px' }}>
                                {Array.from({ length: p.gol }, (_, i) => (
                                  <span key={i} style={{ fontSize: '0.75rem' }}>⚽</span>
                                ))}
                              </span>
                            )}
                            {p.autogol > 0 && (
                              <span title={`${p.autogol} Autogol`} style={{ display: 'flex', gap: '2px' }}>
                                {Array.from({ length: p.autogol }, (_, i) => (
                                  <span key={i} style={{ fontSize: '0.7rem', filter: 'grayscale(1) brightness(0.6)' }}>⚽</span>
                                ))}
                              </span>
                            )}
                            {p.assist > 0 && (
                              <span title={`${p.assist} Assist`} style={{ display: 'flex', gap: '2px' }}>
                                {Array.from({ length: p.assist }, (_, i) => (
                                  <span key={i} style={{
                                    display: 'inline-flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    width: 16,
                                    height: 16,
                                    borderRadius: '50%',
                                    background: 'var(--accent)',
                                    color: '#000',
                                    fontSize: '0.55rem',
                                    fontWeight: 800,
                                    lineHeight: 0,
                                    paddingTop: '1px',
                                  }}>A</span>
                                ))}
                              </span>
                            )}
                            {p.voto != null && <span style={{ fontWeight: 600, color: p.voto >= 6.5 ? '#22c55e' : p.voto < 5.5 ? '#ef4444' : 'var(--text-secondary)' }}>{p.voto}</span>}
                          </div>
                        </Link>
                      ))}
                    </div>
                  ))}
                </div>
              )}
            </motion.div>
          )
        })}
      </AnimatePresence>

      {!loading && visible < matches.length && (
        <button
          onClick={() => setVisible((v) => v + 10)}
          style={{
            display: 'block',
            margin: '1rem auto',
            padding: '0.7rem 2rem',
            borderRadius: '8px',
            background: 'var(--surface)',
            color: 'var(--accent)',
            fontWeight: 700,
            fontSize: '0.85rem',
            border: '1px solid #333',
          }}
        >
          Mostra altri
        </button>
      )}

      {!loading && matches.length === 0 && !error && (
        <p style={{ color: 'var(--text-secondary)', textAlign: 'center', marginTop: '3rem' }}>
          Nessuna partita disponibile
        </p>
      )}
    </div>
  )
}
