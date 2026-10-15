import { Link } from 'react-router-dom'
import { PINS, RECHERCHES_POPULAIRES, THEMES, melange } from '../data/pins'
import { PinCard } from '../ui/PinCard'

/*
 * Explorer (« Aujourd'hui »). La date du jour en petit, un grand titre centré,
 * une grille de cartes à histoire, puis des recherches populaires, chacune
 * suivie d'une rangée d'épingles.
 */
export function Explorer() {
  const date = new Intl.DateTimeFormat('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }).format(new Date())
  return (
    <div className="explorer">
      <p className="explorer-date">{date}</p>
      <h1 className="explorer-titre">Restez inspiré</h1>
      <div className="grille-histoires">
        {THEMES.map((t) => (
          <Link key={t.titre} to={`/search/pins?q=${encodeURIComponent(t.recherche)}`} className="carte-theme histoire">
            <img src={t.image} alt="" />
            <span className="carte-theme-texte">
              <small>{t.sur_titre}</small>
              <strong>{t.titre}</strong>
            </span>
          </Link>
        ))}
      </div>

      {RECHERCHES_POPULAIRES.slice(0, 4).map((r, i) => (
        <section className="explorer-section" key={r}>
          <p className="explorer-sur">Recherches populaires</p>
          <h2>{r.charAt(0).toUpperCase() + r.slice(1)}</h2>
          <div className="rangee-pins">
            {melange(PINS, i * 11 + 4)
              .slice(0, 5)
              .map((p) => (
                <PinCard key={p.id} pin={p} />
              ))}
          </div>
          <Link to={`/search/pins?q=${encodeURIComponent(r)}`} className="btn btn-gris centre">
            Voir plus d'idées
          </Link>
        </section>
      ))}
    </div>
  )
}
