import { createClient } from '@supabase/supabase-js'

// In K8s the secret is mounted as /usr/share/nginx/html/env-config.js
// which sets window.__env__ before the app bundle loads.
// Fallback to import.meta.env for local `vite dev`.
const runtimeEnv = (window as Window & { __env__?: Record<string, string> }).__env__

export const supabase = createClient(
  runtimeEnv?.VITE_SUPABASE_URL ?? import.meta.env.VITE_SUPABASE_URL,
  runtimeEnv?.VITE_SUPABASE_ANON_KEY ?? import.meta.env.VITE_SUPABASE_ANON_KEY
)
