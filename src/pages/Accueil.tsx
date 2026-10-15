import { useRef } from 'react'
import { Link } from 'react-router-dom'
import { CATEGORIES, PINS, THEMES, pinsDe, type Categorie } from '../data/pins'
import { PiedPublic, PublicShell } from '../shell/PublicShell'
import { Icone } from '../ui/Icone'

/*
 * L'accueil déconnecté (Landing Page), relevé au pixel près sur la capture réelle
 * de https://fr.pinterest.com/ :
 *   - Titre hero : « Créez la vie que vous aimez sur Pinterest »
 *   - Bouton rouge « Rejoignez Pinterest gratuitement » + bouton gris « J'ai déjà un compte »
 *   - Section « Plus d'idées gagnantes » avec le bouton « Tout voir » et les cartes à 3 volets
 *   - Rangées d'idées défilantes et thèmes du moment
 */

const COLLAGE = ['102', '110', '95', '75', '63', '116']

const IDEES_GAGNANTES = [
  {
    titre: 'Coiffures sportives faciles',
    auteur: 'Pinterest France',
    epingles: 78,
    temps: '4 mois',
    images: ['/pins/65.jpg', '/pins/21.jpg', '/pins/64.jpg'],
    recherche: 'coiffure sportive',
  },
  {
    titre: 'Blokecore : styliser le maillot de foot',
    auteur: 'Pinterest France',
    epingles: 89,
    temps: '4 mois',
    images: ['/pins/22.jpg', '/pins/26.jpg', '/pins/103.jpg'],
    recherche: 'blokecore style',
  },
  {
    titre: 'Coupes cheveux inspirées du foot',
    auteur: 'Pinterest France',
    epingles: 55,
    temps: '4 mois',
    images: ['/pins/64.jpg', '/pins/65.jpg', '/pins/22.jpg'],
    recherche: 'coupe cheveux',
  },
  {
    titre: "Manucures pour exprimer l'esprit d'équipe",
    auteur: 'Pinterest France',
    epingles: 42,
    temps: '4 mois',
    images: ['/pins/25.jpg', '/pins/41.jpg', '/pins/82.jpg'],
    recherche: 'manucure nail art',
  },
]

export function Accueil() {
  return (
    <PublicShell accueil>
      {/* Hero section réelle de Pinterest */}
      <section className="ouverture">
        <div className="ouverture-texte">
          <h1>Créez la vie que vous aimez sur Pinterest</h1>
          <div className="ouverture-actions">
            <Link to="/signup" className="btn btn-rouge">
              Rejoignez Pinterest gratuitement
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

      {/* Section officielle « Plus d'idées gagnantes » */}
      <section className="rangee rangee-gagnantes">
        <div className="rangee-entete">
          <h2>Plus d'idées gagnantes</h2>
          <Link to="/ideas" className="btn btn-gris">
            Tout voir
          </Link>
        </div>
        <div className="grille-gagnantes">
          {IDEES_GAGNANTES.map((idee) => (
            <Link
              key={idee.titre}
              to={`/search/pins?q=${encodeURIComponent(idee.recherche)}`}
              className="carte-gagnante"
            >
              <div className="gagnante-visuels">
                <img className="gagnante-gauche" src={idee.images[0]} alt="" />
                <div className="gagnante-droite">
                  <img src={idee.images[1]} alt="" />
                  <img src={idee.images[2]} alt="" />
                </div>
              </div>
              <strong className="gagnante-titre">{idee.titre}</strong>
              <div className="gagnante-meta">
                <span className="gagnante-auteur">
                  {idee.auteur}
                  <span className="pastille-verifie" aria-label="Compte vérifié">
                    <svg width="14" height="14" viewBox="0 0 16 16" fill="#e60023">
                      <path d="M8 0a8 8 0 1 0 0 16A8 8 0 0 0 8 0Zm3.7 6.3-4.5 4.5a1 1 0 0 1-1.4 0L3.8 8.8a1 1 0 0 1 1.4-1.4L7 9.2l3.3-3.3a1 1 0 0 1 1.4 1.4Z" />
                    </svg>
                  </span>
                </span>
                <span className="gagnante-chiffres">
                  {idee.epingles} Épingles · {idee.temps}
                </span>
              </div>
            </Link>
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
          <Icone nom="droite" taille={20} />
        </button>
      </div>
    </section>
  )
}
