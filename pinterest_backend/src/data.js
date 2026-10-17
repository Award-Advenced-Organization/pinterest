export const CURRENT_USER = {
  id: 'usr_jaye_ahf_01',
  username: 'ahiffent',
  full_name: 'Jaye ahf',
  avatar_url: '/avatar_jaye.jpg',
  bio: 'Designer & Creator · http://ahiffonjephte.me',
  website: 'http://ahiffonjephte.me',
  follower_count: 1,
  following_count: 2,
  is_verified: true,
  email: 'ahiffent@gmail.com',
};

export const INITIAL_BOARDS = [
  {
    id: 'board_toutes_les_epingles',
    name: 'Toutes les Épingles',
    secret: false,
    pin_count: 22,
    created_at: '2024-01-10T00:00:00Z',
    cover_images: ['/pins/10.jpg', '/pins/11.jpg', '/pins/12.jpg'],
  },
  {
    id: 'board_voyages_a_faire',
    name: 'Voyages à faire',
    secret: false,
    pin_count: 6,
    created_at: '2024-03-12T00:00:00Z',
    cover_images: ['/pins/13.jpg', '/pins/14.jpg', '/pins/15.jpg'],
  },
  {
    id: 'board_idees_deco',
    name: 'Idées déco',
    secret: false,
    pin_count: 5,
    created_at: '2024-04-05T00:00:00Z',
    cover_images: ['/pins/16.jpg', '/pins/17.jpg', '/pins/18.jpg'],
  },
  {
    id: 'board_recettes',
    name: 'Recettes',
    secret: false,
    pin_count: 4,
    created_at: '2024-05-18T00:00:00Z',
    cover_images: ['/pins/19.jpg', '/pins/20.jpg', '/pins/21.jpg'],
  },
  {
    id: 'board_inspiration_photo',
    name: 'Inspiration photo',
    secret: true,
    pin_count: 7,
    created_at: '2024-06-22T00:00:00Z',
    cover_images: ['/pins/22.jpg', '/pins/23.jpg', '/pins/24.jpg'],
  },
];

export const INITIAL_CREATED_PINS = [
  {
    id: 'pin_moi_video_01',
    title: 'Idée créative',
    description: 'Tutoriel court et astuces créatives.',
    link: 'https://ahiffonjephte.me',
    image_url: '/pins/10.jpg',
    width: 736,
    height: 736,
    aspect_ratio: 1.0,
    dominant_color: '#D3C8A2',
    category: 'tech',
    is_video: true,
    video_duration: '0:07',
    creator: {
      id: CURRENT_USER.id,
      name: CURRENT_USER.full_name,
      username: CURRENT_USER.username,
      avatar_url: CURRENT_USER.avatar_url,
    },
    repin_count: 42,
    reactions: { heart: 24, star: 18 },
    created_at: '2024-08-01T12:00:00Z',
  },
];

export const NOTIFICATIONS = [
  {
    id: 'notif_01',
    title: 'Site Motion Design.',
    description: "Vous n'avez pas encore trouvé ce qu'il vous faut ? Explorez les idées associées à Motion Design And 3d Website.",
    time_ago: '2 mois',
    image_url: '/pins/36.jpg',
    read: false,
  },
  {
    id: 'notif_02',
    title: 'Recherche suggérée',
    description: "Vous n'avez pas encore trouvé ce qu'il vous faut ? Explorez les idées associées à Image Developpement Web.",
    time_ago: '5 mois',
    icon: 'search',
    read: true,
  },
  {
    id: 'notif_03',
    title: 'Naruto guide',
    description: 'De nouvelles Épingles associées à Naruto guide ont été publiées.',
    time_ago: '7 mois',
    image_url: '/pins/56.jpg',
    read: true,
  },
  {
    id: 'notif_04',
    title: 'Vocabulaire guide',
    description: 'Une sélection pour enrichir vos tableaux.',
    time_ago: '7 mois',
    image_url: '/pins/24.jpg',
    read: true,
  },
  {
    id: 'notif_05',
    title: 'Vous méritez de tout avoir',
    description: 'Inspiration citations et mindset.',
    time_ago: '7 mois',
    image_url: '/pins/22.jpg',
    read: true,
  },
  {
    id: 'notif_06',
    title: 'One Piece guide',
    description: 'Idées recommandées pour vous.',
    time_ago: '7 mois',
    image_url: '/pins/82.jpg',
    read: true,
  },
];

export const CONVERSATIONS = [
  {
    id: 'conv_camille',
    with_user: {
      name: 'Camille',
      username: 'camille_design',
      avatar_url: '/pins/18.jpg',
    },
    last_message: 'Super ton tableau UI !',
    time_ago: '3 j',
    messages: [
      { from: 'them', text: 'Salut Jaye, tu as vu le nouveau design system ?', time: '14:20' },
      { from: 'me', text: 'Oui, magnifique ! Je vais faire des tests dessus.', time: '14:22' },
      { from: 'them', text: 'Super ton tableau UI !', time: '14:25' },
    ],
  },
];

// Generate 60 realistic pins from existing local photos
const PIN_TITLES = [
  'Café du matin sur table en bois',
  'Ponton paisible au crépuscule',
  'Allée brumeuse au matin',
  'Rayons de soleil dans les herbes',
  'Pommes de pin macro nature',
  'Marais sauvage sous ciel pastel',
  'Gouttes de pluie sur vitre',
  'Forêt de sapins silencieuse',
  'Création graphique moderne',
  'Poster typographique minimaliste',
  'Architecture grecque blanche et mer bleue',
  'Livre ouvert et lumière douce',
  'Citations inspirantes et mindset',
  'Guide UI et design system responsive',
  'Studio développeur minimaliste',
  'Illustration animée créative',
  'Portrait lumière naturelle et contraste',
  'Palette de couleurs terre cuite & sable',
];

const CATEGORIES = ['tech', 'design', 'nature', 'art', 'voyage', 'mode', 'lifestyle'];

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PINS_DIR = path.join(__dirname, '..', 'public', 'pins');

function getAvailablePinImages() {
  try {
    const files = fs.readdirSync(PINS_DIR)
      .filter((f) => f.endsWith('.jpg') || f.endsWith('.png'))
      .sort((a, b) => (parseInt(a) || 0) - (parseInt(b) || 0));
    return files.map((f) => `/pins/${f}`);
  } catch (_) {
    return [];
  }
}

export function generateInitialPins() {
  const pins = [];
  const availableImages = getAvailablePinImages();
  const pool = availableImages.length > 0
    ? availableImages
    : Array.from({ length: 60 }, (_, idx) => `/pins/${idx + 10}.jpg`);

  for (let i = 0; i < pool.length; i++) {
    const w = 736;
    const h = 800 + ((i * 137) % 650);
    const title = PIN_TITLES[i % PIN_TITLES.length] + (i >= PIN_TITLES.length ? ` #${i + 1}` : '');
    const category = CATEGORIES[i % CATEGORIES.length];
    const imagePath = pool[i];
    const avatarPath = pool[(i + 7) % pool.length];

    const isVid = i % 5 === 0;
    const isCar = !isVid && (i % 3 === 0);

    pins.push({
      id: `pin_${i + 1}`,
      title: i % 4 === 0 ? '' : title,
      description: `Inspiration visuelle Pinterest - collection ${category}. Découverte et partage d'idées créatives.`,
      link: i % 3 === 0 ? 'https://pinterest.com' : undefined,
      image_url: imagePath,
      width: w,
      height: h,
      aspect_ratio: w / h,
      dominant_color: i % 2 === 0 ? '#2c3e50' : '#dcdcd7',
      category,
      is_video: isVid,
      video_duration: isVid ? (i % 2 === 0 ? '0:22' : '0:15') : undefined,
      is_carousel: isCar,
      creator: {
        id: `creator_${(i % 10) + 1}`,
        name: `Créateur ${(i % 10) + 1}`,
        username: `createur_${(i % 10) + 1}`,
        avatar_url: avatarPath,
      },
      repin_count: ((i + 1) * 23) % 200 + 5,
      reactions: {
        heart: ((i + 1) * 17) % 80,
        star: ((i + 1) * 7) % 40,
      },
      created_at: new Date(Date.now() - (i + 1) * 3600 * 24 * 1000).toISOString(),
    });
  }
  return pins;
}
