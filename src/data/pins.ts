import photos from './photos.json'

/*
 * Les données du site. Tout est écrit ici, à la main : les photos viennent de
 * Picsum (licence Unsplash), téléchargées dans public/pins, et chaque titre a
 * été écrit en regardant la photo. Aucune donnée n'est tirée de Pinterest.
 */

export type Categorie =
  | 'voyage'
  | 'nature'
  | 'deco'
  | 'mode'
  | 'cuisine'
  | 'photo'
  | 'ville'
  | 'tech'
  | 'art'

export type Createur = {
  id: string
  nom: string
  pseudo: string
  couleur: string
  abonnes: number
  site?: string
}

export type Pin = {
  id: string
  image: string
  w: number
  h: number
  couleur: string
  titre: string
  description: string
  categorie: Categorie
  createur: Createur
  lien?: string
  photographe: string
  titreVisible: boolean
}

export type Commentaire = { auteur: string; couleur: string; texte: string; il_y_a: string }

export const CATEGORIES: Record<Categorie, { nom: string; recherche: string }> = {
  voyage: { nom: 'Voyages', recherche: 'idées voyage' },
  nature: { nom: 'Nature', recherche: 'paysages nature' },
  deco: { nom: 'Décoration intérieure', recherche: 'déco maison' },
  mode: { nom: 'Mode', recherche: 'tenues automne' },
  cuisine: { nom: 'Cuisine', recherche: 'recettes faciles' },
  photo: { nom: 'Photographie', recherche: 'idées photo' },
  ville: { nom: 'Architecture', recherche: 'architecture urbaine' },
  tech: { nom: 'Bureau et tech', recherche: 'setup bureau' },
  art: { nom: 'Art', recherche: 'art minimaliste' },
}

export const CREATEURS: Createur[] = [
  { id: 'c1', nom: 'Atelier Brume', pseudo: 'atelierbrume', couleur: '#5b7a6b', abonnes: 48200, site: 'atelierbrume.fr' },
  { id: 'c2', nom: 'Carnet de Route', pseudo: 'carnetderoute', couleur: '#2f6690', abonnes: 126500, site: 'carnetderoute.com' },
  { id: 'c3', nom: 'Léa Moreau', pseudo: 'leamoreau', couleur: '#b5838d', abonnes: 9310 },
  { id: 'c4', nom: 'Maison Sauge', pseudo: 'maisonsauge', couleur: '#7d8f69', abonnes: 75400, site: 'maisonsauge.fr' },
  { id: 'c5', nom: 'Petit Four', pseudo: 'petitfour', couleur: '#c0763c', abonnes: 210300, site: 'petitfour.fr' },
  { id: 'c6', nom: 'Grain Argentique', pseudo: 'grainargentique', couleur: '#3d3d3d', abonnes: 33800 },
  { id: 'c7', nom: 'Nomade Studio', pseudo: 'nomadestudio', couleur: '#8a5a44', abonnes: 18700, site: 'nomadestudio.co' },
  { id: 'c8', nom: 'Hugo Lambert', pseudo: 'hugolambert', couleur: '#4a4e69', abonnes: 2140 },
  { id: 'c9', nom: 'Verde Journal', pseudo: 'verdejournal', couleur: '#386641', abonnes: 61200, site: 'verdejournal.fr' },
  { id: 'c10', nom: 'Bureau Clair', pseudo: 'bureauclair', couleur: '#6c757d', abonnes: 27450, site: 'bureauclair.io' },
]

const DESCRIPTIONS: Record<Categorie, string[]> = {
  voyage: [
    'Une étape à garder pour le prochain départ. Lumière du matin, peu de monde, et le temps de tout regarder.',
    'Carnet d\'adresses en fin d\'article : où dormir, où manger, et le meilleur moment de l\'année pour y aller.',
  ],
  nature: [
    'Le genre d\'endroit où l\'on coupe le téléphone. Sentier facile, deux heures aller-retour.',
    'Couleurs de saison et grand air : une idée de balade pour le week-end.',
  ],
  deco: [
    'Bois brut, tons doux et matières naturelles pour un intérieur qui respire.',
    'Petits détails, grand effet : à reproduire sans tout changer chez soi.',
  ],
  mode: [
    'Une tenue simple qui se décline toute la saison. Les pièces sont listées dans l\'article.',
    'Des basiques qui durent, et une touche de couleur pour réveiller l\'ensemble.',
  ],
  cuisine: [
    'Prête en vingt minutes, avec ce qu\'il reste dans le placard. Recette complète sur le site.',
    'Un classique revisité, à servir tiède avec une boisson chaude.',
  ],
  photo: [
    'Réglages, objectif et heure de prise de vue détaillés sous la photo.',
    'Une composition à tenter avec un simple téléphone : tout se joue dans la lumière.',
  ],
  ville: [
    'Lignes, matières et lumière : une architecture qui se regarde de près.',
    'Promenade urbaine en dix arrêts, à faire à pied en une matinée.',
  ],
  tech: [
    'Un poste de travail épuré, pensé pour rester concentré toute la journée.',
    'Câbles cachés, lumière douce et l\'essentiel à portée de main.',
  ],
  art: [
    'Texture, matière et couleur : une source d\'inspiration pour un prochain projet.',
    'Le détail qui fait tout. À imprimer en grand format pour un mur blanc.',
  ],
}

/* id de la photo, titre, catégorie, créateur, titre affiché sous l'image */
const FICHES: [string, string, Categorie, number, boolean?][] = [
  ['10', 'Forêt de pins au bord du lac', 'nature', 8],
  ['11', 'Vallée brumeuse au petit matin', 'nature', 0, true],
  ['12', 'Rochers noirs sur plage de sable', 'voyage', 1],
  ['13', 'Crique sauvage de la côte ouest', 'voyage', 1, true],
  ['14', 'Bord de mer, ciel laiteux', 'photo', 5],
  ['15', 'Cascade cachée dans la montagne', 'nature', 8, true],
  ['16', 'Baie calme et îles au loin', 'voyage', 1],
  ['17', 'Chemin de campagne au printemps', 'nature', 8],
  ['18', 'Herbes hautes en gros plan', 'photo', 5],
  ['19', 'Mousse dorée sur un tronc', 'nature', 0],
  ['20', 'Bureau créatif et magazines', 'tech', 9, true],
  ['21', 'Escarpins blancs sur bois rouge', 'mode', 2, true],
  ['22', 'Costume ajusté, allure de ville', 'mode', 7],
  ['23', 'Fourchettes en noir et blanc', 'art', 5],
  ['24', 'Coin lecture et vieux livre', 'deco', 3, true],
  ['25', 'Branches roses en contre-jour', 'art', 2],
  ['26', 'Essentiels du gentleman à plat', 'mode', 7, true],
  ['27', 'Dunes dorées au coucher du soleil', 'voyage', 6],
  ['28', 'Canopée verte vue d\'en haut', 'nature', 8],
  ['29', 'Sommets enneigés de l\'Himalaya', 'voyage', 1, true],
  ['30', 'Tasse vintage au soleil', 'cuisine', 4],
  ['31', 'Pieds nus et lumière blanche', 'photo', 5],
  ['32', 'Mur blanc patiné', 'art', 2],
  ['33', 'Fleurs sauvages au crépuscule', 'nature', 0],
  ['34', 'Bidon rouge rouillé dans l\'herbe', 'photo', 5],
  ['35', 'Cactus en macro, épines dorées', 'nature', 8],
  ['36', 'Appareil photo démonté pièce par pièce', 'tech', 9, true],
  ['37', 'Falaise fleurie face à l\'océan', 'voyage', 1],
  ['38', 'Nuage et trace d\'avion', 'photo', 5],
  ['39', 'Platine vinyle en gros plan', 'deco', 3, true],
  ['40', 'Museau de chat tout doux', 'photo', 7],
  ['41', 'Gouttes d\'eau sur surface mate', 'art', 2],
  ['42', 'Café du matin sur table en bois', 'cuisine', 4, true],
  ['43', 'Pont de Brooklyn la nuit', 'ville', 6],
  ['44', 'Plage dans la brume', 'voyage', 1],
  ['45', 'Tuk-tuk de Bangkok en détail', 'voyage', 6],
  ['46', 'Collines désertiques à perte de vue', 'voyage', 1],
  ['47', 'Ponton en noir et blanc', 'photo', 5],
  ['48', 'Portable et café, coin travail', 'tech', 9],
  ['49', 'Santorin, maisons blanches et moulins', 'voyage', 1, true],
  ['50', 'Cormoran sur la corde', 'photo', 5],
  ['51', 'Horizon marin en monochrome', 'photo', 5],
  ['52', 'Ponton en bois flou', 'photo', 7],
  ['53', 'Fumée bleue sur ciel profond', 'art', 2],
  ['54', 'Randonneurs au sommet', 'voyage', 6, true],
  ['55', 'Feuille neuve sur bois flotté', 'nature', 8],
  ['56', 'Bokeh coloré pour fond d\'écran', 'art', 2],
  ['57', 'Rue de New York déserte', 'ville', 6, true],
  ['58', 'Phare sous ciel d\'orage', 'voyage', 1],
  ['59', 'Clôture de ferme en automne', 'nature', 0],
  ['60', 'Setup sombre et carnet en cuir', 'tech', 9, true],
  ['61', 'Toits d\'une vieille ville d\'Europe', 'ville', 6],
  ['62', 'Collines de Toscane dans la brume', 'voyage', 1],
  ['63', 'Café au lait sur fond rouge', 'cuisine', 4, true],
  ['64', 'Lunettes de soleil et bouquet des champs', 'mode', 2, true],
  ['65', 'Cheveux dans la lumière dorée', 'mode', 2],
  ['66', 'Plaine verte et montagnes', 'nature', 8],
  ['67', 'Vallée boisée en noir et blanc', 'photo', 5],
  ['68', 'Quai de gare au bord de l\'eau', 'ville', 6],
  ['69', 'Voie ferrée dans la forêt', 'voyage', 6],
  ['70', 'Arbres dans le brouillard', 'nature', 0],
  ['71', 'Balançoire face au lac', 'deco', 3, true],
  ['72', 'Aiguilles de pin au sol', 'photo', 7],
  ['73', 'Balle de baseball et gant', 'photo', 7],
  ['74', 'Ville au loin et kayak', 'voyage', 1],
  ['75', 'Raisins noirs de fin d\'été', 'cuisine', 4, true],
  ['76', 'Vélo vert contre bois patiné', 'deco', 3, true],
  ['77', 'Ponton vers le kiosque sur l\'eau', 'voyage', 1, true],
  ['78', 'Porte ancienne en bois sculpté', 'ville', 6, true],
  ['79', 'Route de montagne en lacets', 'voyage', 6],
  ['80', 'Pomme de pin en macro', 'nature', 0],
  ['81', 'Tunnel de verdure', 'nature', 8],
  ['82', 'Fleurs de cerisier', 'art', 2, true],
  ['83', 'Forêt sombre de conifères', 'nature', 8],
  ['84', 'Pont suspendu au crépuscule', 'ville', 6],
  ['85', 'Tracteur bleu dans les blés', 'photo', 7],
  ['87', 'Banc face à la mer', 'deco', 3],
  ['88', 'Avenue vue du ciel', 'ville', 6, true],
  ['89', 'Brins d\'herbe à contre-jour', 'photo', 5],
  ['90', 'Bouteilles vertes sur la clôture', 'deco', 3],
  ['91', 'Appareil photo moyen format', 'photo', 5, true],
  ['92', 'Coquillages sur le sable', 'voyage', 1],
  ['93', 'Prairie fleurie au printemps', 'nature', 8],
  ['94', 'Sous-bois et lumière tamisée', 'nature', 0],
  ['95', 'Arbres nus dans la brume', 'art', 2, true],
  ['96', 'Manette de jeu rétroéclairée', 'tech', 9],
  ['98', 'Épis de blé dans le vent', 'nature', 0],
  ['99', 'Vieille charrette en bois', 'photo', 7],
  ['100', 'Plage animée sous le voile de chaleur', 'voyage', 1],
  ['101', 'Bunker en béton, ciel d\'azur', 'ville', 6, true],
  ['102', 'Framboises fraîches au soleil', 'cuisine', 4, true],
  ['103', 'Pause dans l\'herbe en baskets', 'mode', 7],
  ['104', 'Attrape-rêves en macramé', 'deco', 3, true],
  ['106', 'Fleurs roses sur ciel bleu', 'art', 2],
  ['107', 'Champ de blé vert', 'nature', 8],
  ['108', 'Palmiers en lumière pâle', 'voyage', 6],
  ['109', 'Graminées dans le soleil couchant', 'nature', 0],
  ['110', 'Coucher de soleil sur la campagne', 'voyage', 1, true],
  ['111', 'Voiture ancienne aux chromes', 'photo', 7, true],
  ['112', 'Herbes sèches de fin d\'été', 'nature', 8],
  ['113', 'Thé fumant en gros plan', 'cuisine', 4],
  ['114', 'Ciel d\'orage sur la plaine', 'photo', 5],
  ['115', 'Bitume après la pluie', 'art', 2],
  ['116', 'Villa toscane et cyprès', 'voyage', 1, true],
  ['117', 'Concert en contre-jour', 'photo', 7],
  ['118', 'Chardon et vallée', 'nature', 0],
  ['120', 'Voie lactée au-dessus du champ', 'photo', 5, true],
  ['121', 'Gorges dans le brouillard', 'nature', 8],
  ['122', 'Londres de nuit, dôme illuminé', 'ville', 6, true],
  ['123', 'Gouttes de pluie sur métal', 'art', 2],
  ['124', 'Barque rouge sur eau turquoise', 'voyage', 1, true],
  ['125', 'Lac et collines sèches', 'nature', 0],
  ['126', 'Reflets sur l\'eau en mouvement', 'art', 2],
  ['127', 'Mousse et sous-bois lumineux', 'nature', 8],
  ['128', 'Lac alpin et roseaux', 'voyage', 1],
  ['129', 'Duo sur un banc face à la baie', 'photo', 7, true],
  ['130', 'Mouette sur ciel gris', 'photo', 5],
  ['132', 'Plaque de glace au coucher du soleil', 'nature', 0],
]

const parId = new Map(photos.map((p) => [p.id, p]))

export const PINS: Pin[] = FICHES.flatMap(([id, titre, categorie, c, visible], rang) => {
  const photo = parId.get(id)
  if (!photo) return []
  const createur = CREATEURS[c]
  return [
    {
      id,
      image: `/pins/${id}.jpg`,
      w: photo.w,
      h: photo.h,
      couleur: photo.couleur,
      titre,
      description: DESCRIPTIONS[categorie][rang % 2],
      categorie,
      createur,
      lien: createur.site,
      photographe: photo.auteur,
      titreVisible: Boolean(visible),
    },
  ]
})

export const pinParId = (id: string) => PINS.find((p) => p.id === id)

export const pinsDe = (categorie: Categorie) => PINS.filter((p) => p.categorie === categorie)

/** Un ordre mélangé mais stable : le même à chaque visite, comme un fil. */
export function melange<T>(liste: T[], graine = 7): T[] {
  const copie = [...liste]
  let s = graine
  for (let i = copie.length - 1; i > 0; i -= 1) {
    s = (s * 9301 + 49297) % 233280
    const j = Math.floor((s / 233280) * (i + 1))
    ;[copie[i], copie[j]] = [copie[j], copie[i]]
  }
  return copie
}

/*
 * Les résultats d'une recherche, sans doublon : ce qui correspond d'abord,
 * puis le reste des catégories touchées, puis tout le catalogue. Comme sur le
 * vrai site, une recherche étroite ne finit jamais sur une page vide.
 */
export function chercher(requete: string): Pin[] {
  const q = sansAccents(requete.trim().toLowerCase())
  if (!q) return []
  const mots = q.split(/\s+/).filter((m) => m.length > 2)
  const trouves = PINS.filter((p) => {
    const texte = sansAccents(`${p.titre} ${p.description} ${CATEGORIES[p.categorie].nom} ${CATEGORIES[p.categorie].recherche}`.toLowerCase())
    return mots.some((m) => texte.includes(m))
  })
  const cats = new Set(trouves.map((p) => p.categorie))
  const voisins = melange(PINS.filter((p) => cats.has(p.categorie) && !trouves.includes(p)), q.length)
  const reste = melange(PINS.filter((p) => !cats.has(p.categorie)), q.length + 1)
  return [...trouves, ...voisins, ...reste]
}

export function sansAccents(s: string) {
  return s.normalize('NFD').replace(/[̀-ͯ]/g, '')
}

export const COMMENTAIRES: Commentaire[] = [
  { auteur: 'Camille', couleur: '#e07a5f', texte: 'Magnifique, ça donne envie de partir tout de suite.', il_y_a: '2 j' },
  { auteur: 'Yanis', couleur: '#3d405b', texte: 'Tu as utilisé quel objectif ?', il_y_a: '5 j' },
  { auteur: 'Inès', couleur: '#81b29a', texte: 'Enregistré pour mon prochain projet !', il_y_a: '1 sem.' },
]

export const RECHERCHES_POPULAIRES = [
  'déco automne',
  'recettes de saison',
  'tenue mi-saison',
  'idées week-end',
  'bureau minimaliste',
  'photo argentique',
  'balade en forêt',
  'cuisine japandi',
]

/** Les thèmes du moment, ceux de la page Idées et de l'accueil déconnecté. */
export const THEMES = [
  { sur_titre: 'Saison des couleurs', titre: 'Balades d\'automne en forêt', image: '/pins/110.jpg', recherche: 'forêt' },
  { sur_titre: 'Douceur maison', titre: 'Coins lecture et bois brut', image: '/pins/24.jpg', recherche: 'lecture' },
  { sur_titre: 'Pause gourmande', titre: 'Boissons chaudes et fruits de saison', image: '/pins/63.jpg', recherche: 'café' },
  { sur_titre: 'Ailleurs', titre: 'Villages blancs au bord de l\'eau', image: '/pins/49.jpg', recherche: 'santorin' },
  { sur_titre: 'Lumière', titre: 'Photographier la brume', image: '/pins/95.jpg', recherche: 'brume' },
  { sur_titre: 'Bureau', titre: 'Setups sombres et épurés', image: '/pins/60.jpg', recherche: 'setup' },
]
