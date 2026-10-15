# Pinterest Web — Reproduction Pixel-Perfect

<p align="center">
  <img src="public/favicon.svg" width="72" height="72" alt="Pinterest Logo" />
</p>

<p align="center">
  <strong>Reproduction ultra-fidèle de l'interface officielle Pinterest (Web 2026).</strong><br>
  Basée sur une session authentique et une analyse vidéo image par image.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/React-18.3-61DAFB?logo=react&logoColor=black" alt="React" />
  <img src="https://img.shields.io/badge/TypeScript-5.6-3178C6?logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Vite-5.4-646CFF?logo=vite&logoColor=white" alt="Vite" />
  <img src="https://img.shields.io/badge/Design_System-Gestalt_Pinterest-E60023?logo=pinterest&logoColor=white" alt="Gestalt" />
  <img src="https://img.shields.io/badge/Organisation-Awward-FF5722" alt="Awward" />
</p>

---

## 🌟 Présentation

Ce projet reproduit avec une fidélité visuelle et comportementale chirurgicale l'interface web de **Pinterest**, calibrée sur une session utilisateur réelle (`Jaye ahf` / `@ahiffent`) et une capture vidéo frame par frame :

- **Tracés vectoriels SVG 100% authentiques** : extraction directe des composants d'icônes officiels Pinterest Gestalt (`logo`, `loupe`, `cloche`, `discussion`, `mégaphone`, `profil`, `chevron`, `croix`, `crayon`, `filtre`, etc.).
- **Aucune dépendance CSS lourde** : styles écrits en CSS Vanilla moderne, tokens de design Gestalt natifs, performances maximales et 60 FPS garantis.
- **Expérience interactive complète** : navigation fluide, filtres, onglets actifs, volets déroulants et création d'Épingles.

---

## 📸 Fonctionnalités & Vues Implémentées

### 1. Page d'Accueil Connectée (Home Feed)
- **Barre supérieure Gestalt** : logo calligraphique rouge, pastille `Page d'accueil ≡`, champ de recherche extensible avec icône appareil photo, pastille de profil capsule (`Jaye ahf / Profil de Jaye ahf ⌵`), 5 icônes d'actions (recherche, notifications, messages, activités sociales, profil et menu déroulant).
- **Onglet `All`** avec indicateur de soulignement noir dynamique.
- **Grille Masonry infinie** : cartes d'épingles avec survol fluide, boutons d'enregistrement rapide, options `...` et bouton flottant d'aide `?` en bas à droite.

### 2. Volet Notifications Réel
- Popover flottant accessible depuis la cloche avec badge de notification.
- Flux de recommandations réelles relevées sur la session utilisateur (`Site Motion Design.`, `Naruto guide`, `Vocabulaire guide`, `One Piece guide`, etc.).
- Vignettes de contenu au format 48×48 avec coins arrondis et horodatages (`2 mois`, `7 mois`).

### 3. Boîte de Réception (Messages)
- Panneau coulissant avec en-tête officiel `✕ Boîte de réception`.
- Bouton rouge `Nouveau message` avec icône stylet.
- Ligne d'invitation `Invitez vos amis`.
- Illustration vectorielle authentique de la bouteille à la mer et texte d'accueil *« Lancer une conversation »*.

### 4. Profil Utilisateur (`/ahiffent`)
- En-tête personnalisé avec titre `Pinterest ≡` et boutons d'actions carrés arrondis `[↑]` (partage) et `[+]` (création).
- Identité complète : grand avatar circulaire 120px (`/avatar_jaye.jpg`), nom `Jaye ahf`, pseudo `@ahiffent`, compteurs `1 abonné · 2 abonnements`, lien vérifié `🌐 ahiffonjephte.me`, et bouton gris arrondi `Modifier le profil`.
- Onglets centrés **Créées** et **Enregistrées** avec soulignement interactif.
- Barre d'outils avec icône filtre `⊶` et bouton rouge pill flottant **Créer** en bas à droite.
- **Onglet Créées** : affiche l'Épingle réelle *« Suis moi et ensemble apprenons le développement web »*.
- **Onglet Enregistrées** : section *« Gardez une trace de ce qui vous inspire »* et clusters de tableaux (`Toutes les Épingles`, `Voyages à faire`, `Idées déco`, `Recettes`, `Inspiration photo`).

### 5. Outil de Création d'Épingle (`/pin-creation-tool`)
- En-tête dédié `Créer ≡` avec bouton d'action rouge `Publier`.
- Zone de glisser-déposer d'images (.jpg, .png, .webp) avec aperçu immédiat et suppression.
- Formulaire complet : Titre, Description détaillée, Lien de destination et sélecteur de Tableau.

### 6. Landing Page Déconnectée
- Hero section : *« Créez la vie que vous aimez sur Pinterest »* avec call-to-actions rouge et gris.
- Bannière d'acceptation des cookies officielle avec options de personnalisation.
- Section découverte *« Plus d'idées gagnantes »* avec cartes visuelles multi-images et badges vérifiés.

---

## 🛠️ Stack Technique

- **Framework** : [React 18](https://react.dev/) + [Vite 5](https://vitejs.dev/)
- **Langage** : [TypeScript 5](https://www.typescriptlang.org/) (mode strict `noUnusedLocals`)
- **Routage** : [React Router DOM v6](https://reactrouter.com/)
- **Styles** : CSS Vanilla moderne (variables CSS, flexbox, CSS grid, media queries responsives)
- **Assets** : Tracés SVG officiels Pinterest Gestalt et visuels haute fidélité

---

## 🚀 Démarrage Rapide

### Prérequis
- [Node.js](https://nodejs.org/) (v18 ou supérieur recommandé)
- [npm](https://www.npmjs.com/) ou [pnpm](https://pnpm.io/)

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/Award-Advenced-Organization/pinterest.git

# Accéder au dossier
cd pinterest

# Installer les dépendances
npm install
```

### Développement

```bash
# Lancer le serveur de développement local
npm run dev
```

L'application sera accessible sur `http://localhost:3017/` (ou le port indiqué dans la console).

### Build de Production

```bash
# Compiler le projet
npm run build

# Prévisualiser le bundle de production
npm run preview
```

---

## 📂 Structure du Projet

```text
pinterest/
├── public/
│   ├── avatar_jaye.jpg       # Avatar réel de l'utilisateur
│   ├── favicon.svg           # Favicon officiel Pinterest
│   └── pins/                 # Échantillons d'images d'épingles
├── src/
│   ├── assets/marque/        # Logo vectoriel officiel Pinterest
│   ├── data/                 # Données mockées et pins de démonstration
│   ├── pages/
│   │   ├── Accueil.tsx       # Landing page publique déconnectée
│   │   ├── Connexion.tsx     # Page d'authentification
│   │   ├── Creer.tsx         # Outil de création d'Épingle
│   │   ├── Fil.tsx           # Page d'accueil connectée (onglet All)
│   │   └── Profil.tsx        # Profil utilisateur (Créées / Enregistrées)
│   ├── shell/
│   │   ├── AppShell.tsx      # En-tête, notifications, boîte de réception
│   │   ├── Recherche.tsx     # Volet de recherche en 2 colonnes
│   │   └── PublicShell.tsx   # En-tête et pied de page déconnectés
│   ├── state/
│   │   └── Session.tsx       # Contexte d'authentification et état global
│   ├── styles/
│   │   ├── charpente.css     # Styles de l'en-tête, modales et navigation
│   │   ├── pages.css         # Styles des pages, profils, feed et création
│   │   └── theme.css         # Variables et tokens visuels Gestalt
│   └── ui/
│       ├── Icone.tsx         # Bibliothèque des icônes SVG Pinterest Gestalt
│       ├── Masonry.tsx       # Grille dynamique d'épingles
│       └── PinCard.tsx       # Carte d'épingle avec actions au survol
└── README.md
```

---

## 📄 Licence

Ce projet est réalisé à des fins d'apprentissage, d'étude ergonomique et de démonstration technique. Les marques, logos et identités visuelles associés appartiennent à [Pinterest, Inc.](https://www.pinterest.com/).
