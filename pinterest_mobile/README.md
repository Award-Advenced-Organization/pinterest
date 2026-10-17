# Pinterest Mobile (Flutter) : Reproduction Pixel-Perfect

<p align="center">
  <img src="assets/images/avatar_jaye.jpg" width="80" height="80" style="border-radius: 50%;" alt="Jaye ahf Avatar" />
</p>

<p align="center">
  <strong>Application Mobile Pinterest officielle (Android & iOS) reproduite en Flutter.</strong><br>
  Basée sur la décompilation de l'APK officiel (v14.40.0) et la session réelle de l'utilisateur.
</p>

---

## 📱 Vues & Fonctionnalités Implémentées

### 1. 🏠 Accueil (Home Feed)
- **Barre supérieure avec logo Pinterest officiel** et sélection de chips horizontaux (*Pour vous*, *Tout*, *Dev Web*, *Design*, *Tech*, *Nature*, etc.).
- **Grille Masonry Staggered 2 colonnes** avec calcul dynamique des ratios d'aspect des images.
- **Menu tactile contextuel au Long-Press** : Enregistrer, Partager, Masquer.
- **Hero Animation fluide** vers le détail de l'épingle.

### 2. 🔍 Recherche & Découverte
- Barre de recherche avec **icône caméra de recherche visuelle**.
- Filtres thématiques interactifs et suggestions de tendances.
- Exploration en direct connectée au backend.

### 3. ➕ Outil de Création d'Épingle (Create Pin)
- Sélecteur de visuel avec aperçu instantané.
- Saisie du titre, de la description détaillée et du lien externe.
- Sélecteur déroulant de tableaux existants.
- Publication en temps réel via l'API REST `POST /v3/pins/`.

### 4. 💬 Boîte de Réception (Inbox)
- Onglet double : **Mises à jour** (Notifications réelles avec vignettes 48×48 et horodatages) et **Messages**.
- Illustration vectorielle authentique de la bouteille à la mer et texte d'invitation *« Lancer une conversation »*.

### 5. 👤 Profil Utilisateur (`Jaye ahf` / `@ahiffent`)
- Grand avatar circulaire 120dp.
- Nom `Jaye ahf`, identifiant `@ahiffent`, compteurs `1 abonné · 2 abonnements`, lien `🌐 ahiffonjephte.me`.
- Bouton arrondi `Modifier le profil`.
- Onglets centrés **Créées** (avec l'épingle réelle *« Suis moi et ensemble apprenons le développement web »*) et **Enregistrées** (avec les clusters de tableaux et inspiration).
- Bouton d'action rouge pill flottant **Créer** en bas à droite.

### 6. 🔎 Vue Détaillée d'Épingle (Pin Detail)
- Zoom interactif tactile via `InteractiveViewer`.
- Bouton rouge officiel `Enregistrer`.
- Informations complètes du créateur, bouton `S'abonner`.
- Section commentaires et grille de suggestions *« Plus d'idées similaires »*.

---

## 🛠️ Stack Technique

- **Framework** : [Flutter SDK](https://flutter.dev/) (Material 3 + Gestalt Design Tokens)
- **Grille Masonry** : `flutter_staggered_grid_view`
- **Cache d'images** : `cached_network_image`
- **Typographie** : `google_fonts` (Inter Tight)
- **Client HTTP** : `http` connecté au backend REST `http://localhost:3018`

---

## 🚀 Lancement

```bash
# 1. Démarrer le backend (dans pinterest_backend)
cd ../pinterest_backend
npm install
node src/server.js

# 2. Lancer l'application Flutter
cd ../pinterest_mobile
flutter pub get
flutter run
```
