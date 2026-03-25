import { useEffect, useState } from 'react'
import { toast } from 'sonner'
import { supabase } from '../../lib/supabase'
import { Skeleton } from '../../components/Skeleton'

interface ProssimaPartita {
  data: string
  ora: string
  luogo: string
  nome: string
}

export function AdminHome() {
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [attivo, setAttivo] = useState(false)
  const [data, setData] = useState('')
  const [ora, setOra] = useState('')
  const [luogo, setLuogo] = useState('')
  const [nome, setNome] = useState('')
  const [widgetId, setWidgetId] = useState<string | null>(null)

  useEffect(() => {
    supabase
      .from('home_widgets')
      .select('*')
      .eq('tipo', 'prossima_partita')
      .single()
      .then(({ data: row }) => {
        if (row) {
          setWidgetId(row.id)
          setAttivo(row.attivo)
          const p = row.payload as ProssimaPartita
          setData(p.data ?? '')
          setOra(p.ora ?? '')
          setLuogo(p.luogo ?? '')
          setNome(p.nome ?? '')
        }
      })
      .finally(() => setLoading(false))
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!widgetId) return
    setSubmitting(true)

    const { error } = await supabase
      .from('home_widgets')
      .update({
        attivo,
        payload: { data, ora, luogo, nome } satisfies ProssimaPartita,
        updated_at: new Date().toISOString(),
      })
      .eq('id', widgetId)

    if (error) toast.error(error.message)
    else toast.success('Salvato')
    setSubmitting(false)
  }

  const fieldStyle: React.CSSProperties = { padding: '0.5rem', fontSize: '0.9rem', width: '100%' }

  if (loading) return <Skeleton height="2rem" count={5} />

  return (
    <div>
      <h1 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1.5rem' }}>Home</h1>

      <form onSubmit={handleSubmit} style={{ background: 'var(--surface)', borderRadius: 'var(--radius)', padding: '1.25rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.25rem' }}>
          <h3 style={{ fontWeight: 600, fontSize: '1rem' }}>Prossima Partita</h3>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', fontWeight: 600 }}>
              {attivo ? 'Attivo' : 'Disattivo'}
            </span>
            <div
              onClick={() => setAttivo(!attivo)}
              style={{
                width: 40,
                height: 22,
                borderRadius: 11,
                background: attivo ? 'var(--accent)' : '#444',
                position: 'relative',
                transition: 'background 0.2s',
                cursor: 'pointer',
              }}
            >
              <div style={{
                width: 18,
                height: 18,
                borderRadius: '50%',
                background: '#fff',
                position: 'absolute',
                top: 2,
                left: attivo ? 20 : 2,
                transition: 'left 0.2s',
              }} />
            </div>
          </label>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem', marginBottom: '0.75rem' }}>
          <div>
            <label style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Data</label>
            <input type="date" value={data} onChange={(e) => setData(e.target.value)} style={fieldStyle} />
          </div>
          <div>
            <label style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Ora</label>
            <input type="time" value={ora} onChange={(e) => setOra(e.target.value)} style={fieldStyle} />
          </div>
        </div>

        <div style={{ marginBottom: '0.75rem' }}>
          <label style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Luogo</label>
          <input value={luogo} onChange={(e) => setLuogo(e.target.value)} placeholder="Centro Sportivo FREE TIME" style={fieldStyle} />
        </div>

        <div style={{ marginBottom: '1.25rem' }}>
          <label style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Nome evento (opzionale)</label>
          <input value={nome} onChange={(e) => setNome(e.target.value)} placeholder="es. Quadrangolare di Agosto" style={fieldStyle} />
        </div>

        <button
          type="submit"
          disabled={submitting}
          style={{
            padding: '0.5rem 1.5rem',
            borderRadius: '8px',
            background: 'var(--accent)',
            color: '#000',
            fontWeight: 700,
            opacity: submitting ? 0.6 : 1,
          }}
        >
          {submitting ? 'Salvataggio...' : 'Salva'}
        </button>
      </form>
    </div>
  )
}
