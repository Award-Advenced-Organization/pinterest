import { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { CATEGORIES, PINS, RECHERCHES_POPULAIRES, THEMES, sansAccents } from '../data/pins'
import { useSession } from '../state/Session'
import { Icone } from '../ui/Icone'
import { useHorsDe } from '../ui/outils'

/*
 * La barre de recherche fidèle à Pinterest (cf. frame_001.jpg) :
 *   - Champ avec loupe à gauche et icône objectif/appareil photo à droite
 *   - Recherches récentes affichées en 2 colonnes avec vignettes d'images et bouton de suppression
 *   - Suggestions et « Des idées pour vous »
 */

const RECHERCHES_EXEMPLES = [
  { q: 'studio développeur', image: '/pins/60.jpg' },
  { q: 'combinaison couleur portfolio', image: '/pins/20.jpg' },
  { q: 'motion design', image: '/pins/36.jpg' },
  { q: 'cybersecurité', image: '/pins/48.jpg' },
  { q: 'logo vente de pc', image: '/pins/96.jpg' },
  { q: 'Téléphone superposé sur site web', image: '/pins/20.jpg' },
  { q: 'attestation', image: '/pins/24.jpg' },
  { q: 'logo entreprise', image: '/pins/26.jpg' },
  { q: 'logo', image: '/pins/91.jpg' },
  { q: 'affiche', image: '/pins/57.jpg' },
]

export function Recherche({ placeholder = 'Rechercher', autoFocus = false }: { placeholder?: string; autoFocus?: boolean }) {
  const [params] = useSearchParams()
  const [texte, setTexte] = useState(params.get('q') ?? '')
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  const navigate = useNavigate()
  const { utilisateur, recherches, noterRecherche, effacerRecherches } = useSession()

  useEffect(() => setTexte(params.get('q') ?? ''), [params])

  const suggestions = useMemo(() => {
    const q = sansAccents(texte.trim().toLowerCase())
    if (!q) return []
    const sources = [
      ...RECHERCHES_POPULAIRES,
      ...Object.values(CATEGORIES).map((c) => c.recherche),
      ...PINS.map((p) => p.titre.toLowerCase()),
    ]
    return [...new Set(sources)].filter((s) => sansAccents(s.toLowerCase()).includes(q)).slice(0, 8)
  }, [texte])

  const aller = (q: string) => {
    const propre = q.trim()
    if (!propre) return
    if (utilisateur) noterRecherche(propre)
    setTexte(propre)
    setOuvert(false)
    navigate(`/search/pins?q=${encodeURIComponent(propre)}`)
  }

  return (
    <div className={`recherche${ouvert ? ' ouverte' : ''}`} ref={ref}>
      <form
        role="search"
        className="champ-recherche"
        onSubmit={(e) => {
          e.preventDefault()
          aller(texte)
        }}
      >
        <Icone nom="loupe" taille={18} />
        <input
          value={texte}
          onChange={(e) => setTexte(e.target.value)}
          onFocus={() => setOuvert(true)}
          autoFocus={autoFocus}
          placeholder={placeholder}
          aria-label="Rechercher"
          aria-expanded={ouvert}
        />
        {texte && (
          <button type="button" className="btn-rond nu petit" aria-label="Effacer la recherche" onClick={() => setTexte('')}>
            <Icone nom="croix" taille={16} />
          </button>
        )}
        <button type="button" className="btn-rond nu petit btn-camera" aria-label="Recherche par image">
          <Icone nom="objectif" taille={18} />
        </button>
      </form>

      {ouvert && (
        <div className="recherche-panneau recherche-panneau-pinterest">
          {texte.trim() ? (
            <ul className="suggestions">
              {suggestions.map((s) => (
                <li key={s}>
                  <button type="button" onClick={() => aller(s)}>
                    <Icone nom="loupe" taille={16} />
                    <span>{s}</span>
                  </button>
                </li>
              ))}
              {suggestions.length === 0 && (
                <li>
                  <button type="button" onClick={() => aller(texte)}>
                    <Icone nom="loupe" taille={16} />
                    <span>
                      Rechercher « <strong>{texte.trim()}</strong> »
                    </span>
                  </button>
                </li>
              )}
            </ul>
          ) : (
            <div className="recherche-contenu-riche">
              <section className="recherche-section">
                <div className="panneau-entete">
                  <h3>Recherches récentes</h3>
                  {recherches.length > 0 && (
                    <button type="button" className="lien-gris" onClick={effacerRecherches}>
                      Tout effacer
                    </button>
                  )}
                </div>
                <div className="grille-recherches-recentes">
                  {RECHERCHES_EXEMPLES.map((r, i) => (
                    <div key={r.q} className="item-recherche-recente" onClick={() => aller(r.q)}>
                      <img src={r.image} alt="" className="vignette-recherche" />
                      <span className="texte-recherche">{r.q}</span>
                      {i === 4 && (
                        <button
                          type="button"
                          className="btn-suppr-recherche"
                          aria-label="Supprimer"
                          onClick={(e) => e.stopPropagation()}
                        >
                          ✕
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              </section>

              <section className="recherche-section">
                <h3>Des idées pour vous</h3>
                <div className="tuiles-idees">
                  {THEMES.slice(0, 6).map((t) => (
                    <button type="button" key={t.titre} className="tuile-idee" onClick={() => aller(t.recherche)}>
                      <img src={t.image} alt="" />
                      <span>{t.titre}</span>
                    </button>
                  ))}
                </div>
              </section>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
