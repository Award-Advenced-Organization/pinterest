import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PINS_DIR = path.join(__dirname, '..', 'public', 'pins');

export const CURRENT_USER = {
  id: 'usr_jaye_ahf_01',
  username: 'ahiffent',
  full_name: 'Jaye ahf',
  avatar_url: '/avatar_jaye.jpg',
  bio: '',
  pronouns: [],
  website: 'http://ahiffonjephte.me',
  email: '',
  country_code: '+229',
  phone: '',
  follower_count: 1,
  following_count: 2,
  is_verified: false,
  appearance: 'system',
};

// Créateurs fictifs qui publient les Épingles du fil.
export const CREATORS = [
  { id: 'creator_1', name: 'Léa Martin', username: 'lea.martin' },
  { id: 'creator_2', name: 'Camille Durand', username: 'camille_design' },
  { id: 'creator_3', name: 'Moussa Diallo', username: 'moussa.dl' },
  { id: 'creator_4', name: 'Inès Benali', username: 'ines.creative' },
  { id: 'creator_5', name: 'Hugo Lefèvre', username: 'hugo.lfv' },
  { id: 'creator_6', name: 'Aïcha Koné', username: 'aicha.kone' },
  { id: 'creator_7', name: 'Théo Bernard', username: 'theo_photo' },
  { id: 'creator_8', name: 'Sarah Mensah', username: 'sarahmensah' },
  { id: 'creator_9', name: 'Yanis Roux', username: 'yanis.roux' },
  { id: 'creator_10', name: 'Fatou Sow', username: 'fatou.sow' },
];

// Utilisateurs présents dans l'activité (suggestions, abonnés).
export const OTHER_USERS = [
  { id: 'usr_alassanemomo', name: 'Alassanemomo', username: 'alassanemomo', avatar_url: '' },
  { id: 'usr_zora', name: 'zora', username: 'zora', avatar_url: '/pins/117.jpg' },
];

// Titre, catégorie et mots-clés de chaque image, décrits d'après son contenu réel.
const IMAGE_INFO = {
  10: ['Pins face au lac de montagne', 'nature', 'forêt lac montagne fond d’écran'],
  11: ['Rivière dans la vallée brumeuse', 'nature', 'rivière brume vallée fond d’écran'],
  12: ['Rochers sur la plage au matin', 'mer', 'plage rochers bord de mer'],
  13: ['Plage de galets et mer calme', 'mer', 'plage galets bord de mer'],
  14: ['Côte rocheuse sous un ciel pâle', 'mer', 'côte rochers bord de mer'],
  15: ['Cascade au cœur de la montagne', 'montagne', 'cascade montagne randonnée'],
  16: ['Rochers et horizon marin', 'mer', 'horizon rochers bord de mer'],
  17: ['Sentier entre les sapins', 'nature', 'sentier forêt randonnée fond d’écran'],
  18: ['Herbes hautes en plein soleil', 'nature', 'herbes été prairie'],
  19: ['Mousse sur un tronc en forêt', 'nature', 'mousse forêt macro'],
  20: ['Bureau créatif et carnet de design', 'design', 'design bureau typographie setup'],
  21: ['Escarpins blancs sur fond rouge', 'mode', 'mode chaussures escarpins'],
  22: ['Silhouette urbaine minimaliste', 'photo', 'minimalisme ville photographie'],
  23: ['Fourchettes en noir et blanc', 'photo', 'noir et blanc nature morte photographie'],
  24: ['Livre ouvert et lumière douce', 'lifestyle', 'lecture livre cosy'],
  25: ['Branches fleuries en contre-jour', 'nature', 'fleurs branches printemps'],
  26: ['Essentiels du voyageur à plat', 'lifestyle', 'flat lay accessoires homme voyage'],
  27: ['Coucher de soleil sur la falaise', 'voyage', 'coucher de soleil falaise voyage'],
  28: ['Forêt verdoyante et rivière', 'nature', 'forêt rivière fond d’écran'],
  29: ['Sommets enneigés', 'montagne', 'montagne neige sommets fond d’écran'],
  30: ['Mug vintage sur la nappe', 'lifestyle', 'café mug vintage'],
  31: ['Pieds au repos en noir et blanc', 'photo', 'noir et blanc portrait photographie'],
  32: ['Mur blanc et banc de pierre', 'photo', 'minimalisme architecture photographie'],
  33: ['Prairie dorée au lever du soleil', 'nature', 'prairie lever de soleil fond d’écran'],
  34: ['Bidon rouge dans les herbes', 'photo', 'rouge rouille photographie'],
  35: ['Cactus en lumière rasante', 'nature', 'cactus macro plante'],
  36: ['Appareils photo vintage à plat', 'photo', 'appareil photo flat lay vintage photographie'],
  37: ['Côte fleurie au bord de la mer', 'mer', 'côte fleurs bord de mer voyage'],
  38: ['Nuages sur un ciel bleu canard', 'nature', 'nuages ciel fond d’écran'],
  39: ['Platine vinyle', 'lifestyle', 'vinyle musique déco'],
  40: ['Museau de chat en gros plan', 'animaux', 'chat animaux macro'],
  41: ['Gouttes d’eau sur une surface', 'photo', 'gouttes macro photographie'],
  42: ['Table en bois et café', 'lifestyle', 'café table déco cosy'],
  43: ['Pont de Brooklyn la nuit', 'ville', 'new york pont nuit ville'],
  44: ['Plage dans la brume', 'mer', 'plage brume bord de mer'],
  45: ['Tuk-tuk coloré', 'voyage', 'voyage asie tuk-tuk'],
  46: ['Canyon et désert', 'voyage', 'désert canyon voyage'],
  47: ['Jetée dans le brouillard', 'mer', 'jetée brouillard bord de mer'],
  48: ['Ordinateur portable sur un bureau en bois', 'tech', 'setup bureau ordinateur tech'],
  49: ['Moulins de Santorin', 'voyage', 'santorin grèce voyage'],
  50: ['Cormoran sur la barque', 'animaux', 'oiseau barque bord de mer'],
  51: ['Vagues en noir et blanc', 'mer', 'vagues noir et blanc bord de mer'],
  52: ['Poste de surveillance sur la plage', 'mer', 'plage été bord de mer'],
  53: ['Traînée lumineuse dans le ciel', 'nature', 'ciel bleu fond d’écran'],
  54: ['Colline sous les nuages', 'voyage', 'colline nuages randonnée'],
  55: ['Pousse sur un vieux tronc', 'nature', 'plante macro forêt'],
  56: ['Bokeh coloré', 'photo', 'bokeh lumières photographie fond d’écran'],
  57: ['Rue de New York au petit matin', 'ville', 'new york rue ville'],
  58: ['Phare en noir et blanc', 'mer', 'phare noir et blanc bord de mer'],
  59: ['Clôture et barbelés en été', 'campagne', 'campagne clôture été'],
  60: ['Setup de bureau sombre et minimaliste', 'tech', 'setup bureau clavier tech minimalisme'],
  61: ['Vieille ville en noir et blanc', 'ville', 'ville noir et blanc architecture'],
  62: ['Vallée au coucher du soleil', 'nature', 'vallée coucher de soleil fond d’écran'],
  63: ['Tasse de café sur fond rouge', 'lifestyle', 'café rouge minimalisme'],
  64: ['Portrait aux lunettes et fleurs sauvages', 'photo', 'portrait fleurs été photographie'],
  65: ['Cheveux au vent au soleil couchant', 'photo', 'portrait coucher de soleil photographie'],
  66: ['Plaine et montagnes au loin', 'nature', 'plaine montagne fond d’écran'],
  67: ['Collines boisées en noir et blanc', 'nature', 'collines noir et blanc'],
  68: ['Ponton et lampadaires', 'mer', 'ponton noir et blanc bord de mer'],
  69: ['Voie ferrée en forêt', 'voyage', 'train rails forêt voyage'],
  70: ['Route bordée d’arbres dans la brume', 'nature', 'route brume arbres fond d’écran'],
  71: ['Balançoire au bord du lac', 'campagne', 'balançoire lac campagne'],
  72: ['Herbes sauvages en noir et blanc', 'photo', 'noir et blanc herbes photographie'],
  73: ['Balle de baseball entre les mains', 'sport', 'baseball sport'],
  74: ['Baie de San Francisco', 'ville', 'san francisco baie ville voyage'],
  75: ['Grappes de raisin', 'cuisine', 'raisin vigne automne'],
  76: ['Vélo vert devant une porte en bois', 'lifestyle', 'vélo vintage porte'],
  77: ['Ponton vers le kiosque sur la mer', 'voyage', 'ponton maldives voyage bord de mer'],
  78: ['Porte ancienne en bois', 'architecture', 'porte architecture vintage'],
  79: ['Route de montagne en noir et blanc', 'montagne', 'route montagne noir et blanc'],
  80: ['Pomme de pin en noir et blanc', 'nature', 'pomme de pin macro noir et blanc'],
  81: ['Tunnel de verdure', 'nature', 'forêt tunnel fond d’écran'],
  82: ['Fleurs de cerisier', 'nature', 'cerisier fleurs printemps fond d’écran'],
  83: ['Forêt de sapins au crépuscule', 'nature', 'forêt sapins fond d’écran'],
  84: ['Pont suspendu sous l’orage', 'ville', 'pont architecture nuit ville'],
  85: ['Tracteur dans les champs', 'campagne', 'campagne tracteur champ'],
  87: ['Banc sur le ponton face à la mer', 'mer', 'banc ponton bord de mer'],
  88: ['Circulation vue du ciel', 'ville', 'ville drone route'],
  89: ['Herbes au premier plan', 'nature', 'herbes macro'],
  90: ['Bouteilles en verre sur la clôture', 'déco', 'bouteilles vintage déco'],
  91: ['Appareil photo argentique', 'photo', 'appareil photo argentique photographie'],
  92: ['Coquillages sur le sable', 'mer', 'coquillages plage bord de mer'],
  93: ['Prairie au lever du jour', 'nature', 'prairie matin'],
  94: ['Herbes et lumière du soir', 'nature', 'herbes lumière'],
  95: ['Arbres dans le brouillard', 'nature', 'arbres brouillard automne fond d’écran'],
  96: ['Voiture de sport de nuit', 'voiture', 'voiture sport nuit'],
  98: ['Épis sauvages au soleil', 'nature', 'épis été prairie'],
  99: ['Roue de charrette ancienne', 'campagne', 'vintage roue noir et blanc'],
  100: ['Plage animée dans la brume', 'mer', 'plage été bord de mer'],
  101: ['Bunker en béton', 'architecture', 'architecture béton brutalisme'],
  102: ['Framboises sur un gâteau', 'cuisine', 'framboises gâteau dessert'],
  103: ['Baskets dans le pré', 'mode', 'baskets mode été'],
  104: ['Attrape-rêves', 'déco', 'attrape-rêves bohème déco'],
  106: ['Fleurs roses sur ciel bleu', 'nature', 'fleurs printemps'],
  107: ['Champ de blé vert', 'campagne', 'blé champ campagne'],
  108: ['Palmiers dans le désert', 'voyage', 'palmiers désert voyage'],
  109: ['Lumière dorée dans les herbes', 'nature', 'lumière dorée prairie fond d’écran'],
  110: ['Coucher de soleil sur la savane', 'voyage', 'savane coucher de soleil afrique voyage'],
  111: ['Voiture ancienne', 'voiture', 'voiture vintage'],
  112: ['Champ de blé doré', 'campagne', 'blé été campagne'],
  113: ['Thé chaud au réveil', 'lifestyle', 'thé matin cosy'],
  114: ['Ciel d’orage', 'nature', 'orage ciel nuages'],
  115: ['Pluie sur la vitre', 'photo', 'pluie vitre photographie'],
  116: ['Villa toscane', 'voyage', 'toscane italie voyage'],
  117: ['Concert et lumières', 'musique', 'concert musique lumières'],
  118: ['Chardons sur la colline', 'nature', 'chardons colline'],
  120: ['Voie lactée au-dessus de la clôture', 'nature', 'étoiles nuit voie lactée fond d’écran'],
  121: ['Gorges en noir et blanc', 'montagne', 'montagne gorges noir et blanc'],
  122: ['Cathédrale Saint-Paul de nuit', 'ville', 'londres nuit ville architecture'],
  123: ['Gouttes de pluie en macro', 'photo', 'gouttes macro photographie'],
  124: ['Barque sur une eau turquoise', 'mer', 'barque turquoise bord de mer'],
  125: ['Lac et herbes sèches', 'nature', 'lac automne'],
  126: ['Glace sur l’eau', 'nature', 'glace hiver'],
  127: ['Mousse et sous-bois', 'nature', 'mousse forêt'],
  128: ['Lac de montagne et roseaux', 'montagne', 'lac montagne roseaux'],
  129: ['Couple sur un banc au coucher du soleil', 'lifestyle', 'couple coucher de soleil'],
  130: ['Mouette dans le ciel blanc', 'nature', 'oiseau ciel minimalisme'],
  132: ['Paysage d’automne et flaques', 'nature', 'automne flaques'],
};

const DESCRIPTIONS = {
  nature: 'Un coin de nature pour respirer un peu. Parfait en fond d’écran.',
  mer: 'Le bord de mer, le bruit des vagues et rien d’autre.',
  montagne: 'Grand air, sommets et randonnées à prévoir.',
  ville: 'Ambiance urbaine et architecture à découvrir.',
  voyage: 'À ajouter à la liste des voyages à faire.',
  lifestyle: 'Petits moments du quotidien, simples et doux.',
  photo: 'Idée de composition pour vos prochaines photos.',
  campagne: 'La campagne, ses champs et sa lumière.',
  design: 'Inspiration pour vos projets de design.',
  tech: 'Idées de setup et d’espace de travail.',
  mode: 'Idée de style à reproduire.',
  déco: 'Une touche de déco facile à reproduire.',
  cuisine: 'Gourmandise et produits de saison.',
  voiture: 'Pour les passionnés d’automobile.',
  architecture: 'Matières, lignes et détails d’architecture.',
  animaux: 'Nos amis les animaux.',
  musique: 'Pour les amoureux de musique.',
  sport: 'Esprit sportif.',
};

function readImageMeta() {
  try {
    return JSON.parse(fs.readFileSync(path.join(PINS_DIR, 'meta.json'), 'utf-8'));
  } catch (_) {
    return {};
  }
}

export const IMAGE_META = readImageMeta();

export function creatorFor(index) {
  const c = CREATORS[index % CREATORS.length];
  const avatarIds = [64, 65, 31, 91, 129, 21, 36, 103, 26, 113];
  return { ...c, avatar_url: `/pins/${avatarIds[index % avatarIds.length]}.jpg` };
}

// Épingles du fil : une par image disponible, avec ses vraies dimensions et sa couleur dominante.
export function generateInitialPins() {
  const ids = Object.keys(IMAGE_INFO).map(Number).sort((a, b) => a - b);
  const pins = [];
  ids.forEach((n, i) => {
    const file = `${n}.jpg`;
    const meta = IMAGE_META[file] ?? { width: 474, height: 711, dominant_color: '#cfcfcf' };
    const [title, category, tags] = IMAGE_INFO[n];
    // Une Épingle sur sept est un carrousel avec les images voisines de la même catégorie.
    let images;
    if (i % 7 === 3) {
      const same = ids.filter((m) => m !== n && IMAGE_INFO[m][1] === category).slice(0, 3);
      if (same.length >= 2) images = [`/pins/${file}`, ...same.map((m) => `/pins/${m}.jpg`)];
    }
    pins.push({
      id: `pin_${n}`,
      title,
      description: DESCRIPTIONS[category] ?? '',
      tags: tags.split(' '),
      link: i % 4 === 0 ? 'https://unsplash.com' : undefined,
      image_url: `/pins/${file}`,
      images,
      is_carousel: Boolean(images),
      width: meta.width,
      height: meta.height,
      aspect_ratio: meta.width / meta.height,
      dominant_color: meta.dominant_color,
      category,
      creator: creatorFor(i),
      repin_count: ((i + 1) * 23) % 200 + 5,
      like_count: ((i + 1) * 17) % 80,
      created_at: new Date(Date.now() - (i + 1) * 3600 * 24 * 1000).toISOString(),
    });
  });
  // Ordre du fil mélangé de façon stable (même ordre à chaque démarrage).
  let seed = 42;
  const rand = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
  for (let i = pins.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [pins[i], pins[j]] = [pins[j], pins[i]];
  }
  return pins;
}

// Épingles enregistrées au départ, encore non classées dans un tableau.
export const INITIAL_SAVED = [
  10, 11, 17, 28, 29, 33, 38, 53, 56, 62, 66, 70, 81, 82, 83, 95, 109, 120, // nature, fond d’écran
  12, 13, 14, 16, 37, 44, 47, 51, 52, 58, 68, 87, 92, 100, 124, // bord de mer
  23, 31, 36, 41, 64, 65, 72, 91, 115, // photographie
].map((n) => `pin_${n}`);

// Regroupements proposés sur le profil (« clusters ») : un nom et les mots-clés qui le composent.
export const CLUSTERS = [
  { id: 'cluster_fond_ecran', name: 'Fond d’écran', tag: 'fond' },
  { id: 'cluster_bord_de_mer', name: 'Bord de mer', category: 'mer' },
  { id: 'cluster_photographie', name: 'Photographie', category: 'photo' },
];

// Cartes de la page Rechercher (tapées = recherche du terme).
export const SEARCH_IDEAS = {
  ideas: [
    { title: 'Fond d’écran nature', query: 'fond d’écran', image: '/pins/83.jpg' },
    { title: 'Photographie portrait', query: 'portrait', image: '/pins/64.jpg' },
    { title: 'Setup bureau', query: 'setup', image: '/pins/60.jpg' },
    { title: 'Bord de mer', query: 'bord de mer', image: '/pins/77.jpg' },
    { title: 'Noir et blanc', query: 'noir et blanc', image: '/pins/58.jpg' },
    { title: 'Voyages à faire', query: 'voyage', image: '/pins/49.jpg' },
    { title: 'Ville la nuit', query: 'nuit', image: '/pins/43.jpg' },
    { title: 'Coucher de soleil', query: 'coucher de soleil', image: '/pins/110.jpg' },
  ],
  popular: [
    { title: 'Montagne', query: 'montagne', image: '/pins/29.jpg' },
    { title: 'Café cosy', query: 'café', image: '/pins/63.jpg' },
    { title: 'Vintage', query: 'vintage', image: '/pins/111.jpg' },
    { title: 'Fleurs de printemps', query: 'printemps', image: '/pins/82.jpg' },
  ],
};

export const ACTIVITY = [
  { id: 'act_1', type: 'suggestion', user: 'alassanemomo', text: 'Vous connaissez peut-être', time_ago: '1 sem.' },
  { id: 'act_2', type: 'follow', user: 'zora', text: 'est abonné(e) à vos Épingles', time_ago: '03/26' },
];

export const NOTIFICATIONS = [
  {
    id: 'notif_01',
    text: 'Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Bord de mer.',
    query: 'bord de mer',
    time_ago: '07/26',
    icon: 'search',
  },
  {
    id: 'notif_02',
    text: 'Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Setup bureau.',
    query: 'setup',
    time_ago: '07/26',
    icon: 'search',
  },
  {
    id: 'notif_03',
    text: 'De nouvelles Épingles associées à Montagne ont été publiées.',
    query: 'montagne',
    time_ago: '06/26',
    image_url: '/pins/29.jpg',
  },
  {
    id: 'notif_04',
    text: 'Idées pour vous : Fond d’écran nature.',
    query: 'fond d’écran',
    time_ago: '05/26',
    image_url: '/pins/81.jpg',
  },
];

export const CONVERSATIONS = [
  {
    id: 'conv_camille',
    with_user: { name: 'Camille Durand', username: 'camille_design', avatar_url: '/pins/65.jpg' },
    last_message: 'Super ton tableau Bord de mer !',
    time_ago: '3 j',
    messages: [
      { from: 'them', text: 'Salut Jaye, tu as vu les nouvelles photos de Santorin ?', time: '14:20' },
      { from: 'me', text: 'Oui, magnifiques ! Je les ai enregistrées.', time: '14:22' },
      { from: 'them', text: 'Super ton tableau Bord de mer !', time: '14:25' },
    ],
  },
];

export const DEFAULT_COMMENTS = [
  { id: 'c1', author: 'Léa Martin', username: 'lea.martin', avatar_url: '/pins/64.jpg', text: 'J’adore la lumière sur cette photo !', time_ago: '2 j' },
  { id: 'c2', author: 'Hugo Lefèvre', username: 'hugo.lfv', avatar_url: '/pins/129.jpg', text: 'Très inspirant, merci pour le partage.', time_ago: '5 h' },
];
