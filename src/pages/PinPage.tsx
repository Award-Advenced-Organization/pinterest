import { useCallback, useMemo, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { COMMENTAIRES, melange, type Commentaire } from '../data/pins'
import { useSession } from '../state/Session'
import { Avatar, Icone } from '../ui/Icone'
import { BoutonEnregistrer, ChoixTableau } from '../ui/Enregistrer'
import { Masonry, type Element } from '../ui/Masonry'
import { MenuPartager, PinCard } from '../ui/PinCard'
import { abrege, useHorsDe } from '../ui/outils'
import { Introuvable } from './Introuvable'

/*
 * La page d'une épingle. Une grande carte arrondie : la photo à gauche, à
 * droite la barre d'actions, le tableau et « Enregistrer », le titre, le
 * créateur, les commentaires et la saisie collée en bas. Dessous, « Plus de
 * contenu à découvrir » reprend le fil, d'abord dans la même catégorie.
 */
export function PinPage() {
  const { id = '' } = useParams()
  const { tousLesPins, utilisateur, jaime, aimer, abonnements, suivre } = useSession()
  const navigate = useNavigate()
  const pin = tousLesPins.find((p) => p.id === id)
  const [commentaires, setCommentaires] = useState<Commentaire[]>(() => COMMENTAIRES.slice(0, (Number(id) % 3) + 1))
  const [replies, setReplies] = useState(true)
  const [saisie, setSaisie] = useState('')
  const [menu, setMenu] = useState<null | 'partager' | 'plus'>(null)
  const fermer = useCallback(() => setMenu(null), [])
  const ref = useHorsDe<HTMLDivElement>(menu !== null, fermer)
  const [pages, setPages] = useState(1)

  const autres = useMemo<Element[]>(() => {
    if (!pin) return []
    const memes = tousLesPins.filter((p) => p.id !== pin.id && p.categorie === pin.categorie)
    const reste = melange(
      tousLesPins.filter((p) => p.id !== pin.id && p.categorie !== pin.categorie),
      Number(pin.id) || 3,
    )
    const base = [...melange(memes, 5), ...reste]
    return Array.from({ length: pages }, (_, n) => (n === 0 ? base : melange(base, n * 13)).map((p) => ({ cle: `${p.id}-${n}`, pin: p }))).flat()
  }, [pin, tousLesPins, pages])

  if (!pin) return <Introuvable />

  const aime = jaime.includes(pin.id)
  const reactions = 40 + ((Number(pin.id) * 37) % 300) + (aime ? 1 : 0)
  const abonne = abonnements.includes(pin.createur.id)

  return (
    <div className="page-pin">
      <button type="button" className="btn-rond nu retour" aria-label="Retour" onClick={() => (window.history.length > 1 ? navigate(-1) : navigate('/'))}>
        <Icone nom="retour" />
      </button>
      <article className="carte-pin">
        <div className="carte-pin-image" style={{ background: pin.couleur }}>
          <img src={pin.image} alt={pin.titre} style={{ aspectRatio: `${pin.w} / ${pin.h}` }} />
          <Link to={`/search/pins?q=${encodeURIComponent(pin.titre)}`} className="btn-rond blanc loupe-visuelle" aria-label="Rechercher des images similaires">
            <Icone nom="objectif" taille={20} />
          </Link>
        </div>
        <div className="carte-pin-infos">
          <div className="carte-pin-barre" ref={ref}>
            <div className="carte-pin-icones">
              <button
                type="button"
                className={`btn-rond nu reaction${aime ? ' aime' : ''}`}
                aria-label={aime ? 'Retirer la réaction' : 'Réagir'}
                aria-pressed={aime}
                onClick={() => (utilisateur ? aimer(pin.id) : navigate('/signup'))}
              >
                <Icone nom="coeur" plein={aime} />
              </button>
              <span className="compte-reactions">{reactions}</span>
              <button type="button" className="btn-rond nu" aria-label="Partager" aria-expanded={menu === 'partager'} onClick={() => setMenu((m) => (m === 'partager' ? null : 'partager'))}>
                <Icone nom="partager" />
              </button>
              <button type="button" className="btn-rond nu" aria-label="Plus d'options" aria-expanded={menu === 'plus'} onClick={() => setMenu((m) => (m === 'plus' ? null : 'plus'))}>
                <Icone nom="points" />
              </button>
              {menu === 'partager' && <MenuPartager pin={pin} fermer={fermer} />}
              {menu === 'plus' && (
                <div className="menu menu-plus haut" role="menu">
                  <a role="menuitem" href={pin.image} download={`${pin.id}.jpg`} onClick={fermer}>
                    Télécharger l'image
                  </a>
                  <button type="button" role="menuitem" onClick={fermer}>
                    Signaler l'Épingle
                  </button>
                </div>
              )}
            </div>
            <div className="carte-pin-enregistrer">
              <ChoixTableau pinId={pin.id} />
              <BoutonEnregistrer pinId={pin.id} grand />
            </div>
          </div>

          <div className="carte-pin-defile">
            {pin.lien && (
              <p className="carte-pin-lien">
                <Icone nom="fleche" taille={16} epaisseur={2.4} />
                {pin.lien}
              </p>
            )}
            <h1>{pin.titre}</h1>
            <p className="carte-pin-desc">{pin.description}</p>
            <p className="carte-pin-credit">Photo : {pin.photographe}, via Unsplash</p>

            <div className="createur">
              <Link to={`/${pin.createur.pseudo}`} className="createur-lien">
                <Avatar nom={pin.createur.nom} couleur={pin.createur.couleur} taille={48} />
                <span>
                  <strong>{pin.createur.nom}</strong>
                  <small>{abrege(pin.createur.abonnes + (abonne ? 1 : 0))} abonnés</small>
                </span>
              </Link>
              {pin.createur.id !== 'moi' && (
                <button type="button" className={`btn ${abonne ? 'btn-noir' : 'btn-gris'}`} onClick={() => (utilisateur ? suivre(pin.createur.id) : navigate('/signup'))}>
                  {abonne ? 'Abonné(e)' : "S'abonner"}
                </button>
              )}
            </div>

            <section className="commentaires">
              <button type="button" className="commentaires-titre" aria-expanded={replies} onClick={() => setReplies((r) => !r)}>
                {commentaires.length} commentaire{commentaires.length > 1 ? 's' : ''}
                <Icone nom="chevron" taille={20} epaisseur={2.6} className={replies ? 'tourne' : undefined} />
              </button>
              {replies && (
                <ul>
                  {commentaires.map((c, i) => (
                    <li key={i}>
                      <Avatar nom={c.auteur} couleur={c.couleur} taille={32} />
                      <p>
                        <strong>{c.auteur}</strong> {c.texte}
                        <small>{c.il_y_a}</small>
                      </p>
                    </li>
                  ))}
                </ul>
              )}
            </section>
          </div>

          <form
            className="saisie-commentaire"
            onSubmit={(e) => {
              e.preventDefault()
              if (!utilisateur) return navigate('/signup')
              if (!saisie.trim()) return
              setCommentaires((l) => [...l, { auteur: utilisateur.nom, couleur: utilisateur.couleur, texte: saisie.trim(), il_y_a: "À l'instant" }])
              setSaisie('')
              setReplies(true)
            }}
          >
            <p>Qu'en pensez-vous ?</p>
            <div className="saisie-ligne">
              {utilisateur && <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={48} />}
              <label className="champ-commentaire">
                <input value={saisie} onChange={(e) => setSaisie(e.target.value)} placeholder="Ajouter un commentaire" aria-label="Ajouter un commentaire" />
                <Icone nom="sourire" taille={20} />
              </label>
              <button type="submit" className="btn-rond rouge" aria-label="Publier le commentaire" disabled={!saisie.trim()}>
                <Icone nom="envoyer" taille={20} epaisseur={2.6} />
              </button>
            </div>
          </form>
        </div>
      </article>

      <h2 className="titre-centre">Plus de contenu à découvrir</h2>
      <Masonry elements={autres} rendre={(e) => <PinCard pin={e.pin} />} surFin={() => setPages((p) => Math.min(p + 1, 4))} chargement={pages < 4} />
    </div>
  )
}
