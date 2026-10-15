/*
 * Les icônes, tracées pour ce projet sur une grille de 24. Pleines quand
 * l'état est actif (accueil, cœur), au trait sinon : c'est ainsi que la barre
 * latérale montre la page où l'on se trouve.
 */

const TRACES = {
  accueil: 'M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4.5v-5.5h-5V20H5a1 1 0 0 1-1-1z',
  explorer: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18Zm3.9 5.1-2.2 5.6-5.6 2.2 2.2-5.6z',
  tableaux: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z',
  plus: 'M12 5v14M5 12h14',
  cloche: 'M6 16V11a6 6 0 1 1 12 0v5l1.5 2h-15zM10 20.5a2 2 0 0 0 4 0',
  bulle: 'M4 6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H10l-4.5 3.5V17H6a2 2 0 0 1-2-2z',
  roue: 'M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7ZM10.6 3h2.8l.5 2.3 1.7 1 2.2-.8 1.4 2.4-1.8 1.6v1.9l1.8 1.6-1.4 2.4-2.2-.8-1.7 1-.5 2.4h-2.8l-.5-2.4-1.7-1-2.2.8-1.4-2.4 1.8-1.6v-1.9L4.6 7.9 6 5.5l2.2.8 1.7-1z',
  loupe: 'M10.5 4a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM15.5 15.5 20 20',
  chevron: 'm6 9 6 6 6-6',
  droite: 'm9 6 6 6-6 6',
  gauche: 'm15 6-6 6 6 6',
  retour: 'M19 12H5M11 6l-6 6 6 6',
  croix: 'M6 6l12 12M18 6 6 18',
  partager: 'M12 15V4M7.5 8.5 12 4l4.5 4.5M5 13v6h14v-6',
  points: 'M5.5 12h.01M12 12h.01M18.5 12h.01',
  coeur: 'M12 20s-7.5-4.6-7.5-10A4.3 4.3 0 0 1 12 7.4 4.3 4.3 0 0 1 19.5 10c0 5.4-7.5 10-7.5 10Z',
  oeil: 'M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12ZM12 9.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5Z',
  fleche: 'M7 17 17 7M9 7h8v8',
  crayon: 'm4 20 1-4.5L15.5 5a2.1 2.1 0 0 1 3 3L8 18.5zM14 6.5l3 3',
  envoyer: 'M12 19V6M6.5 11.5 12 6l5.5 5.5',
  filtre: 'M4 7h10M18 7h2M4 17h2M10 17h10M14 5v4M6 15v4',
  photo: 'M4 8a2 2 0 0 1 2-2h2l1.5-2h5L16 6h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2zM12 9.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Z',
  objectif: 'M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z',
  lien: 'M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1',
  cadenas: 'M7 11V8a5 5 0 0 1 10 0v3M5.5 11h13v9h-13z',
  etincelle: 'M12 3.5 13.8 10l6.7 2-6.7 2L12 20.5 10.2 14 3.5 12l6.7-2z',
  telecharger: 'M12 4v11M7.5 10.5 12 15l4.5-4.5M5 19.5h14',
  drapeau: 'M6 21V4M6 4h11l-2 4 2 4H6',
  masquer: 'M4 4l16 16M10.6 6A9 9 0 0 1 21.5 12a14 14 0 0 1-2.8 3.4M6.5 7.6A14 14 0 0 0 2.5 12S6 18.5 12 18.5a8.8 8.8 0 0 0 3.6-.8',
  courrier: 'M4 6h16v12H4zM4.5 6.5 12 12.5l7.5-6',
  sourire: 'M12 3.5a8.5 8.5 0 1 0 0 17 8.5 8.5 0 0 0 0-17ZM8.5 14a4 4 0 0 0 7 0M9 9.5h.01M15 9.5h.01',
  coche: 'm5 12.5 4.5 4.5L19 7.5',
  personnes: 'M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7ZM2.5 20a6.5 6.5 0 0 1 13 0M16 4.3a3.5 3.5 0 0 1 0 6.4M18.5 14.5A6.5 6.5 0 0 1 21.5 20',
  aide: 'M12 3.5a8.5 8.5 0 1 0 0 17 8.5 8.5 0 0 0 0-17ZM9.6 9.3a2.5 2.5 0 1 1 3.4 2.3c-.6.3-1 .8-1 1.5v.6M12 16.5h.01',
  menu: 'M5 7h14M5 12h14M5 17h14',
  megaphone: 'M4 10.5v3a1.5 1.5 0 0 0 1.5 1.5H7l7 4.5v-15L7 9H5.5A1.5 1.5 0 0 0 4 10.5ZM17.5 9.5a3.5 3.5 0 0 1 0 5M7.5 15l1.2 4.5',
  discussion: 'M12 4c4.7 0 8.5 3.2 8.5 7.2s-3.8 7.2-8.5 7.2c-1 0-2-.1-2.9-.4L5 20l.9-3.6A6.8 6.8 0 0 1 3.5 11.2C3.5 7.2 7.3 4 12 4ZM8.5 11.2h.01M12 11.2h.01M15.5 11.2h.01',
} as const

export type NomIcone = keyof typeof TRACES

/* La boussole ne se remplit pas : pleine, son aiguille disparaît dans le disque. */
const PLEINES: NomIcone[] = ['accueil', 'coeur', 'cloche', 'bulle', 'tableaux', 'etincelle']

export function Icone({
  nom,
  taille = 24,
  plein = false,
  epaisseur = 2,
  className,
}: {
  nom: NomIcone
  taille?: number
  plein?: boolean
  epaisseur?: number
  className?: string
}) {
  const remplir = plein && PLEINES.includes(nom)
  return (
    <svg
      className={className}
      width={taille}
      height={taille}
      viewBox="0 0 24 24"
      fill={remplir ? 'currentColor' : 'none'}
      stroke="currentColor"
      strokeWidth={nom === 'points' ? 3.2 : epaisseur}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      <path d={TRACES[nom]} fillRule="evenodd" />
    </svg>
  )
}

/*
 * L'emplacement du logo officiel. Le fichier de la charte se dépose dans
 * src/assets/marque/logo.svg : s'il est là, Vite le sert et il remplace la
 * punaise partout. La recherche se fait à la construction, donc un fichier
 * absent ne coûte aucune requête en erreur.
 */
const OFFICIEL = Object.values(
  import.meta.glob('../assets/marque/logo.svg', { eager: true, query: '?url', import: 'default' }),
)[0] as string | undefined

/*
 * La marque. Par défaut, une punaise blanche dans un disque rouge, dessinée
 * pour ce projet : elle évoque l'épingle sans reprendre le logo déposé.
 */
export function Marque({ taille = 32, avecNom = false }: { taille?: number; avecNom?: boolean }) {
  if (OFFICIEL) {
    return (
      <span className="marque">
        <img src={OFFICIEL} width={taille} height={taille} alt="" />
        {avecNom && <span className="marque-nom">Pinterest</span>}
      </span>
    )
  }
  return (
    <span className="marque">
      <svg width={taille} height={taille} viewBox="0 0 32 32" aria-hidden="true">
        <circle cx="16" cy="16" r="16" fill="var(--rouge)" />
        <path
          fill="#fff"
          d="M11 8.5h10a1 1 0 0 1 .7 1.7L19.5 12.4v4.3l3.2 2.6a1 1 0 0 1-.6 1.8H17v6.4l-1 1.5-1-1.5v-6.4H9.9a1 1 0 0 1-.6-1.8l3.2-2.6v-4.3l-2.2-2.2A1 1 0 0 1 11 8.5Z"
        />
      </svg>
      {avecNom && <span className="marque-nom">Pinterest</span>}
    </span>
  )
}

export function Avatar({ nom, couleur, taille = 32 }: { nom: string; couleur: string; taille?: number }) {
  return (
    <span className="avatar" style={{ width: taille, height: taille, background: couleur, fontSize: taille * 0.42 }} aria-hidden="true">
      {nom.trim().charAt(0).toUpperCase() || '?'}
    </span>
  )
}
