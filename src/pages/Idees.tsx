import { useState } from 'react'
import { Link } from 'react-router-dom'
import { CATEGORIES, THEMES, pinsDe, type Categorie } from '../data/pins'
import { PiedPublic, PublicShell } from '../shell/PublicShell'

/*
 * La page Idées, relevée sur la capture : trois grandes cartes de thème
 * (sur-titre fin, titre gras centré en bas), un bouton « En voir plus », puis
 * les catégories en tuiles. Chaque « En voir plus » déplie la suite.
 */
export function Idees() {
  const [themes, setThemes] = useState(3)
  const [cats, setCats] = useState(5)
  const toutes = Object.keys(CATEGORIES) as Categorie[]
  return (
    <PublicShell>
      <div className="page-idees">
        <h1>Explorez les plus beaux thèmes de Pinterest</h1>
        <div className="grille-themes">
          {THEMES.slice(0, themes).map((t) => (
            <Link key={t.titre} to={`/search/pins?q=${encodeURIComponent(t.recherche)}`} className="carte-theme">
              <img src={t.image} alt="" />
              <span className="carte-theme-texte">
                <small>{t.sur_titre}</small>
                <strong>{t.titre}</strong>
              </span>
            </Link>
          ))}
        </div>
        {themes < THEMES.length && (
          <button type="button" className="btn btn-gris centre" onClick={() => setThemes(THEMES.length)}>
            En voir plus
          </button>
        )}

        <h2>Parcourir par catégorie</h2>
        <div className="grille-categories">
          {toutes.slice(0, cats).map((c) => (
            <Link key={c} to={`/search/pins?q=${encodeURIComponent(CATEGORIES[c].recherche)}`} className="tuile-categorie">
              <img src={pinsDe(c)[1]?.image} alt="" />
              <span>{CATEGORIES[c].nom}</span>
            </Link>
          ))}
        </div>
        {cats < toutes.length && (
          <button type="button" className="btn btn-gris centre" onClick={() => setCats(toutes.length)}>
            En voir plus
          </button>
        )}
      </div>
      <PiedPublic />
    </PublicShell>
  )
}
