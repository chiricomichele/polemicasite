import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export function PWAStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [showOfflineBanner, setShowOfflineBanner] = useState(false);
  const [updateAvailable, setUpdateAvailable] = useState(false);

  useEffect(() => {
    // Gestione stato online/offline
    const handleOnline = () => {
      setIsOnline(true);
      setShowOfflineBanner(false);
    };

    const handleOffline = () => {
      setIsOnline(false);
      // Mostra banner dopo 2 secondi (evita flash per disconnessioni momentanee)
      setTimeout(() => {
        if (!navigator.onLine) {
          setShowOfflineBanner(true);
        }
      }, 2000);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Verifica aggiornamenti service worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.ready.then(registration => {
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          
          if (newWorker) {
            newWorker.addEventListener('statechange', () => {
              if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                // Nuovo service worker disponibile
                setUpdateAvailable(true);
              }
            });
          }
        });
      });
    }

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const handleUpdate = () => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.ready.then(registration => {
        registration.waiting?.postMessage({ type: 'SKIP_WAITING' });
      });
      
      // Ricarica la pagina dopo un breve delay
      setTimeout(() => {
        window.location.reload();
      }, 500);
    }
  };

  return (
    <>
      {/* Banner Offline - Discreto in alto */}
      <AnimatePresence>
        {showOfflineBanner && (
          <motion.div
            initial={{ y: -100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -100, opacity: 0 }}
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              zIndex: 50,
              background: 'rgba(30, 30, 30, 0.95)',
              backdropFilter: 'blur(10px)',
              borderBottom: '1px solid rgba(212, 255, 0, 0.3)',
              padding: '0.75rem 1rem',
              textAlign: 'center',
            }}
          >
            <div style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem',
              fontSize: '0.875rem',
              color: 'var(--text-secondary)',
            }}>
              <span style={{ color: 'var(--accent)' }}>📡</span>
              <span>Modalità offline</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Banner Aggiornamento - Elegante e non invasivo */}
      <AnimatePresence>
        {updateAvailable && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            style={{
              position: 'fixed',
              bottom: '5.5rem',
              left: '1rem',
              right: '1rem',
              maxWidth: 'var(--max-width)',
              margin: '0 auto',
              zIndex: 40,
            }}
          >
            <div style={{
              background: 'var(--surface)',
              border: '1px solid rgba(212, 255, 0, 0.2)',
              borderRadius: 'var(--radius)',
              padding: '1rem',
              boxShadow: '0 4px 20px rgba(0, 0, 0, 0.5)',
            }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem' }}>
                <div style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  background: 'rgba(212, 255, 0, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <svg width="20" height="20" fill="var(--accent)" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z" clipRule="evenodd" />
                  </svg>
                </div>
                
                <div style={{ flex: 1, minWidth: 0 }}>
                  <h3 style={{
                    fontSize: '0.875rem',
                    fontWeight: 600,
                    color: 'var(--text-primary)',
                    marginBottom: '0.25rem',
                  }}>
                    Aggiornamento disponibile
                  </h3>
                  <p style={{
                    fontSize: '0.75rem',
                    color: 'var(--text-secondary)',
                    lineHeight: 1.4,
                  }}>
                    Nuove funzionalità e miglioramenti
                  </p>
                </div>

                <button
                  onClick={() => setUpdateAvailable(false)}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--text-secondary)',
                    cursor: 'pointer',
                    padding: '0.25rem',
                    flexShrink: 0,
                  }}
                  aria-label="Chiudi"
                >
                  <svg width="20" height="20" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </button>
              </div>

              <div style={{ marginTop: '0.75rem', display: 'flex', gap: '0.5rem' }}>
                <button
                  onClick={handleUpdate}
                  style={{
                    flex: 1,
                    background: 'var(--accent)',
                    color: 'var(--bg)',
                    border: 'none',
                    padding: '0.625rem 1rem',
                    borderRadius: '8px',
                    fontSize: '0.875rem',
                    fontWeight: 600,
                    cursor: 'pointer',
                    fontFamily: 'var(--font)',
                    transition: 'opacity 0.2s',
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.opacity = '0.9'}
                  onMouseLeave={(e) => e.currentTarget.style.opacity = '1'}
                >
                  Aggiorna ora
                </button>
                <button
                  onClick={() => setUpdateAvailable(false)}
                  style={{
                    background: 'transparent',
                    color: 'var(--text-secondary)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    padding: '0.625rem 1rem',
                    borderRadius: '8px',
                    fontSize: '0.875rem',
                    fontWeight: 500,
                    cursor: 'pointer',
                    fontFamily: 'var(--font)',
                    transition: 'background 0.2s',
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.05)'}
                  onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                >
                  Dopo
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Indicatore piccolo offline - Discreto in alto a destra */}
      {!isOnline && !showOfflineBanner && (
        <div style={{
          position: 'fixed',
          top: '1rem',
          right: '1rem',
          zIndex: 40,
        }}>
          <div style={{
            background: 'rgba(30, 30, 30, 0.9)',
            backdropFilter: 'blur(10px)',
            border: '1px solid rgba(212, 255, 0, 0.3)',
            borderRadius: '20px',
            padding: '0.375rem 0.75rem',
            fontSize: '0.75rem',
            fontWeight: 500,
            color: 'var(--text-secondary)',
            display: 'flex',
            alignItems: 'center',
            gap: '0.375rem',
            boxShadow: '0 2px 10px rgba(0, 0, 0, 0.3)',
          }}>
            <span style={{
              width: '6px',
              height: '6px',
              borderRadius: '50%',
              background: 'var(--accent)',
              animation: 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
            }}></span>
            <span>Offline</span>
          </div>
        </div>
      )}
    </>
  );
}

// Made with Bob
