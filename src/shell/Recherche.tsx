import { useCallback, useEffect, useMemo, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { CATEGORIES, PINS, RECHERCHES_POPULAIRES, THEMES, chercher, sansAccents } from '../data/pins'
import { useSession } from '../state/Session'
import { Icone } from '../ui/Icone'
import { useHorsDe } from '../ui/outils'

/*
 * La barre de recherche. Au focus et vide : les recherches récentes, puis des
 * idées en vignettes. En tapant : des suggestions qui se resserrent à chaque
 * lettre. Entrée ou un clic mène aux résultats.
 */
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
        <Icone nom="loupe" taille={18} epaisseur={2.4} />
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
            <Icone nom="croix" taille={16} epaisseur={2.6} />
          </button>
        )}
      </form>
      {ouvert && (
        <div className="recherche-panneau">
          {texte.trim() ? (
            <ul className="suggestions">
              {suggestions.map((s) => (
                <li key={s}>
                  <button type="button" onClick={() => aller(s)}>
                    <Icone nom="loupe" taille={16} epaisseur={2.4} />
                    <span>{s}</span>
                  </button>
                </li>
              ))}
              {suggestions.length === 0 && (
                <li>
                  <button type="button" onClick={() => aller(texte)}>
                    <Icone nom="loupe" taille={16} epaisseur={2.4} />
                    <span>
                      Rechercher « <strong>{texte.trim()}</strong> »
                    </span>
                  </button>
                </li>
              )}
            </ul>
          ) : (
            <>
              {utilisateur && recherches.length > 0 && (
                <section>
                  <div className="panneau-entete">
                    <h3>Recherches récentes</h3>
                    <button type="button" className="lien-gris" onClick={effacerRecherches}>
                      Tout effacer
                    </button>
                  </div>
                  <div className="pastilles">
                    {recherches.map((r) => (
                      <button type="button" key={r} className="pastille" onClick={() => aller(r)}>
                        {r}
                      </button>
                    ))}
                  </div>
                </section>
              )}
              <section>
                <h3>Idées pour vous</h3>
                <div className="tuiles-idees">
                  {THEMES.slice(0, 6).map((t) => (
                    <button type="button" key={t.titre} className="tuile-idee" onClick={() => aller(t.recherche)}>
                      <img src={t.image} alt="" />
                      <span>{t.titre}</span>
                    </button>
                  ))}
                </div>
              </section>
              <section>
                <h3>Populaire sur Pinterest</h3>
                <div className="tuiles-idees">
                  {RECHERCHES_POPULAIRES.slice(0, 6).map((r) => (
                    <button type="button" key={r} className="tuile-idee" onClick={() => aller(r)}>
                      <img src={(chercher(r)[0] ?? PINS[0]).image} alt="" />
                      <span>{r}</span>
                    </button>
                  ))}
                </div>
              </section>
              {!utilisateur && (
                <p className="panneau-note">
                  <Link to="/login">Connectez-vous</Link> pour retrouver vos recherches récentes.
                </p>
              )}
            </>
          )}
        </div>
      )}
    </div>
  )
}
