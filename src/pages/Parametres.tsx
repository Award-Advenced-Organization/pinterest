import { useEffect, useState } from 'react'
import { NavLink, useParams } from 'react-router-dom'
import { useSession, type Theme } from '../state/Session'
import { Avatar } from '../ui/Icone'

/*
 * Les paramètres. La liste des rubriques à gauche, la rubrique à droite, et
 * pour le profil la barre collée en bas « Réinitialiser / Enregistrer », qui
 * ne s'allume que si quelque chose a changé.
 */
const RUBRIQUES = [
  { id: '', nom: 'Modification du profil' },
  { id: 'compte', nom: 'Gestion du compte' },
  { id: 'affichage', nom: "Mode d'affichage" },
  { id: 'notifications', nom: 'Notifications' },
  { id: 'confidentialite', nom: 'Confidentialité et données' },
]

export function Parametres() {
  const { rubrique = '' } = useParams()
  return (
    <div className="parametres">
      <nav className="parametres-nav" aria-label="Rubriques des paramètres">
        {RUBRIQUES.map((r) => (
          <NavLink key={r.id} to={r.id ? `/settings/${r.id}` : '/settings'} end className={({ isActive }) => (isActive ? 'actif' : '')}>
            {r.nom}
          </NavLink>
        ))}
      </nav>
      <section className="parametres-contenu">
        {rubrique === '' && <EditionProfil />}
        {rubrique === 'compte' && <Compte />}
        {rubrique === 'affichage' && <Affichage />}
        {rubrique === 'notifications' && (
          <Bascules
            titre="Notifications"
            intro="Choisissez ce que nous vous signalons, et comment."
            lignes={['Sur Pinterest', 'Par e-mail', 'Notifications push']}
          />
        )}
        {rubrique === 'confidentialite' && (
          <Bascules
            titre="Confidentialité et données"
            intro="Réglez ce que les autres voient de vous et ce qui sert à personnaliser votre fil."
            lignes={['Masquer votre profil des moteurs de recherche', 'Personnaliser selon les sites visités', 'Personnaliser selon les informations de partenaires']}
          />
        )}
      </section>
    </div>
  )
}

function EditionProfil() {
  const { utilisateur, modifierProfil, annoncer } = useSession()
  const depart = { nom: utilisateur?.nom ?? '', apropos: utilisateur?.apropos ?? '', site: utilisateur?.site ?? '', pseudo: utilisateur?.pseudo ?? '' }
  const [champs, setChamps] = useState(depart)
  useEffect(() => setChamps(depart), [utilisateur]) // eslint-disable-line react-hooks/exhaustive-deps
  if (!utilisateur) return null
  const change = JSON.stringify(champs) !== JSON.stringify(depart)
  const maj = (k: keyof typeof champs) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setChamps((c) => ({ ...c, [k]: e.target.value }))

  return (
    <>
      <h1>Modification du profil</h1>
      <p className="intro">Gardez vos informations à jour. Ce qui figure ici est visible par les personnes qui consultent votre profil.</p>
      <div className="formulaire">
        <div className="photo-profil">
          <span className="etiquette">Photo</span>
          <span className="photo-ligne">
            <Avatar nom={champs.nom || utilisateur.nom} couleur={utilisateur.couleur} taille={75} />
          </span>
        </div>
        <label className="champ">
          <span className="etiquette">Nom</span>
          <input value={champs.nom} onChange={maj('nom')} />
        </label>
        <label className="champ">
          <span className="etiquette">À propos</span>
          <textarea value={champs.apropos} onChange={maj('apropos')} placeholder="Racontez votre histoire" rows={3} maxLength={500} />
        </label>
        <label className="champ">
          <span className="etiquette">Site web</span>
          <input value={champs.site} onChange={maj('site')} placeholder="Ajoutez un lien pour générer du trafic vers votre site" />
        </label>
        <label className="champ">
          <span className="etiquette">Nom d'utilisateur</span>
          <input value={champs.pseudo} onChange={maj('pseudo')} />
          <small className="aide">www.pinterest.fr/{champs.pseudo}</small>
        </label>
      </div>
      <div className="barre-collee">
        <button type="button" className="btn btn-gris" disabled={!change} onClick={() => setChamps(depart)}>
          Réinitialiser
        </button>
        <button
          type="button"
          className="btn btn-rouge"
          disabled={!change || !champs.nom.trim()}
          onClick={() => {
            modifierProfil(champs)
            annoncer({ texte: 'Profil mis à jour' })
          }}
        >
          Enregistrer
        </button>
      </div>
    </>
  )
}

function Compte() {
  const { utilisateur } = useSession()
  return (
    <>
      <h1>Gestion du compte</h1>
      <p className="intro">Modifiez vos informations personnelles ou le type de compte.</p>
      <h2>Votre compte</h2>
      <div className="formulaire">
        <label className="champ">
          <span className="etiquette">E-mail · Privé</span>
          <input value={utilisateur?.email ?? ''} readOnly />
        </label>
        <div className="ligne-reglage">
          <span>
            <strong>Mot de passe</strong>
            <small>Aucun mot de passe n'est gardé dans cette reproduction.</small>
          </span>
          <button type="button" className="btn btn-gris" disabled>
            Changer
          </button>
        </div>
      </div>
    </>
  )
}

function Affichage() {
  const { theme, choisirTheme } = useSession()
  const options: { id: Theme; nom: string; aide: string }[] = [
    { id: 'systeme', nom: 'Comme le système', aide: "Suit le réglage de votre appareil." },
    { id: 'clair', nom: 'Clair', aide: 'Fond blanc, texte noir.' },
    { id: 'sombre', nom: 'Sombre', aide: 'Fond noir, plus doux le soir.' },
  ]
  return (
    <>
      <h1>Mode d'affichage</h1>
      <p className="intro">Choisissez l'apparence de Pinterest sur cet appareil.</p>
      <div className="choix-theme" role="radiogroup" aria-label="Thème">
        {options.map((o) => (
          <label key={o.id} className={`option-theme${theme === o.id ? ' active' : ''}`}>
            <input type="radio" name="theme" checked={theme === o.id} onChange={() => choisirTheme(o.id)} />
            <span className={`apercu-theme ${o.id}`} aria-hidden="true" />
            <strong>{o.nom}</strong>
            <small>{o.aide}</small>
          </label>
        ))}
      </div>
    </>
  )
}

function Bascules({ titre, intro, lignes }: { titre: string; intro: string; lignes: string[] }) {
  const [etats, setEtats] = useState(() => lignes.map((_, i) => i === 0))
  return (
    <>
      <h1>{titre}</h1>
      <p className="intro">{intro}</p>
      <div className="formulaire">
        {lignes.map((l, i) => (
          <label className="ligne-reglage" key={l}>
            <strong>{l}</strong>
            <span className={`bascule${etats[i] ? ' active' : ''}`}>
              <input type="checkbox" checked={etats[i]} onChange={() => setEtats((e) => e.map((v, k) => (k === i ? !v : v)))} />
            </span>
          </label>
        ))}
      </div>
    </>
  )
}
