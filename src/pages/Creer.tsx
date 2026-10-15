import { useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import type { Categorie, Pin } from '../data/pins'
import { useSession } from '../state/Session'
import { Icone } from '../ui/Icone'

/*
 * Le créateur d'Épingle. Une barre « Créer une Épingle / Publier », la zone
 * de dépôt à gauche, le formulaire à droite. Le formulaire reste grisé tant
 * qu'il n'y a pas d'image, et « Publier » aussi : un geste sans effet se
 * désactive. L'image est réduite à 736 px avant d'être gardée, pour tenir dans
 * le stockage du navigateur.
 */
export function Creer() {
  const { utilisateur, tableaux, publier, enregistrer, annoncer } = useSession()
  const navigate = useNavigate()
  const [image, setImage] = useState<{ src: string; w: number; h: number } | null>(null)
  const [titre, setTitre] = useState('')
  const [description, setDescription] = useState('')
  const [lien, setLien] = useState('')
  const [tableau, setTableau] = useState(tableaux[0]?.id ?? '')
  const [survol, setSurvol] = useState(false)
  const [erreur, setErreur] = useState('')
  const champ = useRef<HTMLInputElement>(null)

  const charger = (fichier?: File) => {
    if (!fichier) return
    if (!fichier.type.startsWith('image/')) return setErreur('Choisissez une image (.jpg, .png, .webp).')
    if (fichier.size > 20 * 1024 * 1024) return setErreur('Cette image dépasse 20 Mo.')
    setErreur('')
    const lecteur = new FileReader()
    lecteur.onload = () => {
      const img = new Image()
      img.onload = () => {
        const echelle = Math.min(1, 736 / img.width)
        const toile = document.createElement('canvas')
        toile.width = Math.round(img.width * echelle)
        toile.height = Math.round(img.height * echelle)
        toile.getContext('2d')!.drawImage(img, 0, 0, toile.width, toile.height)
        setImage({ src: toile.toDataURL('image/jpeg', 0.82), w: toile.width, h: toile.height })
      }
      img.src = String(lecteur.result)
    }
    lecteur.readAsDataURL(fichier)
  }

  const publierPin = () => {
    if (!image || !utilisateur) return
    const pin: Pin = {
      id: `moi-${Date.now()}`,
      image: image.src,
      w: image.w,
      h: image.h,
      couleur: '#dcdcd7',
      titre: titre.trim() || 'Sans titre',
      description: description.trim(),
      categorie: 'art' as Categorie,
      createur: { id: 'moi', nom: utilisateur.nom, pseudo: utilisateur.pseudo, couleur: utilisateur.couleur, abonnes: 0 },
      lien: lien.trim() || undefined,
      photographe: utilisateur.nom,
      titreVisible: Boolean(titre.trim()),
    }
    publier(pin)
    if (tableau) enregistrer(pin.id, tableau)
    annoncer({ texte: 'Votre Épingle a été publiée', image: pin.image })
    navigate(`/pin/${pin.id}`)
  }

  return (
    <div className="creer">
      <header className="creer-barre">
        <h1>Créer une Épingle</h1>
        <button type="button" className="btn btn-rouge" disabled={!image} onClick={publierPin}>
          Publier
        </button>
      </header>
      <div className="creer-corps">
        <div
          className={`depot${survol ? ' survol' : ''}${image ? ' plein' : ''}`}
          onDragOver={(e) => {
            e.preventDefault()
            setSurvol(true)
          }}
          onDragLeave={() => setSurvol(false)}
          onDrop={(e) => {
            e.preventDefault()
            setSurvol(false)
            charger(e.dataTransfer.files[0])
          }}
        >
          {image ? (
            <div className="depot-apercu">
              <img src={image.src} alt="Aperçu de votre Épingle" />
              <button type="button" className="btn-rond blanc depot-retirer" aria-label="Retirer l'image" onClick={() => setImage(null)}>
                <Icone nom="croix" taille={18} epaisseur={2.6} />
              </button>
            </div>
          ) : (
            <button type="button" className="depot-zone" onClick={() => champ.current?.click()}>
              <span className="rond-noir">
                <Icone nom="envoyer" epaisseur={2.6} />
              </span>
              <strong>Choisissez un fichier ou glissez-déposez-le ici</strong>
              <small>Une image de bonne qualité, en .jpg de préférence, de moins de 20 Mo.</small>
            </button>
          )}
          <input ref={champ} type="file" accept="image/*" hidden onChange={(e) => charger(e.target.files?.[0])} />
          {erreur && (
            <p className="erreur" role="alert">
              {erreur}
            </p>
          )}
        </div>

        <fieldset className="creer-formulaire" disabled={!image}>
          <label className="champ">
            <span className="etiquette">Titre</span>
            <input value={titre} onChange={(e) => setTitre(e.target.value)} placeholder="Ajouter un titre" maxLength={100} />
          </label>
          <label className="champ">
            <span className="etiquette">Description</span>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Ajoutez une description détaillée" rows={4} maxLength={500} />
          </label>
          <label className="champ">
            <span className="etiquette">Lien</span>
            <input value={lien} onChange={(e) => setLien(e.target.value)} placeholder="Ajouter un lien" />
          </label>
          <label className="champ champ-select">
            <span className="etiquette">Tableau</span>
            <select value={tableau} onChange={(e) => setTableau(e.target.value)}>
              {tableaux.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.nom}
                </option>
              ))}
            </select>
            <Icone nom="chevron" taille={18} epaisseur={2.6} />
          </label>
        </fieldset>
      </div>
    </div>
  )
}
