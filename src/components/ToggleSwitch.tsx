interface Props {
  value: boolean
  onChange: (v: boolean) => void
  labelOn?: string
  labelOff?: string
}

export function ToggleSwitch({ value, onChange, labelOn = 'Attivo', labelOff = 'Disattivo' }: Props) {
  return (
    <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
      <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', fontWeight: 600 }}>
        {value ? labelOn : labelOff}
      </span>
      <div
        onClick={() => onChange(!value)}
        style={{
          width: 40,
          height: 22,
          borderRadius: 11,
          background: value ? 'var(--accent)' : '#444',
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
          left: value ? 20 : 2,
          transition: 'left 0.2s',
        }} />
      </div>
    </label>
  )
}
