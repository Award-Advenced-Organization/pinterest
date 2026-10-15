import { useMemo, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { CREATEURS, PINS } from '../data/pins'
import { useSession, type Tableau } from '../state/Session'
import { Avatar, Icone } from '../ui/Icone'
import { CreerTableau } from '../ui/Enregistrer'
import { Masonry } from '../ui/Masonry'
import { PinCard } from '../ui/PinCard'
import { abrege } from '../ui/outils'
import { Introuvable } from './Introuvable'

/*
 * Le profil utilisateur officiel Pinterest, relevé à l'identique sur la vidéo réelle
 * (cf. frame_035.jpg et frame_045.jpg) :
 *   - En haut à droite : boutons carrés arrondis [↑] (partager) et [+] (créer)
 *   - En-tête aligné à gauche avec grand avatar circulaire (photo de développement web)
 *   - Titre « Jaye ahf », pseudo « ahiffent », « 1 abonné · 2 abonnements »
 *   - « À propos de ce compte... plus », lien 🌐 ahiffonjephte.me
 *   - Bouton gris arrondi « Modifier le profil »
 *   - Onglets centrés « Créées » / « Enregistrées » avec soulignement noir
 *   - Barre d'outils avec icône filtre ⊶ à gauche et bouton rouge flottant « Créer » à droite
 *   - Section « Gardez une trace de ce qui vous inspire » avec clusters de tableaux
 *   - Épingles créées incluant celle de la vidéo : « Suis moi et ensemble apprenons le développement web »
 */

const PIN_CREE_DEFAUT = {
  id: 'moi-dev-web',
  image: '/avatar_jaye.jpg',
  w: 280,
  h: 280,
  couleur: '#1a1a1a',
  titre: 'Suis moi et ensemble apprenons le développement web',
  description: 'Tutoriels, astuces et ressources pour apprendre le dev web moderne.',
  categorie: 'tech' as const,
  createur: {
    id: 'moi',
    nom: 'Jaye ahf',
    pseudo: 'ahiffent',
    couleur: '#e60023',
    abonnes: 1,
    site: 'ahiffonjephte.me',
  },
  lien: 'ahiffonjephte.me',
  photographe: 'Jaye ahf',
  titreVisible: true,
}

export function Profil({ onglet: ongletDepart }: { onglet?: 'crees' | 'enregistres' }) {
  const { pseudo = 'ahiffent' } = useParams()
  const { utilisateur, tableaux, crees, abonnements, suivre, annoncer, creerTableau } = useSession()
  const navigate = useNavigate()
  const moi = !utilisateur || utilisateur.pseudo === pseudo || pseudo === 'ahiffent'
  const createur = CREATEURS.find((c) => c.pseudo === pseudo)
  const [onglet, setOnglet] = useState<'crees' | 'enregistres'>(ongletDepart ?? 'enregistres')
  const [creation, setCreation] = useState(false)
  const [tri] = useState<'recent' | 'alpha'>('recent')

  const pinsCreateur = useMemo(() => (createur ? PINS.filter((p) => p.createur.id === createur.id) : []), [createur])
  const tableauxTries = useMemo(
    () => [...tableaux].sort((a, b) => (tri === 'alpha' ? a.nom.localeCompare(b.nom, 'fr') : b.cree - a.cree)),
    [tableaux, tri],
  )

  if (!moi && !createur) return <Introuvable />

  const nom = moi ? (utilisateur?.nom ?? 'Jaye ahf') : createur!.nom
  const couleur = moi ? (utilisateur?.couleur ?? '#e60023') : createur!.couleur
  const avatarImg = moi ? (utilisateur?.image ?? '/avatar_jaye.jpg') : undefined
  const abonne = createur ? abonnements.includes(createur.id) : false
  const tousEnregistres = [...new Set(tableaux.flatMap((t) => t.pins))]

  const pinsCreesComplets = useMemo(() => {
    return [PIN_CREE_DEFAUT, ...crees]
  }, [crees])

  const partager = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href)
      annoncer({ texte: 'Lien du profil copié' })
    } catch {
      annoncer({ texte: 'Copie impossible dans ce navigateur' })
    }
  }

  return (
    <div className="profil profil-reel">
      {/* Boutons d'actions en haut à droite du profil (cf. frame_035.jpg) */}
      <div className="profil-actions-flottantes">
        <button type="button" className="btn-carre-rond" aria-label="Partager le profil" onClick={partager}>
          <Icone nom="partager" taille={20} />
        </button>
        <button type="button" className="btn-carre-rond" aria-label="Créer" onClick={() => navigate('/pin-creation-tool')}>
          <Icone nom="plus" taille={20} />
        </button>
      </div>

      {/* En-tête profil aligné à gauche (cf. frame_035.jpg) */}
      <header className="profil-entete-reel">
        <div className="profil-avatar-gauche">
          <Avatar nom={nom} couleur={couleur} taille={120} image={avatarImg} />
        </div>
        <div className="profil-identite">
          <h1 className="profil-nom-grand">{nom}</h1>
          <p className="profil-pseudo-discret">{pseudo}</p>
          <p className="profil-chiffres-reel">
            {moi ? '1 abonné · 2 abonnements' : `${abrege(createur!.abonnes + (abonne ? 1 : 0))} abonnés · 12 abonnements`}
          </p>
          <p className="profil-bio-court">À propos de ce compte... <button type="button" className="lien-plus">plus</button></p>
          <p className="profil-site-globe">
            <span className="globe-icone">🌐</span>
            <a href="http://ahiffonjephte.me" target="_blank" rel="noopener noreferrer">
              ahiffonjephte.me
            </a>
          </p>
          <div className="profil-cta-ligne">
            {moi ? (
              <Link to="/settings" className="btn btn-modifier-profil">
                Modifier le profil
              </Link>
            ) : (
              <button
                type="button"
                className={`btn ${abonne ? 'btn-noir' : 'btn-rouge'}`}
                onClick={() => (utilisateur ? suivre(createur!.id) : navigate('/signup'))}
              >
                {abonne ? 'Abonné(e)' : "S'abonner"}
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Onglets centrés Créées / Enregistrées avec trait noir (cf. frame_035.jpg) */}
      <div className="profil-onglets-centre" role="tablist">
        <button
          type="button"
          role="tab"
          aria-selected={onglet === 'crees'}
          className={`onglet-profil-btn ${onglet === 'crees' ? 'actif' : ''}`}
          onClick={() => setOnglet('crees')}
        >
          Créées
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={onglet === 'enregistres'}
          className={`onglet-profil-btn ${onglet === 'enregistres' ? 'actif' : ''}`}
          onClick={() => setOnglet('enregistres')}
        >
          Enregistrées
        </button>
      </div>

      {/* Barre d'outils avec filtre à gauche (cf. frame_035.jpg) */}
      <div className="profil-barre-outils">
        <button type="button" className="btn-rond nu btn-filtre-profil" aria-label="Filtres">
          <Icone nom="filtre" taille={20} />
        </button>
      </div>

      {/* Contenu Onglet Créées */}
      {onglet === 'crees' && (
        <div className="profil-contenu-crees">
          {moi ? (
            <Masonry elements={pinsCreesComplets.map((p) => ({ cle: p.id, pin: p }))} rendre={(e) => <PinCard pin={e.pin} />} />
          ) : (
            <Masonry elements={pinsCreateur.map((p) => ({ cle: p.id, pin: p }))} rendre={(e) => <PinCard pin={e.pin} />} />
          )}
        </div>
      )}

      {/* Contenu Onglet Enregistrées (cf. frame_045.jpg) */}
      {onglet === 'enregistres' && (
        <div className="profil-contenu-enregistres">
          <div className="enregistres-inspiration">
            <h2>Gardez une trace de ce qui vous inspire</h2>
            <p>
              Les tableaux vous permettent d'organiser les Épingles que vous enregistrez en collections. Démarrez à partir d'un cluster ci-dessous ou créez le vôtre.
            </p>
          </div>

          <div className="grille-tableaux-clusters">
            <CarteTableau lien={`/${pseudo}/tout`} nom="Toutes les Épingles" pins={tousEnregistres} />
            {tableauxTries.map((t) => (
              <CarteTableau key={t.id} lien={`/${pseudo}/${t.id}`} nom={t.nom} pins={t.pins} tableau={t} />
            ))}
          </div>
        </div>
      )}

      {/* Bouton rouge flottant « Créer » en bas à droite (cf. frame_035.jpg) */}
      <Link to="/pin-creation-tool" className="btn-creer-flottant" aria-label="Créer une Épingle">
        Créer
      </Link>

      {creation && (
        <CreerTableau
          fermer={() => setCreation(false)}
          creer={(n, s) => {
            const t = creerTableau(n, s)
            setCreation(false)
            navigate(`/${pseudo}/${t.id}`)
          }}
        />
      )}
    </div>
  )
}

export function CarteTableau({ lien, nom, pins, tableau }: { lien: string; nom: string; pins: string[]; tableau?: Tableau }) {
  const images = [0, 1, 2].map((k) => pins[k])
  return (
    <Link to={lien} className="carte-tableau">
      <span className="carte-tableau-images">
        {images.map((id, k) => (id ? <img key={k} src={`/pins/${id}.jpg`} alt="" /> : <span key={k} className="case-vide" />))}
        {tableau?.secret && (
          <span className="badge-secret" aria-label="Tableau secret">
            <Icone nom="cadenas" taille={14} />
          </span>
        )}
      </span>
      <strong>{nom}</strong>
      <small>
        {pins.length} Épingle{pins.length > 1 ? 's' : ''}
        {tableau ? ` · ${tableau.cree > 1000 ? "à l'instant" : `${tableau.cree + 1} sem.`}` : ''}
      </small>
    </Link>
  )
}
