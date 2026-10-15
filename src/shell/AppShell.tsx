import { useCallback, useEffect, useState, type ReactNode } from 'react'
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom'
import { useSession } from '../state/Session'
import { Avatar, Icone, Marque, type NomIcone } from '../ui/Icone'
import { useHorsDe } from '../ui/outils'
import { Recherche } from './Recherche'
import { Toasts } from './Toasts'

/*
 * La charpente Pinterest connectée (AppShell), relevée au pixel près sur la vidéo
 * réelle de l'utilisateur (15 octobre 2026) :
 *   - Logo Pinterest calligraphique officiel
 *   - Nom de section (« Page d'accueil » ou « Pinterest ») suivi de l'icône ≡
 *   - Recherche rétractable avec loupe et caméra/objectif
 *   - Pastille compte « Jaye ahf / Profil de Jaye ahf » avec avatar réel
 *   - 5 boutons ronds d'actions : Loupe, Cloche, Bulle, Mégaphone, Profil, Chevron
 *   - Volets volants exacts : « Notifications » et « Boîte de réception »
 *   - Bouton d'aide « ? » flottant en bas à droite
 */

type Panneau = null | 'notifications' | 'messages' | 'activite'

function nomDeSection(chemin: string) {
  if (chemin === '/') return "Page d'accueil"
  if (chemin.startsWith('/pin-creation-tool')) return 'Créer'
  return 'Pinterest'
}

export function AppShell({ children }: { children: ReactNode }) {
  const [panneau, setPanneau] = useState<Panneau>(null)
  const { pathname, search } = useLocation()
  const [recherche, setRecherche] = useState(pathname.startsWith('/search'))
  const basculer = (p: Panneau) => setPanneau((x) => (x === p ? null : p))
  const fermer = useCallback(() => setPanneau(null), [])

  useEffect(() => {
    setPanneau(null)
    setRecherche(pathname.startsWith('/search'))
  }, [pathname, search])

  return (
    <div className="app">
      <header className="entete-app">
        <div className="entete-gauche">
          <Link to="/" className="entete-logo" aria-label="Page d'accueil">
            <Marque taille={24} />
          </Link>
          <MenuNavigation section={nomDeSection(pathname)} />
        </div>

        {recherche ? (
          <div className="entete-recherche">
            <Recherche autoFocus={!pathname.startsWith('/search')} />
            <button type="button" className="btn-rond nu" aria-label="Fermer la recherche" onClick={() => setRecherche(false)}>
              <Icone nom="croix" taille={20} />
            </button>
          </div>
        ) : (
          <span className="entete-vide" />
        )}

        <div className="entete-droite">
          <PastilleCompte />
          {!recherche && <BoutonEntete icone="loupe" nom="Rechercher" onClick={() => setRecherche(true)} />}
          <BoutonEntete icone="cloche" nom="Notifications" actif={panneau === 'notifications'} pastille={3} onClick={() => basculer('notifications')} />
          <BoutonEntete icone="discussion" nom="Messages" actif={panneau === 'messages'} pastille={1} onClick={() => basculer('messages')} />
          <BoutonEntete icone="megaphone" nom="Gérer les commentaires et l'activité sociale" actif={panneau === 'activite'} onClick={() => basculer('activite')} />
          <MenuCompte />
        </div>
      </header>

      {panneau === 'notifications' && <PanneauNotifications fermer={fermer} />}
      {panneau === 'messages' && <PanneauBoiteReception fermer={fermer} />}
      {panneau === 'activite' && <PanneauActivite fermer={fermer} />}

      <main className="app-contenu">{children}</main>

      <nav className="barre-mobile" aria-label="Navigation principale">
        <LienMobile to="/" icone="accueil" nom="Accueil" actif={pathname === '/' && !panneau} />
        <LienMobile to="/today" icone="explorer" nom="Explorer" actif={pathname.startsWith('/today') && !panneau} />
        <LienMobile to="/pin-creation-tool" icone="plus" nom="Créer" actif={pathname.startsWith('/pin-creation-tool') && !panneau} />
        <BoutonEntete icone="cloche" nom="Notifications" actif={panneau === 'notifications'} pastille={3} onClick={() => basculer('notifications')} />
        <BoutonEntete icone="discussion" nom="Messages" actif={panneau === 'messages'} pastille={1} onClick={() => basculer('messages')} />
      </nav>

      <Aide />
      <Toasts />
    </div>
  )
}

function BoutonEntete({ icone, nom, actif = false, pastille, onClick }: { icone: NomIcone; nom: string; actif?: boolean; pastille?: number; onClick: () => void }) {
  return (
    <button type="button" data-garde className={`entete-btn${actif ? ' actif' : ''}`} aria-label={nom} aria-pressed={actif} onClick={onClick}>
      <Icone nom={icone} />
      {pastille ? <span className="pastille-rouge">{pastille}</span> : null}
      <span className="infobulle">{nom}</span>
    </button>
  )
}

function LienMobile({ to, icone, nom, actif }: { to: string; icone: NomIcone; nom: string; actif: boolean }) {
  return (
    <NavLink to={to} className={`entete-btn${actif ? ' actif' : ''}`} aria-label={nom} aria-current={actif ? 'page' : undefined}>
      <Icone nom={icone} />
    </NavLink>
  )
}

function MenuNavigation({ section }: { section: string }) {
  const { utilisateur } = useSession()
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  const lignes: { to: string; icone: NomIcone; nom: string }[] = [
    { to: '/', icone: 'accueil', nom: "Page d'accueil" },
    { to: '/today', icone: 'explorer', nom: 'Explorer' },
    { to: '/pin-creation-tool', icone: 'plus', nom: 'Créer une Épingle' },
    { to: `/${utilisateur?.pseudo ?? 'ahiffent'}/_saved`, icone: 'tableaux', nom: 'Vos tableaux' },
    { to: '/settings', icone: 'roue', nom: 'Paramètres' },
  ]
  return (
    <div className="menu-navigation" ref={ref}>
      <button type="button" className="entete-section" aria-expanded={ouvert} aria-haspopup="menu" onClick={() => setOuvert((o) => !o)}>
        <span>{section}</span>
        <Icone nom="menu" taille={18} />
      </button>
      {ouvert && (
        <div className="menu menu-nav" role="menu">
          {lignes.map((l) => (
            <NavLink key={l.to} role="menuitem" to={l.to} end onClick={fermer} className={({ isActive }) => (isActive ? 'actif' : '')}>
              <span className="menu-nav-icone">
                <Icone nom={l.icone} taille={20} />
              </span>
              {l.nom}
            </NavLink>
          ))}
        </div>
      )}
    </div>
  )
}

function PastilleCompte() {
  const { utilisateur } = useSession()
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  if (!utilisateur) return null
  return (
    <div className="pastille-compte" ref={ref}>
      <button type="button" className="pastille-compte-btn" aria-expanded={ouvert} aria-label="Changer de compte" onClick={() => setOuvert((o) => !o)}>
        <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={32} image={utilisateur.image} />
        <span className="pastille-compte-textes">
          <span className="pastille-compte-nom">{utilisateur.nom}</span>
          <span className="pastille-compte-role">Profil de {utilisateur.nom}</span>
        </span>
        <Icone nom="chevron" taille={12} />
      </button>
      {ouvert && (
        <div className="menu menu-compte" role="menu">
          <p className="menu-sous-titre">Comptes</p>
          <Link to={`/${utilisateur.pseudo}`} className="compte-carte" onClick={fermer}>
            <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={48} image={utilisateur.image} />
            <span>
              <strong>{utilisateur.nom}</strong>
              <small>Professionnel</small>
            </span>
            <Icone nom="coche" taille={20} />
          </Link>
        </div>
      )}
    </div>
  )
}

function MenuCompte() {
  const { utilisateur, deconnecter } = useSession()
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  const navigate = useNavigate()
  if (!utilisateur) return null
  return (
    <div className="compte" ref={ref}>
      <Link to={`/${utilisateur.pseudo}`} className="entete-btn" aria-label="Votre profil">
        <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={24} image={utilisateur.image} />
      </Link>
      <button type="button" className="compte-fleche" aria-label="Comptes et autres options" aria-expanded={ouvert} onClick={() => setOuvert((o) => !o)}>
        <Icone nom="chevron" taille={16} />
      </button>
      {ouvert && (
        <div className="menu menu-compte" role="menu">
          <p className="menu-sous-titre">Actuellement connecté</p>
          <Link to={`/${utilisateur.pseudo}`} className="compte-carte" onClick={fermer}>
            <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={56} image={utilisateur.image} />
            <span>
              <strong>{utilisateur.nom}</strong>
              <small>Professionnel</small>
              <small>{utilisateur.email}</small>
            </span>
            <Icone nom="coche" taille={20} />
          </Link>
          <p className="menu-sous-titre">Vos comptes</p>
          <Link role="menuitem" to="/settings" onClick={fermer}>
            Paramètres
          </Link>
          <Link role="menuitem" to="/settings/affichage" onClick={fermer}>
            Mode d'affichage
          </Link>
          <button
            type="button"
            role="menuitem"
            onClick={() => {
              deconnecter()
              fermer()
              navigate('/')
            }}
          >
            Se déconnecter
          </button>
        </div>
      )}
    </div>
  )
}

function Aide() {
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  return (
    <div className="aide" ref={ref}>
      {ouvert && (
        <div className="menu menu-aide" role="menu">
          <Link role="menuitem" to="/info/a-propos" onClick={fermer}>
            Centre d'aide
          </Link>
          <Link role="menuitem" to="/info/actualites" onClick={fermer}>
            Nouveautés
          </Link>
          <Link role="menuitem" to="/info/confidentialite" onClick={fermer}>
            Confidentialité
          </Link>
        </div>
      )}
      <button type="button" className="aide-btn" aria-label="Aide" aria-expanded={ouvert} onClick={() => setOuvert((o) => !o)}>
        <Icone nom="aide" taille={26} />
      </button>
    </div>
  )
}

/*
 * Notifications réelles (cf. frame_010.jpg) :
 *   - Titre « Notifications »
 *   - Recommandations et explorations personnalisées avec vignettes
 */
const NOTIFICATIONS_REELLES = [
  {
    titre: 'Site Motion Design.',
    description: "Vous n'avez pas encore trouvé ce qu'il vous faut ? Explorez les idées associées à Motion Design And 3d Website.",
    quand: '2 mois',
    image: '/pins/36.jpg',
  },
  {
    titre: 'Recherche suggérée',
    description: "Vous n'avez pas encore trouvé ce qu'il vous faut ? Explorez les idées associées à Image Developpement Web.",
    quand: '5 mois',
    icone: 'loupe' as NomIcone,
  },
  {
    titre: 'Naruto guide',
    description: 'De nouvelles Épingles associées à Naruto guide ont été publiées.',
    quand: '7 mois',
    image: '/pins/56.jpg',
  },
  {
    titre: 'Vocabulaire guide',
    description: 'Une sélection pour enrichir vos tableaux.',
    quand: '7 mois',
    image: '/pins/24.jpg',
  },
  {
    titre: 'Vous méritez de tout avoir',
    description: 'Inspiration citations et mindset.',
    quand: '7 mois',
    image: '/pins/22.jpg',
  },
  {
    titre: 'One Piece guide',
    description: 'Idées recommandées pour vous.',
    quand: '7 mois',
    image: '/pins/82.jpg',
  },
]

function PanneauNotifications({ fermer }: { fermer: () => void }) {
  const ref = useHorsDe<HTMLElement>(true, fermer)
  return (
    <aside className="panneau-lateral panneau-notifications-reel" ref={ref} aria-label="Notifications">
      <div className="panneau-entete-simple">
        <h2>Notifications</h2>
      </div>
      <ul className="liste-notifications-reelles">
        {NOTIFICATIONS_REELLES.map((n, i) => (
          <li key={i} className="item-notif-reel">
            <div className="notif-visuel">
              {n.image ? (
                <img src={n.image} alt="" className="notif-img" />
              ) : (
                <span className="notif-icone-rond">
                  <Icone nom={n.icone ?? 'loupe'} taille={18} />
                </span>
              )}
            </div>
            <div className="notif-corps">
              <strong className="notif-titre">{n.titre}</strong>
              <p className="notif-desc">{n.description}</p>
              <span className="notif-temps">{n.quand}</span>
            </div>
            <button type="button" className="btn-rond nu notif-options" aria-label="Options">
              <Icone nom="points" taille={16} />
            </button>
          </li>
        ))}
      </ul>
    </aside>
  )
}

/*
 * Volet « Boîte de réception » / Messages (cf. frame_015.jpg) :
 *   - En-tête « ✕ Boîte de réception »
 *   - Bouton rouge « Nouveau message »
 *   - Ligne « Invitez vos amis »
 *   - Illustration bouteille et message : « Lancer une conversation »
 */
function PanneauBoiteReception({ fermer }: { fermer: () => void }) {
  const ref = useHorsDe<HTMLElement>(true, fermer)
  const { conversations, envoyer } = useSession()
  const [ouverte, setOuverte] = useState<string | null>(null)
  const [texte, setTexte] = useState('')
  const conv = conversations.find((c) => c.id === ouverte)

  if (conv) {
    return (
      <aside className="panneau-lateral panneau-chat" ref={ref} aria-label={`Conversation avec ${conv.avec}`}>
        <div className="chat-entete">
          <button type="button" className="btn-rond nu" aria-label="Retour aux messages" onClick={() => setOuverte(null)}>
            <Icone nom="gauche" />
          </button>
          <Avatar nom={conv.avec} couleur={conv.couleur} taille={32} />
          <strong>{conv.avec}</strong>
        </div>
        <div className="chat-fil">
          {conv.messages.map((m, i) => (
            <p key={i} className={`bulle-msg ${m.de}`}>
              {m.texte}
            </p>
          ))}
        </div>
        <form
          className="chat-saisie"
          onSubmit={(e) => {
            e.preventDefault()
            if (!texte.trim()) return
            envoyer(conv.id, texte.trim())
            setTexte('')
          }}
        >
          <input value={texte} onChange={(e) => setTexte(e.target.value)} placeholder="Envoyer un message" aria-label="Votre message" autoFocus />
          <button type="submit" className="btn-rond rouge" aria-label="Envoyer" disabled={!texte.trim()}>
            <Icone nom="envoyer" taille={20} />
          </button>
        </form>
      </aside>
    )
  }

  return (
    <aside className="panneau-lateral panneau-inbox-reel" ref={ref} aria-label="Boîte de réception">
      <div className="inbox-entete">
        <button type="button" className="btn-rond nu inbox-fermer" onClick={fermer} aria-label="Fermer">
          <Icone nom="croix" taille={18} />
        </button>
        <h2>Boîte de réception</h2>
      </div>

      <div className="inbox-action-nouveau">
        <button type="button" className="btn-nouveau-message" onClick={() => setOuverte(conversations[0]?.id ?? 'camille')}>
          <span className="rond-crayon-rouge">
            <Icone nom="crayon" taille={18} />
          </span>
          <strong>Nouveau message</strong>
        </button>
      </div>

      <div className="inbox-inviter">
        <div className="inviter-icone">
          <Icone nom="personnes" taille={20} />
        </div>
        <div className="inviter-textes">
          <strong>Invitez vos amis</strong>
          <small>Connectez-vous pour entamer une discussion</small>
        </div>
      </div>

      <div className="inbox-vide-illustration">
        <div className="illustration-bouteille">
          <svg width="120" height="120" viewBox="0 0 100 100" fill="none">
            <circle cx="50" cy="50" r="45" fill="#e8f3f8" />
            <path d="M42 28h16v6h-16z" fill="#e60023" rx="2" />
            <rect x="44" y="34" width="12" height="6" fill="#fff" opacity="0.8" />
            <path d="M38 42c0-2 2-4 4-4h16c2 0 4 2 4 4l-2 36c0 3-3 5-6 5H46c-3 0-6-2-6-5l-2-36z" fill="#4a90e2" opacity="0.85" />
            <rect x="43" y="48" width="14" height="20" rx="3" fill="#fff" />
            <path d="M46 54h8M46 58h6M46 62h8" stroke="#e60023" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
        </div>
        <h3>Lancer une conversation</h3>
        <p>
          Utilisez la messagerie pour discuter avec vos amis, partager des Épingles et des tableaux, et trouver des idées ensemble. Vos conversations apparaîtront ici.
        </p>
      </div>
    </aside>
  )
}

const ACTIVITE = [
  { qui: 'Camille', couleur: '#e07a5f', texte: 'a commenté votre Épingle « Santorin, maisons blanches et moulins »', quand: '2 h', pin: '49' },
  { qui: 'Yanis', couleur: '#3d405b', texte: 'a réagi à votre Épingle « Setup sombre et carnet en cuir »', quand: '1 j', pin: '60' },
  { qui: 'Inès', couleur: '#81b29a', texte: 'a enregistré votre Épingle « Café au lait sur fond rouge »', quand: '3 j', pin: '63' },
]

function PanneauActivite({ fermer }: { fermer: () => void }) {
  const ref = useHorsDe<HTMLElement>(true, fermer)
  return (
    <aside className="panneau-lateral" ref={ref} aria-label="Activité sociale">
      <h2>Commentaires et activité</h2>
      <ul className="liste-maj">
        {ACTIVITE.map((a) => (
          <li key={a.texte}>
            <Link to={`/pin/${a.pin}`} onClick={fermer}>
              <Avatar nom={a.qui} couleur={a.couleur} taille={48} />
              <span className="maj-texte">
                <span>
                  <strong>{a.qui}</strong> {a.texte}
                </span>
                <small>{a.quand}</small>
              </span>
              <img className="maj-vignette" src={`/pins/${a.pin}.jpg`} alt="" />
            </Link>
          </li>
        ))}
      </ul>
    </aside>
  )
}
