import { useCallback, useEffect, useMemo, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { CATEGORIES, CREATEURS, chercher, sansAccents } from '../data/pins'
import { useSession } from '../state/Session'
import { Avatar, Icone } from '../ui/Icone'
import { Masonry, type Element } from '../ui/Masonry'
import { PinCard } from '../ui/PinCard'
import { abrege, useHorsDe } from '../ui/outils'

/*
 * Les résultats. En tête, le filtre de type dans un menu, puis des pastilles
 * de recherches voisines, chacune sur sa couleur pâle. Le filtre « Profils »
 * remplace le masonry par une liste de créateurs.
 */

const TEINTES = ['#c9e2c9', '#f3d6c5', '#d4ddf2', '#efd7ea', '#f2e5b6', '#cfe6e8', '#e3d6c8', '#dcd3f2']
type Filtre = 'epingles' | 'tableaux' | 'profils'
const NOMS_FILTRE: Record<Filtre, string> = { epingles: 'Toutes les Épingles', tableaux: 'Tableaux', profils: 'Profils' }

export function Resultats() {
  const [params] = useSearchParams()
  const q = params.get('q') ?? ''
  const navigate = useNavigate()
  const { tousLesPins } = useSession()
  const [filtre, setFiltre] = useState<Filtre>('epingles')
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  const [pages, setPages] = useState(1)
  const suite = useCallback(() => setPages((p) => p + 1), [])
  useEffect(() => setPages(1), [q])

  const trouves = useMemo(() => {
    const base = chercher(q)
    const crees = tousLesPins.filter((p) => p.createur.id === 'moi' && sansAccents(p.titre.toLowerCase()).includes(sansAccents(q.toLowerCase())))
    return [...crees, ...base]
  }, [q, tousLesPins])

  /* Quarante épingles par page : la liste est déjà complète et sans doublon, on la découvre peu à peu. */
  const elements = useMemo<Element[]>(() => trouves.slice(0, pages * 40).map((pin) => ({ cle: pin.id, pin })), [trouves, pages])
  const encore = elements.length < trouves.length

  const voisines = useMemo(() => {
    const cats = [...new Set(trouves.map((p) => p.categorie))]
    const mots = cats.map((c) => CATEGORIES[c].recherche)
    return [...new Set([...mots, `${q} idées`, `${q} inspiration`, `${q} automne`])].filter((m) => m.trim() && m !== q).slice(0, 8)
  }, [trouves, q])

  const profils = CREATEURS.filter((c) => trouves.some((p) => p.createur.id === c.id))

  return (
    <div className="resultats">
      <div className="pastilles pastilles-resultats">
        <div className="filtre-type" ref={ref}>
          <button type="button" className="pastille filtre" aria-expanded={ouvert} onClick={() => setOuvert((o) => !o)}>
            {NOMS_FILTRE[filtre]}
            <Icone nom="chevron" taille={16} epaisseur={2.6} />
          </button>
          {ouvert && (
            <div className="menu" role="menu">
              {(Object.keys(NOMS_FILTRE) as Filtre[]).map((f) => (
                <button
                  type="button"
                  role="menuitemradio"
                  aria-checked={filtre === f}
                  key={f}
                  onClick={() => {
                    setFiltre(f)
                    fermer()
                  }}
                >
                  {NOMS_FILTRE[f]}
                  {filtre === f && <Icone nom="coche" taille={18} epaisseur={2.6} />}
                </button>
              ))}
            </div>
          )}
        </div>
        {voisines.map((v, i) => (
          <button type="button" key={v} className="pastille teintee" style={{ background: TEINTES[i % TEINTES.length] }} onClick={() => navigate(`/search/pins?q=${encodeURIComponent(v)}`)}>
            {v}
          </button>
        ))}
      </div>

      {filtre === 'profils' ? (
        <ul className="liste-profils">
          {profils.map((c) => (
            <li key={c.id}>
              <Link to={`/${c.pseudo}`}>
                <Avatar nom={c.nom} couleur={c.couleur} taille={64} />
                <span>
                  <strong>{c.nom}</strong>
                  <small>{abrege(c.abonnes)} abonnés</small>
                </span>
              </Link>
            </li>
          ))}
        </ul>
      ) : filtre === 'tableaux' ? (
        <div className="grille-tableaux">
          {[...new Set(trouves.map((p) => p.categorie))].map((c) => {
            const liste = trouves.filter((p) => p.categorie === c)
            return (
              <Link key={c} to={`/search/pins?q=${encodeURIComponent(CATEGORIES[c].recherche)}`} className="carte-tableau">
                <span className="carte-tableau-images">
                  {[0, 1, 2].map((k) => {
                    const p = liste[k % liste.length]
                    return <img key={k} src={p.image} alt="" style={{ background: p.couleur }} />
                  })}
                </span>
                <strong>{CATEGORIES[c].nom}</strong>
                <small>{liste.length} Épingles</small>
              </Link>
            )
          })}
        </div>
      ) : (
        <Masonry elements={elements} rendre={(e) => <PinCard pin={e.pin} avecCreateur={e.pin.titreVisible} />} surFin={suite} chargement={encore} />
      )}
    </div>
  )
}
