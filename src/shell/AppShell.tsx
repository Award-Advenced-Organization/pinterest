import { useCallback, useEffect, useState, type ReactNode } from 'react'
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom'
import { PINS } from '../data/pins'
import { useSession } from '../state/Session'
import { Avatar, Icone, Marque, type NomIcone } from '../ui/Icone'
import { useHorsDe } from '../ui/outils'
import { Recherche } from './Recherche'
import { Toasts } from './Toasts'

/*
 * La charpente une fois connecté, relevée sur la sauvegarde du fil réel
 * (reproduct.html, compte professionnel, 15 octobre 2026) :
 *
 *   à gauche   le logo, le nom de la section et le bouton ≡ du menu
 *   à droite   la pastille du compte (bord 1 px #c8c8c1, arrondi 16, 149 × 50),
 *              puis cinq boutons de 48 px espacés de 50 : recherche,
 *              notifications, messages, activité, profil, et la flèche des comptes
 *   en bas     le bouton d'aide flottant
 *
 * La recherche n'est qu'une icône : elle s'ouvre dans l'en-tête quand on la
 * demande. Il n'y a pas de barre latérale. Sous 720 px, les icônes passent
 * dans une barre en bas de l'écran, comme sur le site mobile.
 */

type Panneau = null | 'notifications' | 'messages' | 'activite'

function nomDeSection(chemin: string, pseudo?: string) {
  if (chemin === '/' || chemin.startsWith('/pin/')) return "Page d'accueil"
  if (chemin.startsWith('/today')) return 'Explorer'
  if (chemin.startsWith('/search')) return 'Recherche'
  if (chemin.startsWith('/pin-creation-tool')) return 'Créer'
  if (chemin.startsWith('/settings')) return 'Paramètres'
  if (pseudo && chemin.startsWith(`/${pseudo}`)) return 'Profil'
  return "Page d'accueil"
}

export function AppShell({ children }: { children: ReactNode }) {
  const { utilisateur } = useSession()
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
          <MenuNavigation section={nomDeSection(pathname, utilisateur?.pseudo)} />
        </div>

        {recherche ? (
          <div className="entete-recherche">
            <Recherche autoFocus={!pathname.startsWith('/search')} />
            <button type="button" className="btn-rond nu" aria-label="Fermer la recherche" onClick={() => setRecherche(false)}>
              <Icone nom="croix" taille={20} epaisseur={2.4} />
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

      {panneau === 'notifications' && <PanneauMisesAJour fermer={fermer} />}
      {panneau === 'messages' && <PanneauMessages fermer={fermer} />}
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
      <Icone nom={icone} plein={actif && icone !== 'discussion' && icone !== 'megaphone'} />
      {pastille ? <span className="pastille-rouge">{pastille}</span> : null}
      <span className="infobulle">{nom}</span>
    </button>
  )
}

function LienMobile({ to, icone, nom, actif }: { to: string; icone: NomIcone; nom: string; actif: boolean }) {
  return (
    <NavLink to={to} className={`entete-btn${actif ? ' actif' : ''}`} aria-label={nom} aria-current={actif ? 'page' : undefined}>
      <Icone nom={icone} plein={actif} />
    </NavLink>
  )
}

/*
 * Le menu ≡. La sauvegarde ne contient pas son contenu (le vrai site le
 * construit au clic) : les rubriques ci-dessous sont celles de ce projet,
 * rangées dans l'ordre de la navigation, en attendant une capture du menu
 * ouvert pour le caler.
 */
function MenuNavigation({ section }: { section: string }) {
  const { utilisateur } = useSession()
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  const lignes: { to: string; icone: NomIcone; nom: string }[] = [
    { to: '/', icone: 'accueil', nom: "Page d'accueil" },
    { to: '/today', icone: 'explorer', nom: 'Explorer' },
    { to: '/pin-creation-tool', icone: 'plus', nom: 'Créer une Épingle' },
    { to: `/${utilisateur?.pseudo ?? ''}/_saved`, icone: 'tableaux', nom: 'Vos tableaux' },
    { to: '/settings', icone: 'roue', nom: 'Paramètres' },
  ]
  return (
    <div className="menu-navigation" ref={ref}>
      <button type="button" className="entete-section" aria-expanded={ouvert} aria-haspopup="menu" onClick={() => setOuvert((o) => !o)}>
        <span>{section}</span>
        <Icone nom="menu" taille={16} epaisseur={2} />
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
        <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={32} />
        <span>{utilisateur.nom.split(' ')[0]}</span>
        <Icone nom="chevron" taille={12} epaisseur={3} />
      </button>
      {ouvert && (
        <div className="menu menu-compte" role="menu">
          <p className="menu-sous-titre">Comptes</p>
          <Link to={`/${utilisateur.pseudo}`} className="compte-carte" onClick={fermer}>
            <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={48} />
            <span>
              <strong>{utilisateur.nom}</strong>
              <small>Professionnel</small>
            </span>
            <Icone nom="coche" taille={20} epaisseur={2.6} />
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
        <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={24} />
      </Link>
      <button type="button" className="compte-fleche" aria-label="Comptes et autres options" aria-expanded={ouvert} onClick={() => setOuvert((o) => !o)}>
        <Icone nom="chevron" taille={16} epaisseur={2.6} />
      </button>
      {ouvert && (
        <div className="menu menu-compte" role="menu">
          <p className="menu-sous-titre">Actuellement connecté</p>
          <Link to={`/${utilisateur.pseudo}`} className="compte-carte" onClick={fermer}>
            <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={56} />
            <span>
              <strong>{utilisateur.nom}</strong>
              <small>Professionnel</small>
              <small>{utilisateur.email}</small>
            </span>
            <Icone nom="coche" taille={20} epaisseur={2.6} />
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

/* Le bouton d'aide flottant, en bas à droite, relevé sur la sauvegarde. */
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
        <Icone nom="aide" taille={26} epaisseur={2.2} />
      </button>
    </div>
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

const MISES_A_JOUR = [
  { texte: 'Des idées qui pourraient vous plaire pour votre tableau Voyages à faire', quand: '2 h', pins: ['128', '108', '54'] },
  { texte: 'Atelier Brume a publié de nouvelles Épingles', quand: '6 h', pins: ['11', '19', '33'] },
  { texte: 'Inspirée de vos recherches : bureau minimaliste', quand: '1 j', pins: ['60', '48', '20'] },
  { texte: 'Votre tableau Recettes a de nouvelles suggestions', quand: '3 j', pins: ['102', '75', '113'] },
  { texte: 'Photographier la brume : sélection de la semaine', quand: '5 j', pins: ['95', '70', '121'] },
]

function PanneauMisesAJour({ fermer }: { fermer: () => void }) {
  const ref = useHorsDe<HTMLElement>(true, fermer)
  return (
    <aside className="panneau-lateral" ref={ref} aria-label="Mises à jour">
      <h2>Mises à jour</h2>
      <p className="panneau-section">Nouveau</p>
      <ul className="liste-maj">
        {MISES_A_JOUR.map((m, i) => (
          <li key={m.texte}>
            <Link to={`/pin/${m.pins[0]}`} onClick={fermer} className={i < 3 ? 'non-lu' : undefined}>
              <span className="maj-collage">
                {m.pins.map((id) => (
                  <img key={id} src={`/pins/${id}.jpg`} alt="" />
                ))}
              </span>
              <span className="maj-texte">
                {m.texte}
                <small>{m.quand}</small>
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </aside>
  )
}

function PanneauMessages({ fermer }: { fermer: () => void }) {
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
            <Icone nom="envoyer" taille={20} epaisseur={2.6} />
          </button>
        </form>
      </aside>
    )
  }

  return (
    <aside className="panneau-lateral" ref={ref} aria-label="Messages">
      <h2>Messages</h2>
      <button type="button" className="ligne-action" onClick={() => setOuverte(conversations[0]?.id ?? null)}>
        <span className="rond-rouge">
          <Icone nom="crayon" taille={20} />
        </span>
        <strong>Nouveau message</strong>
      </button>
      <p className="panneau-section">Messages</p>
      {conversations.map((c) => (
        <button type="button" key={c.id} className="ligne-conv" onClick={() => setOuverte(c.id)}>
          <Avatar nom={c.avec} couleur={c.couleur} taille={48} />
          <span>
            <strong>{c.avec}</strong>
            <small>{c.messages[c.messages.length - 1]?.texte}</small>
          </span>
        </button>
      ))}
      <div className="ligne-action inviter">
        <span className="rond-gris">
          <Icone nom="personnes" taille={20} />
        </span>
        <span>
          <strong>Invitez vos amis</strong>
          <small>Partagez vos idées avec eux.</small>
        </span>
        <img src={PINS[3].image} alt="" />
      </div>
    </aside>
  )
}
