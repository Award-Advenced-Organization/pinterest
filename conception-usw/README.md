# USW : conception (groupe 4)

United State of World. Ce dossier rassemble tout ce qui a été posé **avant le code** :
la maquette, l'analyse UML, l'architecture du backend et le cahier des charges.

| Dossier ou fichier | Contenu |
|---|---|
| `maquette-usw.html` | La maquette cliquable, 61 écrans, téléphone et tablette. Un seul fichier, à ouvrir dans le navigateur. |
| `maquette/figma/` | La maquette prête pour Figma : images des écrans et pages HTML. |
| `cahier/USW_Cahier_De_Charges_Groupe4_v2.pdf` | Le cahier des charges complet (42 pages). |
| `analyse/ANALYSE.md` | Cas d'utilisation, classes, correspondance avec les écrans. |
| `analyse/ARCHITECTURE.md` | L'architecture du backend Laravel, l'API, la sécurité et le plan de travail. |
| `analyse/rendus/` | Tous les diagrammes, en SVG et en PNG. |
| `MOUVEMENT.md` | Les règles d'animation de l'application. |
| `maquette/`, `outils/`, `pack-icones/` | Les sources de la maquette et les scripts qui la fabriquent. |

## Voir la maquette cliquable

Ouvrir `maquette-usw.html` dans Chrome ou Edge, ou directement en ligne :
<https://raw.githack.com/Award-Advenced-Organization/pinterest/USW/conception-usw/maquette-usw.html>

- **Présenter** lance le prototype. On clique sur les boutons comme dans l'application.
- Un clic hors d'un lien fait clignoter en bleu les zones cliquables.
- `Retour arrière` revient à l'écran précédent, `←` `→` passent d'un écran à l'autre, `Échap` quitte.

## Ouvrir la maquette dans Figma

Les écrans sont numérotés dans l'ordre du parcours : `01-ouverture`, `02-bienvenue-1`, etc.

**1. En images, pour commenter et relier les écrans**

1. Dans Figma, créer un fichier de design.
2. Glisser les 61 images de `maquette/figma/telephone/` (412 px de large, en x2) sur la page.
   Celles de `maquette/figma/tablette/` sont à 800 px.
3. Pour faire un prototype : sélectionner une image, `Ctrl + Alt + G` la met dans un cadre, puis
   relier les cadres dans l'onglet *Prototype*.

**2. En calques modifiables (textes, formes, couleurs)**

1. Installer le module Figma **html.to.design**.
2. Choisir l'import par adresse et coller l'adresse de l'écran voulu, par exemple :
   <https://raw.githack.com/Award-Advenced-Organization/pinterest/USW/conception-usw/maquette/figma/html/14-accueil.html>
   (remplacer `14-accueil` par le nom d'un fichier de `maquette/figma/html/`).
3. Régler la largeur à **412** pour le téléphone, **800** pour la tablette.

Le plan gratuit de html.to.design limite le nombre d'imports par mois : importer d'abord les
écrans sur lesquels on travaille. La police de l'application est **Wura Mi** (licence OFL), dans
`maquette/polices/`. Sans elle, Figma la remplace par une autre.

## Répartir le travail

Le code avance par lots, dans l'ordre, chacun testé avant le suivant (détail dans
`analyse/ARCHITECTURE.md`, section 11).

| Lot | Contenu | Écrans | Responsable |
|---|---|---|---|
| 0. Socle | Projet Laravel 13 `usw_api`, MySQL, Sanctum, format des erreurs, tests, contrôle de la version de PHP | | |
| 1. Compte | Inscription, code e-mail, connexion e-mail et Google, profil, réglages | E01, E02, E36, E18, E21 | |
| 2. Lieux et contenus | Pays, villes, lieux, contenus, données de départ | E03, E33 | |
| 3. Envoi et vérification | Envoi par morceaux, deux temps, analyse, variantes WebP | E12 à E16, E26 à E30, E32 | |
| 4. Exploration | Flux, reels, Près de moi, carte, recherche, filtres | E03, E04, E06, E11, E31, E33 | |
| 5. Communauté | Réactions, commentaires, collections, abonnements, partage | E05, E07, E09, E10, E19 | |
| 6. Modération | Signalements, file, décisions, règles | E22, E24, E25 | |
| 7. Notifications | Centre de notifications, push | E17 | |
| 8. Production | Performances, revue de sécurité, déploiement | | |

Côté application Flutter, chaque lot a aussi ses écrans à brancher sur l'API.

**À décider ensemble avant de commencer :**

1. L'hébergement de production (base, cache, stockage des photos).
2. Le service de notifications push : Firebase est proposé.
3. Le backend dans un projet séparé `usw_api`, à côté de `pinterest_api` : proposé.

**Sécurité :** PHP **8.5.12** au minimum (ou 8.4.27), à cause des failles *php2shell*
(CVE-2026-109618 et CVE-2026-109619, publiées le 21 octobre 2026). Mettez PHP à jour sur vos
machines avant de lancer le backend : `php -v`.

## Refaire la maquette après une modification

Il faut Node, Python 3.12 avec Pillow, Chrome et PlantUML. Les scripts sont dans `outils/` :

- `node outils/maquette.mjs` reconstruit `maquette-usw.html` à partir de `maquette/` ;
- `node outils/figma.mjs` refait l'export pour Figma ;
- `outils/diagrammes.cmd` refait les diagrammes, `outils/cahier.cmd` le PDF du cahier.

Certains scripts supposent que le dossier se trouve dans `D:\usw-ihm`.
