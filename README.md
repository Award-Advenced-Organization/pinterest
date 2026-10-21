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
├── pinterest_api/             # API REST Laravel 13 (port 3018), backend actuel
│   ├── app/Http/Controllers/  # Fil, Épingles, recherche, profils, tableaux, boîte de réception, images
│   ├── app/Http/Resources/    # Format JSON attendu par l'application
│   ├── app/Models/            # Modèles Eloquent (Pin, Board, User, Conversation…)
│   ├── database/              # Migrations et données de départ (seeders/data/pinterest.json)
│   ├── storage/app/media/     # Images du fil (pins/) et envois de l'application (uploads/)
│   └── tests/Feature/         # Tests Pest de toutes les routes
│
├── pinterest_backend/         # Ancien backend Express, remplacé par pinterest_api
│
└── reference_screenshots/     # 11 captures d'écran réelles du smartphone
```

---

## 1. Lancer le Backend API (Port 3018)

Prérequis : PHP 8.3 ou plus et Composer (sous Windows, la commande `php.new` de la documentation Laravel installe les deux).

```powershell
cd pinterest_api
composer setup     # dépendances, .env, base SQLite et données de départ
composer serve     # http://localhost:3018, accessible aussi depuis le téléphone sur le Wi-Fi
```

Les adresses (`/v3/…`) et le format JSON sont identiques à l'ancien backend : l'application n'a rien à changer.
Pour repartir des données de départ : `php artisan migrate:fresh --seed`. Tests : `php artisan test`.

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

## Fonctionnalités

Interface calibrée sur les 11 captures de `reference_screenshots/`, en mode clair et en mode sombre (Profil > … > Apparence).
Les icônes sont un jeu original à trait fin dessiné dans le style des captures (`lib/core/widgets/pin_icon.dart`) ; le logo Pinterest n'est pas reproduit.

1. **Accueil** : grille en mosaïque aux vraies proportions des images, couleur dominante pendant le chargement, chargement continu,
   onglets « Tout » + vos tableaux, carrousels balayables, menu « … » et menu circulaire à l'appui long (Enregistrer, Partager, Masquer).
2. **Épingle** : image pleine largeur, J'aime, commentaires, partage, Enregistrer (puis choix du tableau), abonnement au créateur,
   lien « Visiter », Épingles similaires, suppression de ses propres Épingles.
3. **Rechercher** : recherche par mots-clés (titres, mots-clés, catégories, créateurs), recherches récentes,
   recherche par image (Épingles de couleur proche de la photo choisie).
4. **Créer** : Épingle (image de l'appareil, titre, description, lien, tableau), Tableau (public ou secret), Collage (2 à 4 Épingles).
5. **Boîte de réception** : activité (s'abonner, saluer), messagerie avec envoi d'Épingles, nouveau message, mises à jour masquables.
6. **Profil** : Créées, Enregistrées (tableaux, regroupements proposés à transformer en tableaux, « Organiser » pour ranger),
   page de tableau (modifier, rendre secret, supprimer), modifier le profil et la photo, statistiques (période au choix).

Toutes les actions sont enregistrées dans la base SQLite du backend (`pinterest_api/database/database.sqlite`).

---

## Notes

- **Windows / Android** : les extensions `image_picker` et `url_launcher` demandent le *Mode développeur* de Windows
  pour compiler l'application native (`start ms-settings:developers`). La version web n'en a pas besoin.
- **Adresse du serveur** : `--dart-define=API_URL=http://10.0.2.2:3018` pour l'émulateur Android, ou l'IP du PC pour un téléphone.
- **Captures** (version web) : `?theme=dark&tab=4&open=stats` ouvre directement un écran
  (`tab` 0 à 4 ; `open` = `pin:<id>`, `search:<mots>`, `stats`, `edit`, `create`, `board`, `collage`, `sheet`).
- **Tests** : `flutter test` dans `pinterest_mobile`.
