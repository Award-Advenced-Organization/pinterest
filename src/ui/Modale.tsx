import { useEffect, type ReactNode } from 'react'
import { createPortal } from 'react-dom'
import { Icone } from './Icone'

export function Modale({
  titre,
  fermer,
  children,
  largeur = 480,
}: {
  titre?: string
  fermer: () => void
  children: ReactNode
  largeur?: number
}) {
  useEffect(() => {
    const touche = (e: KeyboardEvent) => e.key === 'Escape' && fermer()
    document.addEventListener('keydown', touche)
    const avant = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', touche)
      document.body.style.overflow = avant
    }
  }, [fermer])

  return createPortal(
    <div className="voile" onMouseDown={(e) => e.target === e.currentTarget && fermer()}>
      <div className="modale" role="dialog" aria-modal="true" aria-label={titre} style={{ maxWidth: largeur }}>
        <button type="button" className="btn-rond modale-fermer" onClick={fermer} aria-label="Fermer">
          <Icone nom="croix" taille={20} epaisseur={2.6} />
        </button>
        {titre && <h2 className="modale-titre">{titre}</h2>}
        {children}
      </div>
    </div>,
    document.body,
  )
}
