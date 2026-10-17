# Reproduction Pinterest Mobile (Flutter & Node.js API)

Reproduction pixel-perfect et fonctionnelle de l'application mobile officielle Pinterest Android, calibrée rigoureusement sur les captures d'écran réelles issues de l'application smartphone (session authentique Jaye ahf).

Conforme à la méthode GOD2 (réflexe 01 : calibrage sur la référence ; réflexe 12 : tout ce qui est sur la photo se fait ; zéro tiret cadratin).

---

## Architecture de la branche

```
.
├── pinterest_mobile/          # Application mobile Flutter
│   ├── lib/
│   │   ├── core/              # Thème Gestalt, widgets réutilisables (PinCard, etc.)
│   │   ├── models/            # Modèles de données (Pin, User, Board, etc.)
│   │   ├── screens/           # Écrans (Accueil, Recherche, Créer, Boîte de réception, Profil, Stats)
│   │   └── services/          # Client API HTTP REST
│   └── pubspec.yaml
│
├── pinterest_backend/         # API REST compagnon Express (port 3018)
│   ├── src/
│   │   ├── server.js          # Serveur HTTP et endpoints REST v3
│   │   └── data.js            # Données réalistes et flux d'Épingles
│   └── package.json
│
└── reference_screenshots/     # 11 captures d'écran réelles du smartphone
```

---

## 1. Lancer le Backend API (Port 3018)

```powershell
cd pinterest_backend
npm install
node src/server.js
```

Le serveur écoute sur `http://localhost:3018`.

---

## 2. Lancer l'Application Mobile Flutter

### Sur Web (Chrome) :
```powershell
cd pinterest_mobile
flutter pub get
flutter run -d chrome
```

### Sur Android (Appareil physique ou émulateur) :
```powershell
cd pinterest_mobile
flutter pub get
flutter run
```

### Compiler l'APK Android release :
```powershell
cd pinterest_mobile
flutter build apk --release
```

---

## Fonctionnalités reproduites à l'identique

1. **Accueil (Flux Masonry)** :
   - Grille échelonnée 2 colonnes avec badges vidéo (`0:22`) et icône muet.
   - Carrousels multi-images avec indicateurs `• • • • ·`.
   - Bouton contextuel `...` et menu d'actions (Enregistrer, Partager, Masquer).

2. **Rechercher** :
   - Barre de recherche avec caméra visuelle.
   - 8 tuiles de « Des idées pour vous » conformes aux captures.
   - 4 tuiles de « Populaire sur Pinterest ».

3. **Créer (`+`)** :
   - Feuille modale « Laissez libre cours à votre créativité dès maintenant ».
   - Boutons Épingle, Collage et Tableau.

4. **Boîte de réception** :
   - Sections Activité (Alassanemomo, Zora), Messages et Mises à jour.

5. **Profil & Sous-écrans** :
   - En-tête profil réel (Jaye ahf, @ahiffent, 1 abonné(e) · 2 abonné(e)s, ahiffonjephte.me).
   - Onglet Créées avec tuile vidéo `0:07`.
   - Onglet Enregistrées avec recherche, carrousel de clusters et idées non organisées.
   - Hub des créateurs / Statistiques (Performances globales, 30 derniers jours).
   - Modifier le profil avec champs bordés et gestion de l'avatar.
