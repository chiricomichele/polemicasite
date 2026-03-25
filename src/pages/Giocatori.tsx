import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { supabase } from '../lib/supabase'
import { Skeleton } from '../components/Skeleton'

interface PlayerListItem {
  id: string
  nome: string
  avatar_url: string | null
}

const PAGE_SIZE = 15

export function Giocatori() {
  const [players, setPlayers] = useState<PlayerListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [hasMore, setHasMore] = useState(true)

  const loadPage = async (offset: number) => {
    const { data, error } = await supabase
      .from('players')
      .select('id, nome, avatar_url')
      .order('nome')
      .range(offset, offset + PAGE_SIZE - 1)

    if (error) return []
    if (!data || data.length < PAGE_SIZE) setHasMore(false)
    return data ?? []
  }

  useEffect(() => {
    loadPage(0)
      .then(setPlayers)
      .finally(() => setLoading(false))
  }, [])

  const handleLoadMore = async () => {
    setLoadingMore(true)
    const more = await loadPage(players.length)
    setPlayers((prev) => [...prev, ...more])
    setLoadingMore(false)
  }

  return (
    <div style={{ padding: '1rem' }}>
      <h1 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1.25rem' }}>Giocatori</h1>

      {loading && <Skeleton height="4rem" count={8} />}

      {players.map((p, idx) => (
        <motion.div
          key={p.id}
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: idx * 0.02 }}
        >
          <Link
            to={`/profilo/${p.id}`}
            style={{
              display: 'flex',
              alignItems: 'center',
              background: 'var(--surface)',
              borderRadius: 'var(--radius)',
              padding: '0.75rem 1rem',
              marginBottom: '0.5rem',
              textDecoration: 'none',
              color: 'inherit',
            }}
          >
            {/* Avatar */}
            {p.avatar_url ? (
              <img
                src={p.avatar_url}
                alt={p.nome}
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: '50%',
                  objectFit: 'cover',
                  marginRight: '0.75rem',
                  flexShrink: 0,
                }}
              />
            ) : (
              <div style={{
                width: 44,
                height: 44,
                borderRadius: '50%',
                background: '#333',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginRight: '0.75rem',
                flexShrink: 0,
                color: 'var(--text-secondary)',
                fontSize: '1.1rem',
                fontWeight: 700,
              }}>
                {p.nome.charAt(0).toUpperCase()}
              </div>
            )}

            {/* Name */}
            <span style={{ flex: 1, fontWeight: 500, fontSize: '1rem' }}>{p.nome}</span>

            {/* Arrow */}
            <svg width="20" height="20" fill="none" stroke="var(--text-secondary)" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
              <path d="M9 18l6-6-6-6" />
            </svg>
          </Link>
        </motion.div>
      ))}

      {hasMore && !loading && (
        <button
          onClick={handleLoadMore}
          disabled={loadingMore}
          style={{
            display: 'block',
            width: '100%',
            padding: '0.75rem',
            marginTop: '0.5rem',
            borderRadius: '8px',
            background: 'var(--surface)',
            color: 'var(--accent)',
            fontWeight: 600,
            fontSize: '0.9rem',
            opacity: loadingMore ? 0.6 : 1,
          }}
        >
          {loadingMore ? 'Caricamento...' : 'Carica altri'}
        </button>
      )}

      {!loading && players.length === 0 && (
        <p style={{ color: 'var(--text-secondary)', textAlign: 'center', marginTop: '3rem' }}>
          Nessun giocatore disponibile
        </p>
      )}
    </div>
  )
}
