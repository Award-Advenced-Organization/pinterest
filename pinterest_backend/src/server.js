import express from 'express';
import cors from 'cors';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import {
  CURRENT_USER,
  CREATORS,
  OTHER_USERS,
  INITIAL_SAVED,
  CLUSTERS,
  SEARCH_IDEAS,
  ACTIVITY,
  NOTIFICATIONS,
  CONVERSATIONS,
  DEFAULT_COMMENTS,
  creatorFor,
  generateInitialPins,
} from './data.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const UPLOADS_DIR = path.join(PUBLIC_DIR, 'uploads');
fs.mkdirSync(UPLOADS_DIR, { recursive: true });

const app = express();
const PORT = process.env.PORT || 3018;

app.use(cors());
app.use(express.json());
app.use(express.static(PUBLIC_DIR));

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOADS_DIR),
  filename: (req, file, cb) => cb(null, `up_${Date.now()}${path.extname(file.originalname) || '.jpg'}`),
});
const upload = multer({ storage, limits: { fileSize: 15 * 1024 * 1024 } });

// --- État persistant (db.json) ---
const DB_FILE = path.join(__dirname, '..', 'db.json');
const DB_VERSION = 2;

function defaultState() {
  return {
    version: DB_VERSION,
    user: { ...CURRENT_USER },
    boards: [], // { id, name, secret, description, pin_ids, created_at }
    savedPinIds: [...INITIAL_SAVED],
    createdPins: [],
    hiddenPinIds: [],
    likedPinIds: [],
    followedUsers: ['camille_design', 'lea.martin'],
    pinComments: {},
    conversations: structuredClone(CONVERSATIONS),
    dismissedNotifications: [],
    dismissedClusters: [],
  };
}

let state = defaultState();

function loadState() {
  if (!fs.existsSync(DB_FILE)) return;
  try {
    const s = JSON.parse(fs.readFileSync(DB_FILE, 'utf-8'));
    if (s.version !== DB_VERSION) {
      // Ancien format : on le met de côté et on repart proprement.
      fs.renameSync(DB_FILE, DB_FILE.replace('.json', `.v${s.version ?? 1}.backup.json`));
      console.log('💾 Ancien db.json sauvegardé, nouvel état créé.');
      return;
    }
    state = { ...defaultState(), ...s, user: { ...CURRENT_USER, ...s.user } };
    console.log('💾 État restauré depuis db.json');
  } catch (e) {
    console.warn('⚠️  Lecture db.json impossible, démarrage avec les valeurs par défaut.', e.message);
  }
}

function saveState() {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(state, null, 2));
  } catch (e) {
    console.warn('⚠️  Sauvegarde db.json impossible.', e.message);
  }
}

loadState();

const generatedPins = generateInitialPins();
const allPins = () => [...state.createdPins, ...generatedPins];
const findPin = (id) => allPins().find((p) => p.id === id);
const has = (list, v) => list.includes(v);
const addOnce = (list, v) => (list.includes(v) ? list : [...list, v]);
const without = (list, v) => list.filter((x) => x !== v);

const norm = (s) =>
  (s ?? '')
    .toString()
    .toLowerCase()
    .replace(/[’']/g, ' ')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '');

function boardOf(pinId) {
  return state.boards.find((b) => b.pin_ids.includes(pinId));
}

function pinOut(p) {
  const liked = has(state.likedPinIds, p.id);
  return {
    ...p,
    is_saved: has(state.savedPinIds, p.id),
    board_id: boardOf(p.id)?.id ?? null,
    liked,
    like_count: (p.like_count ?? 0) + (liked ? 1 : 0),
    comment_count: commentsOf(p.id).length,
  };
}

function commentsOf(pinId) {
  if (state.pinComments[pinId]) return state.pinComments[pinId];
  const isMine = state.createdPins.some((p) => p.id === pinId);
  const n = parseInt(pinId.replace(/\D/g, ''), 10) || 0;
  return !isMine && n % 3 === 0 ? DEFAULT_COMMENTS : [];
}

function boardOut(b) {
  const pins = b.pin_ids.map(findPin).filter(Boolean);
  return {
    id: b.id,
    name: b.name,
    secret: b.secret,
    description: b.description ?? '',
    pin_count: pins.length,
    cover_images: pins.slice(0, 3).map((p) => p.image_url),
    created_at: b.created_at,
  };
}

function userOut() {
  const u = state.user;
  return {
    ...u,
    following_count: state.followedUsers.length,
    created_pins_count: state.createdPins.length,
    saved_pins_count: state.savedPinIds.length,
    boards_count: state.boards.length,
  };
}

function directory() {
  const creators = CREATORS.map((c, i) => ({ ...creatorFor(i), name: c.name }));
  const fromConvs = state.conversations.map((c) => ({ ...c.with_user, id: `usr_${c.with_user.username}` }));
  const all = [...creators, ...OTHER_USERS, ...fromConvs];
  const seen = new Set();
  return all.filter((u) => (seen.has(u.username) ? false : seen.add(u.username)));
}

function findUser(username) {
  return directory().find((u) => u.username === username);
}

const isMe = (username) => username === 'me' || username === state.user.username;

// --- Fil d'accueil ---
app.get('/v3/feeds/home/', (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const pageSize = parseInt(req.query.page_size) || 20;
  const pins = allPins().filter((p) => !has(state.hiddenPinIds, p.id));
  const start = (page - 1) * pageSize;
  res.json({
    status: 'success',
    bookmark: start + pageSize < pins.length ? String(page + 1) : null,
    data: pins.slice(start, start + pageSize).map(pinOut),
    total: pins.length,
  });
});

// --- Épingles ---
app.get('/v3/pins/:id/', (req, res) => {
  const pin = findPin(req.params.id);
  if (!pin) return res.status(404).json({ error: 'Pin not found' });
  const tags = new Set(pin.tags ?? []);
  const related = allPins()
    .filter((p) => p.id !== pin.id && !has(state.hiddenPinIds, p.id))
    .map((p) => ({ p, score: (p.category === pin.category ? 2 : 0) + (p.tags ?? []).filter((t) => tags.has(t)).length }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 20)
    .map(({ p }) => pinOut(p));
  res.json({
    status: 'success',
    data: {
      ...pinOut(pin),
      is_mine: state.createdPins.some((p) => p.id === pin.id),
      is_following: has(state.followedUsers, pin.creator?.username),
      comments: commentsOf(pin.id),
      related_pins: related,
    },
  });
});

app.delete('/v3/pins/:id/', (req, res) => {
  const { id } = req.params;
  if (!state.createdPins.some((p) => p.id === id)) return res.status(403).json({ error: 'Not your pin' });
  state.createdPins = state.createdPins.filter((p) => p.id !== id);
  state.savedPinIds = without(state.savedPinIds, id);
  state.boards.forEach((b) => (b.pin_ids = without(b.pin_ids, id)));
  saveState();
  res.json({ status: 'success' });
});

app.post('/v3/pins/:id/comments/', (req, res) => {
  const { id } = req.params;
  const text = (req.body.text || '').trim();
  if (!text) return res.status(400).json({ error: 'Comment text required' });
  const comment = {
    id: `c_${Date.now()}`,
    author: state.user.full_name,
    username: state.user.username,
    avatar_url: state.user.avatar_url,
    text,
    time_ago: 'À l’instant',
    mine: true,
  };
  state.pinComments[id] = [...commentsOf(id), comment];
  saveState();
  res.status(201).json({ status: 'success', data: comment, comment_count: state.pinComments[id].length });
});

// Enregistrer (dans un tableau, ou dans « Idées non organisées » sans board_id)
app.post('/v3/pins/:id/save/', (req, res) => {
  const { id } = req.params;
  if (!findPin(id)) return res.status(404).json({ error: 'Pin not found' });
  const boardId = req.body?.board_id ?? null;
  state.savedPinIds = addOnce(state.savedPinIds, id);
  state.boards.forEach((b) => (b.pin_ids = without(b.pin_ids, id)));
  const board = boardId ? state.boards.find((b) => b.id === boardId) : null;
  if (board) board.pin_ids.unshift(id);
  saveState();
  res.json({ status: 'success', is_saved: true, board_id: board?.id ?? null, board_name: board?.name ?? null });
});

app.delete('/v3/pins/:id/save/', (req, res) => {
  const { id } = req.params;
  state.savedPinIds = without(state.savedPinIds, id);
  state.boards.forEach((b) => (b.pin_ids = without(b.pin_ids, id)));
  saveState();
  res.json({ status: 'success', is_saved: false });
});

app.post('/v3/pins/:id/like/', (req, res) => {
  const { id } = req.params;
  const pin = findPin(id);
  if (!pin) return res.status(404).json({ error: 'Pin not found' });
  state.likedPinIds = has(state.likedPinIds, id) ? without(state.likedPinIds, id) : [...state.likedPinIds, id];
  saveState();
  const out = pinOut(pin);
  res.json({ status: 'success', liked: out.liked, like_count: out.like_count });
});

app.post('/v3/pins/:id/hide/', (req, res) => {
  state.hiddenPinIds = addOnce(state.hiddenPinIds, req.params.id);
  saveState();
  res.json({ status: 'success', hidden: true });
});

app.delete('/v3/pins/:id/hide/', (req, res) => {
  state.hiddenPinIds = without(state.hiddenPinIds, req.params.id);
  saveState();
  res.json({ status: 'success', hidden: false });
});

// Créer une Épingle (fichier envoyé ou image existante)
app.post('/v3/pins/', upload.single('image'), (req, res) => {
  const { title, description, link, board_id } = req.body;
  let imageUrl = req.body.image_url || null;
  if (req.file) imageUrl = `/uploads/${req.file.filename}`;
  if (!imageUrl) return res.status(400).json({ error: 'Image required' });

  let collage;
  try {
    collage = req.body.collage_images ? JSON.parse(req.body.collage_images) : undefined;
  } catch (_) {
    collage = undefined;
  }
  const width = parseInt(req.body.width) || 736;
  const height = parseInt(req.body.height) || 980;
  const u = state.user;
  const pin = {
    id: `pin_user_${Date.now()}`,
    title: (title || '').trim(),
    description: (description || '').trim(),
    tags: [],
    link: link || undefined,
    image_url: imageUrl,
    collage_images: Array.isArray(collage) && collage.length > 1 ? collage : undefined,
    width,
    height,
    aspect_ratio: width / height,
    dominant_color: req.body.dominant_color || '#d9d9d4',
    category: 'perso',
    creator: { id: u.id, name: u.full_name, username: u.username, avatar_url: u.avatar_url },
    repin_count: 0,
    like_count: 0,
    created_at: new Date().toISOString(),
  };
  state.createdPins.unshift(pin);
  state.savedPinIds = addOnce(state.savedPinIds, pin.id);
  const board = board_id ? state.boards.find((b) => b.id === board_id) : null;
  if (board) board.pin_ids.unshift(pin.id);
  saveState();
  res.status(201).json({ status: 'success', data: pinOut(pin) });
});

// --- Recherche ---
app.get('/v3/search/', (req, res) => {
  const words = norm(req.query.q).split(/\s+/).filter((w) => w.length > 1);
  const category = norm(req.query.category);
  let results = allPins().filter((p) => !has(state.hiddenPinIds, p.id));
  if (category) results = results.filter((p) => norm(p.category) === category);
  if (words.length) {
    results = results.filter((p) => {
      const hay = norm([p.title, p.category, (p.tags ?? []).join(' '), p.creator?.name].join(' '));
      return words.every((w) => hay.includes(w));
    });
  }
  res.json({ status: 'success', query: req.query.q ?? '', count: results.length, data: results.map(pinOut) });
});

app.get('/v3/search/visual/', (req, res) => {
  const hex = (req.query.color || '').replace('#', '');
  if (!/^[0-9a-f]{6}$/i.test(hex)) return res.status(400).json({ error: 'color=#rrggbb required' });
  const rgb = (h) => [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16));
  const target = rgb(hex);
  const dist = (p) => {
    const c = rgb((p.dominant_color || '#000000').replace('#', ''));
    return c.reduce((s, v, i) => s + (v - target[i]) ** 2, 0);
  };
  const results = allPins()
    .filter((p) => !has(state.hiddenPinIds, p.id))
    .sort((a, b) => dist(a) - dist(b))
    .slice(0, 30);
  res.json({ status: 'success', count: results.length, data: results.map(pinOut) });
});

app.get('/v3/search/ideas/', (req, res) => {
  res.json({ status: 'success', data: SEARCH_IDEAS });
});

// --- Utilisateurs ---
app.get('/v3/users/', (req, res) => {
  const q = norm(req.query.q);
  const users = directory()
    .filter((u) => !q || norm(u.name).includes(q) || norm(u.username).includes(q))
    .map((u) => ({ ...u, is_following: has(state.followedUsers, u.username) }));
  res.json({ status: 'success', data: users });
});

app.get('/v3/users/:username/', (req, res) => {
  const { username } = req.params;
  if (isMe(username)) return res.json({ status: 'success', data: userOut() });
  const u = findUser(username);
  if (!u) return res.status(404).json({ error: 'User not found' });
  const pins = generatedPins.filter((p) => p.creator.username === username);
  const seed = username.length * 37;
  res.json({
    status: 'success',
    data: {
      id: u.id,
      username: u.username,
      full_name: u.name,
      avatar_url: u.avatar_url,
      bio: '',
      website: '',
      follower_count: 120 + (seed % 900) + (has(state.followedUsers, username) ? 1 : 0),
      following_count: 20 + (seed % 80),
      is_following: has(state.followedUsers, username),
      created_pins_count: pins.length,
    },
  });
});

app.patch('/v3/users/me/', (req, res) => {
  const allowed = ['full_name', 'username', 'website', 'bio', 'pronouns', 'email', 'phone', 'country_code', 'appearance'];
  const patch = Object.fromEntries(Object.entries(req.body ?? {}).filter(([k]) => allowed.includes(k)));
  if (patch.username !== undefined) {
    patch.username = String(patch.username).trim().toLowerCase();
    if (!/^[a-z0-9._]{3,30}$/.test(patch.username)) {
      return res.status(400).json({ error: 'Nom d’utilisateur invalide (3 à 30 caractères : lettres, chiffres, point, tiret bas).' });
    }
  }
  if (patch.full_name !== undefined && !String(patch.full_name).trim()) {
    return res.status(400).json({ error: 'Le nom ne peut pas être vide.' });
  }
  state.user = { ...state.user, ...patch };
  syncMyCreatorInfo();
  saveState();
  res.json({ status: 'success', data: userOut() });
});

app.post('/v3/users/me/avatar/', upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Image required' });
  state.user.avatar_url = `/uploads/${req.file.filename}`;
  syncMyCreatorInfo();
  saveState();
  res.json({ status: 'success', data: userOut() });
});

function syncMyCreatorInfo() {
  const u = state.user;
  state.createdPins.forEach((p) => {
    p.creator = { id: u.id, name: u.full_name, username: u.username, avatar_url: u.avatar_url };
  });
}

app.post('/v3/users/:username/follow/', (req, res) => {
  const { username } = req.params;
  const following = has(state.followedUsers, username);
  state.followedUsers = following ? without(state.followedUsers, username) : [...state.followedUsers, username];
  saveState();
  res.json({ status: 'success', is_following: !following, following_count: state.followedUsers.length });
});

app.get('/v3/users/:username/pins/created/', (req, res) => {
  const { username } = req.params;
  const pins = isMe(username) ? state.createdPins : generatedPins.filter((p) => p.creator.username === username);
  res.json({ status: 'success', data: pins.map(pinOut) });
});

app.get('/v3/users/:username/pins/saved/', (req, res) => {
  const unorganized = req.query.unorganized === '1';
  const ids = state.savedPinIds.filter((id) => !unorganized || !boardOf(id));
  const pins = ids.map(findPin).filter(Boolean).reverse();
  res.json({ status: 'success', data: pins.map(pinOut) });
});

app.get('/v3/users/:username/boards/', (req, res) => {
  res.json({ status: 'success', data: state.boards.map(boardOut) });
});

function clusterPins(c) {
  return state.savedPinIds
    .filter((id) => !boardOf(id))
    .map(findPin)
    .filter((p) => p && (c.category ? p.category === c.category : (p.tags ?? []).includes(c.tag)));
}

app.get('/v3/users/me/clusters/', (req, res) => {
  const data = CLUSTERS.filter((c) => !has(state.dismissedClusters, c.id))
    .map((c) => ({ c, pins: clusterPins(c) }))
    .filter(({ pins }) => pins.length >= 3)
    .map(({ c, pins }) => ({
      id: c.id,
      name: c.name,
      pin_count: pins.length,
      cover_images: pins.slice(0, 3).map((p) => p.image_url),
    }));
  res.json({ status: 'success', data });
});

app.post('/v3/users/me/clusters/:id/create/', (req, res) => {
  const c = CLUSTERS.find((x) => x.id === req.params.id);
  if (!c) return res.status(404).json({ error: 'Cluster not found' });
  const board = {
    id: `board_${Date.now()}`,
    name: c.name,
    secret: false,
    description: '',
    pin_ids: clusterPins(c).map((p) => p.id),
    created_at: new Date().toISOString(),
  };
  state.boards.push(board);
  state.dismissedClusters = addOnce(state.dismissedClusters, c.id);
  saveState();
  res.status(201).json({ status: 'success', data: boardOut(board) });
});

// --- Tableaux ---
app.post('/v3/boards/', (req, res) => {
  const name = (req.body?.name || '').trim();
  if (!name) return res.status(400).json({ error: 'Le nom du tableau est obligatoire.' });
  if (state.boards.some((b) => norm(b.name) === norm(name))) {
    return res.status(409).json({ error: 'Vous avez déjà un tableau portant ce nom.' });
  }
  const board = {
    id: `board_${Date.now()}`,
    name,
    secret: Boolean(req.body.secret),
    description: '',
    pin_ids: [],
    created_at: new Date().toISOString(),
  };
  state.boards.push(board);
  saveState();
  res.status(201).json({ status: 'success', data: boardOut(board) });
});

app.get('/v3/boards/:id/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  res.json({ status: 'success', data: boardOut(b) });
});

app.patch('/v3/boards/:id/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  if (req.body.name !== undefined) {
    const name = String(req.body.name).trim();
    if (!name) return res.status(400).json({ error: 'Le nom du tableau est obligatoire.' });
    b.name = name;
  }
  if (req.body.secret !== undefined) b.secret = Boolean(req.body.secret);
  if (req.body.description !== undefined) b.description = String(req.body.description);
  saveState();
  res.json({ status: 'success', data: boardOut(b) });
});

app.delete('/v3/boards/:id/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  // Comme sur Pinterest : supprimer un tableau supprime aussi ses Épingles enregistrées.
  state.savedPinIds = state.savedPinIds.filter((id) => !b.pin_ids.includes(id));
  state.boards = state.boards.filter((x) => x.id !== b.id);
  saveState();
  res.json({ status: 'success' });
});

app.get('/v3/boards/:id/pins/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  res.json({ status: 'success', data: b.pin_ids.map(findPin).filter(Boolean).map(pinOut) });
});

app.post('/v3/boards/:id/pins/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  const ids = (req.body?.pin_ids ?? []).filter((id) => findPin(id));
  state.boards.forEach((x) => (x.pin_ids = x.pin_ids.filter((id) => !ids.includes(id))));
  b.pin_ids = [...ids, ...b.pin_ids];
  ids.forEach((id) => (state.savedPinIds = addOnce(state.savedPinIds, id)));
  saveState();
  res.json({ status: 'success', data: boardOut(b) });
});

app.delete('/v3/boards/:id/pins/:pinId/', (req, res) => {
  const b = state.boards.find((x) => x.id === req.params.id);
  if (!b) return res.status(404).json({ error: 'Board not found' });
  b.pin_ids = without(b.pin_ids, req.params.pinId);
  saveState();
  res.json({ status: 'success', data: boardOut(b) });
});

// --- Boîte de réception ---
app.get('/v3/activity/', (req, res) => {
  const data = ACTIVITY.map((a) => {
    const u = findUser(a.user) ?? { username: a.user, name: a.user, avatar_url: '' };
    return { ...a, user: { ...u, is_following: has(state.followedUsers, u.username) } };
  });
  res.json({ status: 'success', data });
});

app.get('/v3/notifications/', (req, res) => {
  res.json({ status: 'success', data: NOTIFICATIONS.filter((n) => !has(state.dismissedNotifications, n.id)) });
});

app.delete('/v3/notifications/:id/', (req, res) => {
  state.dismissedNotifications = addOnce(state.dismissedNotifications, req.params.id);
  saveState();
  res.json({ status: 'success' });
});

app.get('/v3/conversations/', (req, res) => {
  res.json({ status: 'success', data: state.conversations });
});

app.post('/v3/conversations/', (req, res) => {
  const username = (req.body?.username || '').trim();
  const u = findUser(username);
  if (!u) return res.status(404).json({ error: 'User not found' });
  let conv = state.conversations.find((c) => c.with_user.username === username);
  if (!conv) {
    conv = {
      id: `conv_${username.replace(/[^a-z0-9]/gi, '_')}`,
      with_user: { name: u.name, username: u.username, avatar_url: u.avatar_url },
      last_message: '',
      time_ago: '',
      messages: [],
    };
    state.conversations.unshift(conv);
    saveState();
  }
  res.status(201).json({ status: 'success', data: conv });
});

app.post('/v3/conversations/:id/messages/', (req, res) => {
  const conv = state.conversations.find((c) => c.id === req.params.id);
  if (!conv) return res.status(404).json({ error: 'Conversation not found' });
  const text = (req.body?.text || '').trim();
  const pin = req.body?.pin_id ? findPin(req.body.pin_id) : null;
  if (!text && !pin) return res.status(400).json({ error: 'Message text required' });
  const msg = {
    from: 'me',
    text,
    time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    ...(pin ? { pin_id: pin.id, pin_image: pin.image_url } : {}),
  };
  conv.messages.push(msg);
  conv.last_message = text || 'A envoyé une Épingle';
  conv.time_ago = 'À l’instant';
  // La conversation la plus récente remonte en haut de la liste.
  state.conversations = [conv, ...state.conversations.filter((c) => c !== conv)];
  saveState();
  res.status(201).json({ status: 'success', data: msg });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'pinterest-api-backend',
    version: '2.0.0',
    total_pins: allPins().length,
    active_user: state.user.username,
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Pinterest Backend API running on http://localhost:${PORT}`);
});
