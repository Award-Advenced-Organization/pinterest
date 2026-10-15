import { useCallback, useState } from 'react'
import { Link } from 'react-router-dom'
import type { Pin } from '../data/pins'
import { useSession } from '../state/Session'
import { Avatar, Icone } from './Icone'
import { BoutonEnregistrer, ChoixTableau } from './Enregistrer'
import { useHorsDe } from './outils'

/*
 * Une épingle du fil. Au repos : la photo, et le titre quand il en a un. Au
 * survol : un voile sombre, le tableau à gauche, « Enregistrer » à droite, le
 * lien du site en bas et les deux boutons ronds. Le voile reste posé tant
 * qu'un menu est ouvert, sinon le menu se fermerait sous le pointeur.
 */
export function PinCard({ pin, avecCreateur = false }: { pin: Pin; avecCreateur?: boolean }) {
  const { masques, masquer, demasquer } = useSession()
  const [menu, setMenu] = useState<null | 'partager' | 'plus'>(null)
  const [tableauOuvert, setTableauOuvert] = useState(false)
  const fermer = useCallback(() => setMenu(null), [])
  const ref = useHorsDe<HTMLDivElement>(menu !== null, fermer)
  const ratio = (pin.h / pin.w) * 100

  if (masques.includes(pin.id)) {
    return (
      <div className="pin-masque">
        <p>
          <strong>Épingle masquée</strong>
          Nous vous montrerons moins d'Épingles de ce genre.
        </p>
        <button type="button" className="btn btn-gris btn-petit" onClick={() => demasquer(pin.id)}>
          Annuler
        </button>
      </div>
    )
  }

  return (
    <div className={`pin${menu || tableauOuvert ? ' pin-actif' : ''}`} ref={ref}>
      <div className="pin-media" style={{ paddingBottom: `${ratio}%`, background: pin.couleur }}>
        <img src={pin.image} alt="" loading="lazy" decoding="async" />
        <Link to={`/pin/${pin.id}`} className="pin-cible" aria-label={pin.titre} />
        <div className="pin-voile">
          <div className="pin-haut">
            <ChoixTableau pinId={pin.id} clair surBascule={setTableauOuvert} />
            <BoutonEnregistrer pinId={pin.id} />
          </div>
          <div className="pin-bas">
            {pin.lien ? (
              <span className="pin-lien">
                <Icone nom="fleche" taille={14} epaisseur={2.6} />
                <span>{pin.lien}</span>
              </span>
            ) : (
              <span />
            )}
            <span className="pin-ronds">
              <button
                type="button"
                className="btn-rond blanc petit"
                aria-label="Partager"
                onClick={(e) => {
                  e.preventDefault()
                  setMenu((m) => (m === 'partager' ? null : 'partager'))
                }}
              >
                <Icone nom="partager" taille={16} epaisseur={2.4} />
              </button>
            </span>
          </div>
        </div>
      </div>
      {menu === 'partager' && <MenuPartager pin={pin} fermer={fermer} />}
      {menu === 'plus' && (
        <div className="menu menu-plus" role="menu">
          <button type="button" role="menuitem" onClick={() => (masquer(pin.id), fermer())}>
            Masquer l'Épingle
          </button>
          <a role="menuitem" href={pin.image} download={`${pin.id}.jpg`} onClick={fermer}>
            Télécharger l'image
          </a>
          <button type="button" role="menuitem" onClick={fermer}>
            Signaler l'Épingle
          </button>
        </div>
      )}
      {/* Sous la photo, le « … » toujours visible à droite, relevé sur le fil réel */}
      <div className="pin-legende">
        <div className="pin-ligne">
          {pin.titreVisible ? (
            <Link to={`/pin/${pin.id}`} className="pin-titre">
              {pin.titre}
            </Link>
          ) : (
            <span />
          )}
          <button
            type="button"
            className="btn-rond nu pin-plus"
            aria-label="Plus d'options"
            aria-expanded={menu === 'plus'}
            onClick={() => setMenu((m) => (m === 'plus' ? null : 'plus'))}
          >
            <Icone nom="points" taille={16} />
          </button>
        </div>
        {avecCreateur && (
          <Link to={`/${pin.createur.pseudo}`} className="pin-createur">
            <Avatar nom={pin.createur.nom} couleur={pin.createur.couleur} taille={24} />
            <span>{pin.createur.nom}</span>
          </Link>
        )}
      </div>
    </div>
  )
}

export function MenuPartager({ pin, fermer }: { pin: Pin; fermer: () => void }) {
  const { annoncer, utilisateur, conversations, envoyer } = useSession()
  const copier = async () => {
    const adresse = `${window.location.origin}/pin/${pin.id}`
    try {
      await navigator.clipboard.writeText(adresse)
      annoncer({ texte: 'Lien copié', image: pin.image })
    } catch {
      annoncer({ texte: 'Copie impossible dans ce navigateur' })
    }
    fermer()
  }
  return (
    <div className="menu menu-partager" role="dialog" aria-label="Partager">
      <p className="menu-titre centre">Partager</p>
      <div className="partage-ronds">
        <button type="button" onClick={copier}>
          <span className="rond-gris grand">
            <Icone nom="lien" />
          </span>
          Copier le lien
        </button>
        <a href={`mailto:?subject=${encodeURIComponent(pin.titre)}&body=${encodeURIComponent(`${window.location.origin}/pin/${pin.id}`)}`} onClick={fermer}>
          <span className="rond-gris grand">
            <Icone nom="courrier" />
          </span>
          E-mail
        </a>
        {utilisateur && conversations[0] && (
          <button
            type="button"
            onClick={() => {
              envoyer(conversations[0].id, `${pin.titre} : ${window.location.origin}/pin/${pin.id}`)
              annoncer({ texte: `Envoyée à ${conversations[0].avec}`, image: pin.image })
              fermer()
            }}
          >
            <span className="rond-gris grand">
              <Icone nom="bulle" />
            </span>
            {conversations[0].avec}
          </button>
        )}
      </div>
    </div>
  )
}
