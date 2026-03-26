import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

export function InstallPWA() {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [showPrompt, setShowPrompt] = useState(false);
  const [isIOS, setIsIOS] = useState(false);
  const [isStandalone, setIsStandalone] = useState(false);

  useEffect(() => {
    // Verifica se è iOS
    const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
    setIsIOS(iOS);

    // Verifica se è già installata
    const standalone = window.matchMedia('(display-mode: standalone)').matches;
    setIsStandalone(standalone);

    // Handler per il prompt di installazione (Android/Desktop)
    const handler = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e as BeforeInstallPromptEvent);
      
      // Mostra il prompt dopo 10 secondi
      setTimeout(() => {
        if (!localStorage.getItem('pwa-prompt-dismissed')) {
          setShowPrompt(true);
        }
      }, 10000);
    };

    window.addEventListener('beforeinstallprompt', handler);

    // Mostra prompt iOS se non è già installata (dopo 60 secondi)
    if (iOS && !standalone && !localStorage.getItem('pwa-prompt-dismissed')) {
      setTimeout(() => setShowPrompt(true), 10000);
    }

    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;

    try {
      await deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;

      if (outcome === 'accepted') {
        console.log('✅ PWA installata');
      }

      setDeferredPrompt(null);
      setShowPrompt(false);
      localStorage.setItem('pwa-prompt-dismissed', 'true');
    } catch (error) {
      console.error('Errore installazione PWA:', error);
    }
  };

  const handleDismiss = () => {
    setShowPrompt(false);
    localStorage.setItem('pwa-prompt-dismissed', 'true');
  };

  // Non mostrare se già installata
  if (isStandalone) return null;

  // Non mostrare se l'utente ha già rifiutato
  if (!showPrompt) return null;

  return (
    <AnimatePresence>
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
            <img
              src="/logo.jpeg"
              alt="PL"
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '8px',
                objectFit: 'cover',
                flexShrink: 0,
              }}
            />
            
            <div style={{ flex: 1, minWidth: 0 }}>
              <h3 style={{
                fontSize: '0.875rem',
                fontWeight: 600,
                color: 'var(--text-primary)',
                marginBottom: '0.25rem',
              }}>
                📱 Installa l'app
              </h3>
              
              {isIOS ? (
                <div style={{
                  fontSize: '0.75rem',
                  color: 'var(--text-secondary)',
                  lineHeight: 1.4,
                }}>
                  <p style={{ marginBottom: '0.5rem' }}>Tocca <span style={{ color: 'var(--accent)' }}>⬆️ Condividi</span> → <span style={{ color: 'var(--accent)' }}>"Aggiungi a Home"</span></p>
                </div>
              ) : (
                <p style={{
                  fontSize: '0.75rem',
                  color: 'var(--text-secondary)',
                  lineHeight: 1.4,
                }}>
                  Accesso rapido e funzionalità offline
                </p>
              )}
            </div>

            <button
              onClick={handleDismiss}
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

          {!isIOS && deferredPrompt && (
            <div style={{ marginTop: '0.75rem', display: 'flex', gap: '0.5rem' }}>
              <button
                onClick={handleInstall}
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
                Installa
              </button>
              <button
                onClick={handleDismiss}
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
          )}

          {isIOS && (
            <button
              onClick={handleDismiss}
              style={{
                marginTop: '0.75rem',
                width: '100%',
                background: 'none',
                border: 'none',
                color: 'var(--text-secondary)',
                fontSize: '0.75rem',
                cursor: 'pointer',
                fontFamily: 'var(--font)',
              }}
            >
              Non mostrare più
            </button>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  );
}

// Made with Bob
