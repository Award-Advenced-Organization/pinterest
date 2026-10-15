import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { PINS, type Pin } from '../data/pins'

/*
 * La session, tout en local. La connexion est simulée : on garde un nom et une
 * adresse pour afficher le profil, jamais le mot de passe, et rien ne part sur
 * le réseau. Ce qui est rangé dans le navigateur passe par lire/ecrire, qui
 * tolèrent un stockage absent ou plein.
 */

export type Utilisateur = { nom: string; pseudo: string; email: string; couleur: string; apropos: string; site: string }
export type Tableau = { id: string; nom: string; pins: string[]; secret: boolean; cree: number }
export type Theme = 'systeme' | 'clair' | 'sombre'
export type Message = { de: 'moi' | 'eux'; texte: string }
export type Conversation = { id: string; avec: string; couleur: string; messages: Message[] }

type Toast = { id: number; texte: string; image?: string; lien?: string }

type Session = {
  utilisateur: Utilisateur | null
  connecter: (email: string) => void
  deconnecter: () => void
  modifierProfil: (champs: Partial<Utilisateur>) => void
  tableaux: Tableau[]
  dernierTableau: Tableau | null
  creerTableau: (nom: string, secret: boolean) => Tableau
  enregistrer: (pinId: string, tableauId?: string) => void
  retirer: (pinId: string) => void
  estEnregistre: (pinId: string) => Tableau | undefined
  crees: Pin[]
  publier: (pin: Pin) => void
  tousLesPins: Pin[]
  abonnements: string[]
  suivre: (createurId: string) => void
  jaime: string[]
  aimer: (pinId: string) => void
  masques: string[]
  masquer: (pinId: string) => void
  demasquer: (pinId: string) => void
  recherches: string[]
  noterRecherche: (q: string) => void
  effacerRecherches: () => void
  conversations: Conversation[]
  envoyer: (conversationId: string, texte: string) => void
  theme: Theme
  choisirTheme: (t: Theme) => void
  toasts: Toast[]
  annoncer: (t: Omit<Toast, 'id'>) => void
}

const Contexte = createContext<Session | null>(null)

function lire<T>(cle: string, defaut: T): T {
  try {
    const brut = localStorage.getItem(cle)
    return brut ? (JSON.parse(brut) as T) : defaut
  } catch {
    return defaut
  }
}

function ecrire(cle: string, valeur: unknown) {
  try {
    if (valeur === null) localStorage.removeItem(cle)
    else localStorage.setItem(cle, JSON.stringify(valeur))
  } catch {
    /* stockage plein ou bloqué : la session vit en mémoire */
  }
}

const TABLEAUX_DE_DEPART: Tableau[] = [
  { id: 'voyages-a-faire', nom: 'Voyages à faire', pins: ['49', '116', '124', '29', '77', '62'], secret: false, cree: 3 },
  { id: 'idees-deco', nom: 'Idées déco', pins: ['24', '39', '76', '104', '71'], secret: false, cree: 2 },
  { id: 'recettes', nom: 'Recettes', pins: ['63', '102', '75', '42'], secret: false, cree: 1 },
  { id: 'photo', nom: 'Inspiration photo', pins: ['91', '120', '111', '57', '95', '14', '47'], secret: true, cree: 0 },
]

const CONVERSATIONS_DE_DEPART: Conversation[] = [
  {
    id: 'camille',
    avec: 'Camille',
    couleur: '#e07a5f',
    messages: [
      { de: 'eux', texte: 'Regarde ce village, on y va cet été ?' },
      { de: 'moi', texte: 'Carrément, je l\'ajoute au tableau Voyages.' },
    ],
  },
  { id: 'yanis', avec: 'Yanis', couleur: '#3d405b', messages: [{ de: 'eux', texte: 'Tu m\'envoies le lien du bureau sombre ?' }] },
]

function slug(nom: string) {
  return nom
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

export function SessionProvider({ children }: { children: ReactNode }) {
  const [utilisateur, setUtilisateur] = useState<Utilisateur | null>(() => lire('pin-utilisateur', null))
  const [tableaux, setTableaux] = useState<Tableau[]>(() => lire('pin-tableaux', TABLEAUX_DE_DEPART))
  const [dernierId, setDernierId] = useState<string | null>(() => lire('pin-dernier', null))
  const [profil, setProfil] = useState<string[]>(() => lire('pin-profil', []))
  const [crees, setCrees] = useState<Pin[]>(() => lire('pin-crees', []))
  const [abonnements, setAbonnements] = useState<string[]>(() => lire('pin-abonnements', ['c4']))
  const [jaime, setJaime] = useState<string[]>(() => lire('pin-jaime', []))
  const [masques, setMasques] = useState<string[]>([])
  const [recherches, setRecherches] = useState<string[]>(() => lire('pin-recherches', ['bureau minimaliste', 'santorin']))
  const [conversations, setConversations] = useState<Conversation[]>(() => lire('pin-messages', CONVERSATIONS_DE_DEPART))
  const [theme, setTheme] = useState<Theme>(() => {
    const t = lire<string | null>('pin-theme-choix', null)
    return t === 'clair' || t === 'sombre' ? t : 'systeme'
  })
  const [toasts, setToasts] = useState<Toast[]>([])
  const compteur = useRef(0)

  useEffect(() => ecrire('pin-utilisateur', utilisateur), [utilisateur])
  useEffect(() => ecrire('pin-tableaux', tableaux), [tableaux])
  useEffect(() => ecrire('pin-dernier', dernierId), [dernierId])
  useEffect(() => ecrire('pin-profil', profil), [profil])
  useEffect(() => ecrire('pin-crees', crees), [crees])
  useEffect(() => ecrire('pin-abonnements', abonnements), [abonnements])
  useEffect(() => ecrire('pin-jaime', jaime), [jaime])
  useEffect(() => ecrire('pin-recherches', recherches), [recherches])
  useEffect(() => ecrire('pin-messages', conversations), [conversations])

  useEffect(() => {
    ecrire('pin-theme-choix', theme)
    const racine = document.documentElement
    if (theme === 'systeme') {
      delete racine.dataset.theme
      try {
        localStorage.removeItem('pin-theme')
      } catch {
        /* rien à faire */
      }
    } else {
      racine.dataset.theme = theme === 'sombre' ? 'dark' : 'light'
      try {
        localStorage.setItem('pin-theme', racine.dataset.theme)
      } catch {
        /* rien à faire */
      }
    }
  }, [theme])

  const annoncer = useCallback((t: Omit<Toast, 'id'>) => {
    compteur.current += 1
    const id = compteur.current
    setToasts((l) => [...l.slice(-2), { ...t, id }])
    window.setTimeout(() => setToasts((l) => l.filter((x) => x.id !== id)), 3600)
  }, [])

  const tousLesPins = useMemo(() => [...crees, ...PINS], [crees])

  const valeur = useMemo<Session>(() => {
    const trouverPin = (id: string) => tousLesPins.find((p) => p.id === id)
    return {
      utilisateur,
      connecter: (email) => {
        const base = email.split('@')[0] || 'invite'
        const nom = base.replace(/[._-]+/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()).trim()
        setUtilisateur({ nom, pseudo: slug(base) || 'invite', email, couleur: '#5b7a6b', apropos: '', site: '' })
      },
      deconnecter: () => setUtilisateur(null),
      modifierProfil: (champs) => setUtilisateur((u) => (u ? { ...u, ...champs, pseudo: slug(champs.pseudo ?? u.pseudo) || u.pseudo } : u)),
      tableaux,
      dernierTableau: tableaux.find((t) => t.id === dernierId) ?? null,
      creerTableau: (nom, secret) => {
        let id = slug(nom) || 'tableau'
        while (tableaux.some((t) => t.id === id)) id += '-2'
        const nouveau = { id, nom, pins: [], secret, cree: Date.now() }
        setTableaux((l) => [nouveau, ...l])
        return nouveau
      },
      enregistrer: (pinId, tableauId) => {
        const cible = tableauId ?? dernierId ?? 'profil'
        if (cible !== 'profil') {
          setTableaux((l) =>
            l.map((t) => (t.id === cible ? { ...t, pins: [pinId, ...t.pins.filter((p) => p !== pinId)] } : { ...t, pins: t.pins.filter((p) => p !== pinId) })),
          )
          setDernierId(cible)
        } else {
          setProfil((p) => [pinId, ...p.filter((x) => x !== pinId)])
        }
        const t = tableaux.find((x) => x.id === cible)
        const pin = trouverPin(pinId)
        annoncer({ texte: `Enregistrée dans ${t ? t.nom : 'votre profil'}`, image: pin?.image, lien: t ? `/${utilisateur?.pseudo}/${t.id}` : `/${utilisateur?.pseudo}` })
      },
      retirer: (pinId) => {
        setTableaux((l) => l.map((t) => ({ ...t, pins: t.pins.filter((p) => p !== pinId) })))
        setProfil((p) => p.filter((x) => x !== pinId))
      },
      estEnregistre: (pinId) => {
        const t = tableaux.find((x) => x.pins.includes(pinId))
        if (t) return t
        return profil.includes(pinId) ? { id: 'profil', nom: 'Profil', pins: profil, secret: false, cree: 0 } : undefined
      },
      crees,
      publier: (pin) => setCrees((l) => [pin, ...l]),
      tousLesPins,
      abonnements,
      suivre: (id) => setAbonnements((l) => (l.includes(id) ? l.filter((x) => x !== id) : [...l, id])),
      jaime,
      aimer: (id) => setJaime((l) => (l.includes(id) ? l.filter((x) => x !== id) : [...l, id])),
      masques,
      masquer: (id) => setMasques((l) => [...l, id]),
      demasquer: (id) => setMasques((l) => l.filter((x) => x !== id)),
      recherches,
      noterRecherche: (q) => {
        const propre = q.trim()
        if (propre) setRecherches((l) => [propre, ...l.filter((x) => x !== propre)].slice(0, 8))
      },
      effacerRecherches: () => setRecherches([]),
      conversations,
      envoyer: (cid, texte) =>
        setConversations((l) => l.map((c) => (c.id === cid ? { ...c, messages: [...c.messages, { de: 'moi', texte }] } : c))),
      theme,
      choisirTheme: setTheme,
      toasts,
      annoncer,
    }
  }, [utilisateur, tableaux, dernierId, profil, crees, tousLesPins, abonnements, jaime, masques, recherches, conversations, theme, toasts, annoncer])

  return <Contexte.Provider value={valeur}>{children}</Contexte.Provider>
}

export function useSession() {
  const s = useContext(Contexte)
  if (!s) throw new Error('useSession hors du SessionProvider')
  return s
}
