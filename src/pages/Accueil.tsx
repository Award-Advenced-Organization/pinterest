import { useRef } from 'react'
import { Link } from 'react-router-dom'
import { CATEGORIES, PINS, THEMES, pinsDe, type Categorie } from '../data/pins'
import { PiedPublic, PublicShell } from '../shell/PublicShell'
import { Icone } from '../ui/Icone'

/*
 * L'accueil déconnecté, relevé sur la capture du 15 octobre 2026 : un titre
 * de saison à gauche avec ses deux boutons, un collage de six photos à droite,
 * puis des rangées de tableaux d'idées qui défilent à l'horizontale.
 */

const COLLAGE = ['102', '110', '95', '75', '63', '116']

export function Accueil() {
  return (
    <PublicShell accueil>
      <section className="ouverture">
        <div className="ouverture-texte">
          <h1>Faites entrer l'automne chez vous</h1>
          <div className="ouverture-actions">
            <Link to="/signup" className="btn btn-rouge">
              Inscrivez-vous gratuitement
            </Link>
            <Link to="/login" className="btn btn-gris">
              J'ai déjà un compte
            </Link>
          </div>
        </div>
        <div className="collage" aria-hidden="true">
          {COLLAGE.map((id, i) => (
            <img key={id} src={`/pins/${id}.jpg`} alt="" className={`collage-${i + 1}`} />
          ))}
        </div>
      </section>

      <Rangee titre="D'autres idées de saison" categories={['cuisine', 'deco', 'nature', 'mode', 'photo']} />
      <Rangee titre="Envie d'ailleurs" categories={['voyage', 'ville', 'art', 'tech', 'nature']} decalage={3} />

      <section className="themes-accueil">
        <h2>Les thèmes du moment</h2>
        <div className="grille-themes">
          {THEMES.slice(0, 3).map((t) => (
            <Link key={t.titre} to={`/search/pins?q=${encodeURIComponent(t.recherche)}`} className="carte-theme">
              <img src={t.image} alt="" />
              <span className="carte-theme-texte">
                <small>{t.sur_titre}</small>
                <strong>{t.titre}</strong>
              </span>
            </Link>
          ))}
        </div>
      </section>
      <PiedPublic />
    </PublicShell>
  )
}

function Rangee({ titre, categories, decalage = 0 }: { titre: string; categories: Categorie[]; decalage?: number }) {
  const piste = useRef<HTMLDivElement>(null)
  const defiler = (sens: number) => piste.current?.scrollBy({ left: sens * piste.current.clientWidth * 0.8, behavior: 'smooth' })
  return (
    <section className="rangee">
      <div className="rangee-entete">
        <h2>{titre}</h2>
        <Link to="/ideas" className="btn btn-gris">
          En voir plus
        </Link>
      </div>
      <div className="rangee-cadre">
        <div className="rangee-piste" ref={piste}>
          {categories.map((c, i) => {
            const liste = pinsDe(c)
            const trio = [0, 1, 2].map((k) => liste[(k + decalage + i) % liste.length] ?? PINS[k])
            return (
              <Link key={c} to={`/search/pins?q=${encodeURIComponent(CATEGORIES[c].recherche)}`} className="carte-tableau">
                <span className="carte-tableau-images">
                  {trio.map((p) => (
                    <img key={p.id} src={p.image} alt="" style={{ background: p.couleur }} />
                  ))}
                </span>
                <strong>{CATEGORIES[c].nom}</strong>
                <small>{liste.length} Épingles</small>
              </Link>
            )
          })}
        </div>
        <button type="button" className="btn-rond blanc rangee-suivant" aria-label="Suivant" onClick={() => defiler(1)}>
          <Icone nom="droite" taille={20} epaisseur={2.6} />
        </button>
      </div>
    </section>
  )
}
