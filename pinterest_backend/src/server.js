import express from 'express';
import cors from 'cors';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import {
  CURRENT_USER,
  INITIAL_BOARDS,
  INITIAL_CREATED_PINS,
  NOTIFICATIONS,
  CONVERSATIONS,
  generateInitialPins,
} from './data.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const UPLOADS_DIR = path.join(PUBLIC_DIR, 'uploads');
fs.makedirs ? null : (fs.existsSync(UPLOADS_DIR) || fs.mkdirSync(UPLOADS_DIR, { recursive: true }));

const app = express();
const PORT = process.env.PORT || 3018;

app.use(cors());
app.use(express.json());
app.use(express.static(PUBLIC_DIR));

// File storage for user created pins
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOADS_DIR),
  filename: (req, file, cb) => cb(null, `pin_${Date.now()}${path.extname(file.originalname)}`),
});
const upload = multer({ storage });

// --- Persistence (survives restarts) ---
const DB_FILE = path.join(__dirname, '..', 'db.json');

const DEFAULT_COMMENTS = [
  { id: 'c1', author: 'Léa M.', text: 'J’adore les couleurs et la composition !', time_ago: '2 j' },
  { id: 'c2', author: 'Alexandre', text: 'Très inspirant pour mon prochain projet.', time_ago: '5 h' },
];

// In-memory mutable state
let userBoards = [...INITIAL_BOARDS];
let savedPinIds = new Set(['pin_1', 'pin_2', 'pin_3', 'pin_4', 'pin_5', 'pin_6']);
let userCreatedPins = [...INITIAL_CREATED_PINS];
let conversations = [...CONVERSATIONS];
let followedUsers = new Set();          // usernames the current user follows
let pinComments = {};                   // pinId -> [comments]
let followerCount = CURRENT_USER.follower_count;
let followingCount = CURRENT_USER.following_count;

function loadState() {
  try {
    if (fs.existsSync(DB_FILE)) {
      const s = JSON.parse(fs.readFileSync(DB_FILE, 'utf-8'));
      userBoards = s.userBoards ?? userBoards;
      savedPinIds = new Set(s.savedPinIds ?? [...savedPinIds]);
      userCreatedPins = s.userCreatedPins ?? userCreatedPins;
      conversations = s.conversations ?? conversations;
      followedUsers = new Set(s.followedUsers ?? []);
      pinComments = s.pinComments ?? {};
      followerCount = s.followerCount ?? followerCount;
      followingCount = s.followingCount ?? followingCount;
      console.log('💾 État restauré depuis db.json');
    }
  } catch (e) {
    console.warn('⚠️  Lecture db.json impossible, démarrage avec les valeurs par défaut.', e.message);
  }
}

function saveState() {
  try {
    const s = {
      userBoards,
      savedPinIds: [...savedPinIds],
      userCreatedPins,
      conversations,
      followedUsers: [...followedUsers],
      pinComments,
      followerCount,
      followingCount,
    };
    fs.writeFileSync(DB_FILE, JSON.stringify(s, null, 2));
  } catch (e) {
    console.warn('⚠️  Sauvegarde db.json impossible.', e.message);
  }
}

loadState();

// allPins = épingles créées (persistées) + feed généré
let allPins = [...userCreatedPins, ...generateInitialPins()];

// --- Official Pinterest v3 API Endpoints ---

// 1. Home Feed
app.get('/v3/feeds/home/', (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const pageSize = parseInt(req.query.page_size) || 20;
  const startIndex = (page - 1) * pageSize;
  const pagedPins = allPins.slice(startIndex, startIndex + pageSize);

  res.json({
    status: 'success',
    bookmark: startIndex + pageSize < allPins.length ? String(page + 1) : null,
    data: pagedPins.map((p) => ({
      ...p,
      is_saved: savedPinIds.has(p.id),
    })),
    total: allPins.length,
  });
});

// 2. Pin Detail
app.get('/v3/pins/:id/', (req, res) => {
  const { id } = req.params;
  const pin = allPins.find((p) => p.id === id);
  if (!pin) {
    return res.status(404).json({ error: 'Pin not found' });
  }

  // Find related pins in the same category
  const relatedPins = allPins
    .filter((p) => p.id !== id && (p.category === pin.category || Math.random() > 0.5))
    .slice(0, 16);

  const comments = pinComments[id] ?? DEFAULT_COMMENTS;

  res.json({
    status: 'success',
    data: {
      ...pin,
      is_saved: savedPinIds.has(pin.id),
      is_following: followedUsers.has(pin.creator?.username),
      comments_count: comments.length,
      comments,
      related_pins: relatedPins,
    },
  });
});

// 2b. Add a comment to a pin
app.post('/v3/pins/:id/comments/', (req, res) => {
  const { id } = req.params;
  const text = (req.body.text || '').trim();
  if (!text) return res.status(400).json({ error: 'Comment text required' });

  const base = pinComments[id] ?? [...DEFAULT_COMMENTS];
  const newComment = {
    id: `c_${Date.now()}`,
    author: CURRENT_USER.full_name,
    username: CURRENT_USER.username,
    avatar_url: CURRENT_USER.avatar_url,
    text,
    time_ago: 'À l’instant',
    mine: true,
  };
  pinComments[id] = [...base, newComment];
  saveState();
  res.status(201).json({ status: 'success', data: newComment, comments_count: pinComments[id].length });
});

// 3. Save / Unsave Pin
app.post('/v3/pins/:id/save/', (req, res) => {
  const { id } = req.params;
  const boardId = req.body.board_id || 'board_toutes_les_epingles';

  if (savedPinIds.has(id)) {
    savedPinIds.delete(id);
    const board = userBoards.find((b) => b.id === boardId);
    if (board && board.pin_count > 0) board.pin_count--;
    saveState();
    return res.json({ status: 'success', is_saved: false, message: 'Épingle retirée de vos tableaux' });
  } else {
    savedPinIds.add(id);
    const board = userBoards.find((b) => b.id === boardId);
    if (board) board.pin_count++;
    saveState();
    return res.json({ status: 'success', is_saved: true, message: 'Épingle enregistrée !' });
  }
});

// 4. Create Pin (File upload or direct URL)
app.post('/v3/pins/', upload.single('image'), (req, res) => {
  const { title, description, link, category, board_id } = req.body;
  let imageUrl = '/pins/1.jpg';

  if (req.file) {
    imageUrl = `/uploads/${req.file.filename}`;
  } else if (req.body.image_url) {
    imageUrl = req.body.image_url;
  }

  const newPin = {
    id: `pin_user_${Date.now()}`,
    title: title || 'Sans titre',
    description: description || '',
    link: link || undefined,
    image_url: imageUrl,
    width: 736,
    height: 980,
    aspect_ratio: 736 / 980,
    dominant_color: '#e60023',
    category: category || 'general',
    creator: {
      id: CURRENT_USER.id,
      name: CURRENT_USER.full_name,
      username: CURRENT_USER.username,
      avatar_url: CURRENT_USER.avatar_url,
    },
    repin_count: 0,
    reactions: { heart: 0, star: 0 },
    created_at: new Date().toISOString(),
  };

  userCreatedPins.unshift(newPin);
  allPins.unshift(newPin);
  savedPinIds.add(newPin.id);

  const targetBoard = userBoards.find((b) => b.id === (board_id || 'board_toutes_les_epingles'));
  if (targetBoard) targetBoard.pin_count++;

  saveState();
  res.status(201).json({ status: 'success', data: newPin });
});

// 5. Search
app.get('/v3/search/', (req, res) => {
  const q = (req.query.q || '').trim().toLowerCase();
  const category = (req.query.category || '').toLowerCase();

  let results = allPins;
  if (category) {
    results = results.filter((p) => p.category.toLowerCase() === category);
  }
  if (q) {
    results = results.filter(
      (p) =>
        p.title.toLowerCase().includes(q) ||
        p.description.toLowerCase().includes(q) ||
        p.category.toLowerCase().includes(q)
    );
  }

  res.json({
    status: 'success',
    query: q,
    count: results.length,
    data: results.map((p) => ({
      ...p,
      is_saved: savedPinIds.has(p.id),
    })),
  });
});

// 6. User Profile
app.get('/v3/users/:username/', (req, res) => {
  const { username } = req.params;
  if (username === CURRENT_USER.username || username === 'me') {
    return res.json({
      status: 'success',
      data: {
        ...CURRENT_USER,
        follower_count: followerCount,
        following_count: followingCount,
        created_pins_count: userCreatedPins.length,
        saved_pins_count: savedPinIds.size,
        boards_count: userBoards.length,
      },
    });
  }

  // Mock creator
  res.json({
    status: 'success',
    data: {
      id: `usr_${username}`,
      username,
      full_name: username.replace('_', ' ').toUpperCase(),
      avatar_url: '/pins/10.jpg',
      bio: 'Créateur inspirant sur Pinterest.',
      follower_count: 1240,
      following_count: 42,
      is_following: followedUsers.has(username),
    },
  });
});

// 6b. Follow / Unfollow a user
app.post('/v3/users/:username/follow/', (req, res) => {
  const { username } = req.params;
  let isFollowing;
  if (followedUsers.has(username)) {
    followedUsers.delete(username);
    if (followingCount > 0) followingCount--;
    isFollowing = false;
  } else {
    followedUsers.add(username);
    followingCount++;
    isFollowing = true;
  }
  saveState();
  res.json({
    status: 'success',
    is_following: isFollowing,
    following_count: followingCount,
  });
});

// 7. User Created Pins
app.get('/v3/users/:username/pins/created/', (req, res) => {
  res.json({
    status: 'success',
    data: userCreatedPins.map((p) => ({ ...p, is_saved: savedPinIds.has(p.id) })),
  });
});

// 8. User Saved Boards
app.get('/v3/users/:username/boards/', (req, res) => {
  res.json({
    status: 'success',
    data: userBoards,
  });
});

// 9. Notifications
app.get('/v3/notifications/', (req, res) => {
  res.json({
    status: 'success',
    data: NOTIFICATIONS,
  });
});

// 10. Conversations & Messages
app.get('/v3/conversations/', (req, res) => {
  res.json({
    status: 'success',
    data: conversations,
  });
});

app.post('/v3/conversations/:id/messages/', (req, res) => {
  const { id } = req.params;
  const { text } = req.body;
  const conv = conversations.find((c) => c.id === id);
  if (!conv) {
    return res.status(404).json({ error: 'Conversation not found' });
  }

  const newMsg = {
    from: 'me',
    text: text.trim(),
    time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
  };
  conv.messages.push(newMsg);
  conv.last_message = newMsg.text;
  conv.time_ago = 'À l’instant';

  saveState();
  res.status(201).json({ status: 'success', data: newMsg });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'pinterest-api-backend',
    version: '1.0.0',
    total_pins: allPins.length,
    active_user: CURRENT_USER.username,
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Pinterest Backend API running on http://localhost:${PORT}`);
  console.log(`📡 Endpoints available: /v3/feeds/home/, /v3/pins/, /v3/search/, /v3/users/ahiffent/`);
});
