import { useState } from 'react'
import { createPortal } from 'react-dom'
import { Link } from 'react-router-dom'

/*
 * Le choix des cookies, posé au centre sur un voile au premier passage, comme
 * sur le vrai site. Le choix est gardé dans le navigateur ; ce projet ne
 * dépose de toute façon aucun traceur.
 */
export function Cookies() {
  const [choix, setChoix] = useState<string | null>(() => {
    try {
      return localStorage.getItem('pin-cookies')
    } catch {
      return 'inconnu'
    }
  })
  const [details, setDetails] = useState(false)
  const [mesure, setMesure] = useState(false)
  const [pub, setPub] = useState(false)

  if (choix) return null

  const retenir = (valeur: string) => {
    try {
      localStorage.setItem('pin-cookies', valeur)
    } catch {
      /* le choix vaut pour cette visite */
    }
    setChoix(valeur)
  }

  return createPortal(
    <div className="voile voile-cookies">
      <div className="cookies" role="dialog" aria-modal="true" aria-labelledby="cookies-titre">
        <h2 id="cookies-titre">Accepter l'utilisation de cookies ?</h2>
        {details ? (
          <div className="cookies-details">
            <label className="bascule-ligne">
              <span className="bascule active desactivee">
                <input type="checkbox" checked disabled />
              </span>
              <span>
                <strong>Nécessaires</strong>
                <small>Ils font fonctionner le site et ne peuvent pas être désactivés.</small>
              </span>
            </label>
            <label className="bascule-ligne">
              <span className={`bascule${mesure ? ' active' : ''}`}>
                <input type="checkbox" checked={mesure} onChange={(e) => setMesure(e.target.checked)} />
              </span>
              <span>
                <strong>Mesure d'audience</strong>
                <small>Nous aident à comprendre comment le site est utilisé.</small>
              </span>
            </label>
            <label className="bascule-ligne">
              <span className={`bascule${pub ? ' active' : ''}`}>
                <input type="checkbox" checked={pub} onChange={(e) => setPub(e.target.checked)} />
              </span>
              <span>
                <strong>Publicité personnalisée</strong>
                <small>Adaptent les annonces à vos centres d'intérêt.</small>
              </span>
            </label>
          </div>
        ) : (
          <p>
            Ils servent à afficher des annonces, à personnaliser ce que vous voyez et à mesurer la fréquentation. Le détail est dans notre{' '}
            <Link to="/info/confidentialite">politique relative aux cookies</Link>.
          </p>
        )}
        <div className="cookies-actions">
          <button type="button" className="btn btn-gris" onClick={() => retenir('refus')}>
            Tout refuser
          </button>
          <span className="cookies-droite">
            {details ? (
              <button type="button" className="btn btn-gris" onClick={() => retenir(`choix:${mesure ? 'm' : ''}${pub ? 'p' : ''}`)}>
                Enregistrer mes choix
              </button>
            ) : (
              <button type="button" className="btn btn-gris" onClick={() => setDetails(true)}>
                Laissez-moi choisir
              </button>
            )}
            <button type="button" className="btn btn-gris" onClick={() => retenir('tout')}>
              Tout accepter
            </button>
          </span>
        </div>
      </div>
    </div>,
    document.body,
  )
}
