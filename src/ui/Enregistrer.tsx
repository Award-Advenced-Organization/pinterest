import { useCallback, useEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { useNavigate } from 'react-router-dom'
import { useSession, type Tableau } from '../state/Session'
import { Icone } from './Icone'
import { Modale } from './Modale'

/*
 * Le bouton rouge et son tableau. Déconnecté, il mène à l'inscription : c'est
 * ce que fait le vrai site, il ne laisse rien enregistrer sans compte.
 */
export function BoutonEnregistrer({ pinId, grand = false }: { pinId: string; grand?: boolean }) {
  const { utilisateur, enregistrer, retirer, estEnregistre, dernierTableau } = useSession()
  const navigate = useNavigate()
  const deja = estEnregistre(pinId)
  return (
    <button
      type="button"
      className={`btn ${deja ? 'btn-noir' : 'btn-rouge'}${grand ? ' btn-grand' : ''}`}
      onClick={(e) => {
        e.preventDefault()
        e.stopPropagation()
        if (!utilisateur) return navigate('/signup')
        if (deja) retirer(pinId)
        else enregistrer(pinId, dernierTableau?.id)
      }}
    >
      {deja ? 'Enregistrée' : 'Enregistrer'}
    </button>
  )
}

/*
 * Le choix du tableau. Le menu sort dans un portail, en position fixe sous le
 * bouton : posé dans la carte, il était coupé par l'arrondi de la photo, qui
 * masque tout ce qui dépasse. Au défilement il suit son bouton au lieu de se
 * fermer : le fermer au moindre défilement le faisait disparaître dès qu'une
 * image finissait de charger plus haut dans la page.
 */
export function ChoixTableau({ pinId, clair = false, surBascule }: { pinId: string; clair?: boolean; surBascule?: (ouvert: boolean) => void }) {
  const { utilisateur, tableaux, dernierTableau, estEnregistre, enregistrer, creerTableau } = useSession()
  const navigate = useNavigate()
  const [place, setPlace] = useState<{ top: number; left: number } | null>(null)
  const [filtre, setFiltre] = useState('')
  const [creation, setCreation] = useState(false)
  const bouton = useRef<HTMLButtonElement>(null)
  const menu = useRef<HTMLDivElement>(null)
  const ouvert = place !== null
  const deja = estEnregistre(pinId)
  const nom = deja?.nom ?? dernierTableau?.nom ?? 'Profil'
  const visibles = tableaux.filter((t) => t.nom.toLowerCase().includes(filtre.toLowerCase()))

  const fermer = useCallback(() => setPlace(null), [])
  useEffect(() => surBascule?.(ouvert), [ouvert, surBascule])
  useEffect(() => {
    if (!ouvert) return
    const clic = (e: MouseEvent) => {
      const cible = e.target as Node
      if (!menu.current?.contains(cible) && !bouton.current?.contains(cible)) fermer()
    }
    const touche = (e: KeyboardEvent) => e.key === 'Escape' && fermer()
    let image = 0
    const suivre = () => {
      cancelAnimationFrame(image)
      image = requestAnimationFrame(() => setPlace(calculer()))
    }
    document.addEventListener('mousedown', clic)
    document.addEventListener('keydown', touche)
    window.addEventListener('scroll', suivre, { passive: true })
    window.addEventListener('resize', suivre)
    return () => {
      cancelAnimationFrame(image)
      document.removeEventListener('mousedown', clic)
      document.removeEventListener('keydown', touche)
      window.removeEventListener('scroll', suivre)
      window.removeEventListener('resize', suivre)
    }
  }, [ouvert, fermer])

  /* Sous le bouton s'il y a la place, au-dessus sinon, et jamais hors de l'écran. */
  const calculer = () => {
    const r = bouton.current!.getBoundingClientRect()
    const largeur = Math.min(340, window.innerWidth - 16)
    const hauteur = 470
    const top = r.bottom + 6 + hauteur > window.innerHeight ? Math.max(8, r.top - 6 - hauteur) : r.bottom + 6
    return { top, left: Math.min(Math.max(8, r.left), window.innerWidth - largeur - 8) }
  }

  const basculer = () => (ouvert ? fermer() : setPlace(calculer()))

  const choisir = (t?: Tableau) => {
    enregistrer(pinId, t?.id ?? 'profil')
    fermer()
  }

  return (
    <div className="choix-tableau" onClick={(e) => e.preventDefault()}>
      <button
        ref={bouton}
        type="button"
        className={`choix-tableau-btn${clair ? ' clair' : ''}`}
        aria-expanded={ouvert}
        onClick={(e) => {
          e.stopPropagation()
          if (!utilisateur) return navigate('/signup')
          basculer()
        }}
      >
        <span>{nom}</span>
        <Icone nom="chevron" taille={16} epaisseur={2.6} />
      </button>
      {ouvert && createPortal(
        <div ref={menu} className="menu menu-tableaux" style={place} role="dialog" aria-label="Enregistrer dans un tableau" onClick={(e) => e.stopPropagation()}>
          <p className="menu-titre">Enregistrer</p>
          <label className="champ-recherche petit">
            <Icone nom="loupe" taille={16} />
            <input autoFocus value={filtre} onChange={(e) => setFiltre(e.target.value)} placeholder="Rechercher" />
          </label>
          <div className="menu-defile">
            <p className="menu-sous-titre">Enregistrer sur le profil</p>
            <button type="button" className="ligne-tableau" onClick={() => choisir()}>
              <span className="ligne-tableau-vignette profil" />
              <span className="ligne-tableau-nom">Profil</span>
              <span className="btn btn-rouge btn-petit">Enregistrer</span>
            </button>
            <p className="menu-sous-titre">Tous les tableaux</p>
            {visibles.map((t) => (
              <button type="button" className="ligne-tableau" key={t.id} onClick={() => choisir(t)}>
                <span className="ligne-tableau-vignette" style={t.pins[0] ? { backgroundImage: `url(/pins/${t.pins[0]}.jpg)` } : undefined} />
                <span className="ligne-tableau-nom">
                  {t.nom}
                  {t.secret && <Icone nom="cadenas" taille={14} />}
                </span>
                <span className="btn btn-rouge btn-petit">Enregistrer</span>
              </button>
            ))}
            {visibles.length === 0 && <p className="menu-vide">Aucun tableau ne s'appelle ainsi.</p>}
          </div>
          <button type="button" className="menu-pied" onClick={() => setCreation(true)}>
            <span className="rond-gris">
              <Icone nom="plus" taille={20} epaisseur={2.6} />
            </span>
            Créer un tableau
          </button>
        </div>,
        document.body,
      )}
      {creation && (
        <CreerTableau
          fermer={() => setCreation(false)}
          creer={(n, s) => {
            const t = creerTableau(n, s)
            enregistrer(pinId, t.id)
            setCreation(false)
            fermer()
          }}
        />
      )}
    </div>
  )
}

export function CreerTableau({ fermer, creer }: { fermer: () => void; creer: (nom: string, secret: boolean) => void }) {
  const [nom, setNom] = useState('')
  const [secret, setSecret] = useState(false)
  return (
    <Modale titre="Créer un tableau" fermer={fermer} largeur={540}>
      <form
        className="formulaire"
        onSubmit={(e) => {
          e.preventDefault()
          if (nom.trim()) creer(nom.trim(), secret)
        }}
      >
        <label className="champ">
          <span>Nom</span>
          <input autoFocus value={nom} onChange={(e) => setNom(e.target.value)} placeholder="Par exemple, « Recettes du dimanche »" maxLength={50} />
        </label>
        <label className="bascule-ligne">
          <span className={`bascule${secret ? ' active' : ''}`}>
            <input type="checkbox" checked={secret} onChange={(e) => setSecret(e.target.checked)} />
          </span>
          <span>
            <strong>Garder ce tableau secret</strong>
            <small>Vous seul et vos collaborateurs pourrez le voir.</small>
          </span>
        </label>
        <div className="formulaire-pied">
          <button type="submit" className="btn btn-rouge btn-grand" disabled={!nom.trim()}>
            Créer
          </button>
        </div>
      </form>
    </Modale>
  )
}
