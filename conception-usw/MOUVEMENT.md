# USW : la charte du mouvement

United State of World. Les règles de mouvement de l'application, relevées
dans le site Nentem (`D:\nentem\site`, lui-même étudié sur lusion.co) et
adaptées au verre liquide de SafeVault (`D:\safevault-ihm`).

Une règle d'or : **le mouvement explique, il ne décore pas**. Chaque
animation dit d'où vient un élément, où il va, ou que l'action a marché.
Le réglage système « réduire les animations » l'emporte sur tout.

Zéro tiret cadratin.

---

## 1. Les courbes

| nom | valeur | où | source |
|---|---|---|---|
| **signature** | `cubic-bezier(0.35, 0, 0, 1)` | toute entrée de texte, toute arrivée d'écran | `ease.lusion`, `lib/math.ts` |
| **interface** | `cubic-bezier(0.4, 0, 0.1, 1)` | survols, appuis, menus, boutons, onglets | `globals.css`, menu et boutons |
| **ressort** | `cubic-bezier(0.34, 1.56, 0.64, 1)` | l'appui sur le verre, une coche, un cœur | `tokens.css` SafeVault |
| **expo sortie** | `1 - 2^(-10t)` | rideau d'ouverture, cartes qui se posent, phrases longues | `ease.expoOut` |
| **expo aller-retour** | `expoInOut` | colonnes de lettres (machine à sous) | `Featured.tsx` |
| **rebond** | `backOut` | une pastille qui apparaît et dépasse sa taille | étoile du préchargeur |

En Flutter : `Cubic(0.35, 0, 0, 1)`, `Cubic(0.4, 0, 0.1, 1)`,
`Cubic(0.34, 1.56, 0.64, 1)`, `Curves.easeOutExpo`, `Curves.easeInOutExpo`,
`Curves.easeOutBack`.

## 2. Les durées

| quoi | durée |
|---|---|
| survol, couleur, petite bascule | 0,25 à 0,3 s |
| appui (le verre se tasse) | 0,12 s, puis retour 0,5 s au ressort |
| menu, feuille, carte qui entre | 0,4 à 0,5 s |
| texte révélé (un mot, une lettre) | 1 s par pièce, avec décalage |
| transition entre deux écrans | 0,6 à 0,8 s |
| ouverture de l'application | 3 s au total, à toucher pour passer |

Rien ne dure plus d'une seconde quand l'utilisateur attend une réponse.

## 3. Le texte qui entre

Le principe Nentem : un bloc possède une **horloge** qui avance tant qu'il est
à l'écran et revient à zéro quand il repasse sous l'écran, donc l'entrée se
rejoue en remontant puis redescendant (`lib/reveal.ts`). Chaque pièce lit
`fit(temps − rang × décalage, 0, durée, départ, arrivée, courbe)`.

Le texte est découpé en pièces (`components/Split.tsx`) : un cadre
`inline-block` qui coupe ce qui déborde, et dedans le mot ou la lettre qu'on
déplace.

| motif | mouvement | décalage | courbe |
|---|---|---|---|
| **titre héros**, par mot | monte de 1,7 em et se redresse de 15° à 0 | 1/20 s | signature |
| **titre de section**, par lettre | monte de 1 em, se redresse de 10° à 0 (horloge × 1,5) | 1/20 s | signature |
| **paragraphe**, par mot, coupé | monte de 110 % à 0 | 1/60 s | signature |
| **description**, par mot | monte de 100 % à 0, opacité 0,1 à 1 | 1/100 s | expo sortie |
| **appel à l'action** | monte de 150 % à 0, se redresse de 10° | | signature |
| **petite ligne** (« faites défiler ») | opacité 0 à 1, échelle 0,8 à 1 | 1/10 s | signature |
| **étiquettes** | tapées à 40 lettres/s, les 5 dernières encore brouillées | | |
| **titre de carte** | chaque lettre est une colonne de 4 copies qui glisse (machine à sous), les lettres du milieu arrivent d'abord | cosinus | expo aller-retour |

Le départ se déclenche quand le haut du bloc passe à 92 % de la hauteur de
l'écran.

## 4. Le défilement

- Défilement adouci : la page suit sa cible avec
  `position += (cible − position) × (1 − e^(−12 dt))`.
- Au doigt : la vitesse se mesure sur 0,1 s, puis le frottement la freine.
- Les images de la mosaïque prennent un léger « remous » horizontal quand on
  défile vite (déformation ≤ 0,15), et reviennent à plat à l'arrêt.
- Seulement une fois la pile déliée (la page du lieu, E33, ouverte en
  touchant une pile de l'accueil ; les piles, elles, ne bougent pas au
  défilement), une carte qui entre se pose comme les projets de Nentem : elle arrive de
  son côté (colonne de gauche par la gauche, de droite par la droite, du
  milieu tout droit, 5 % de l'écran) en se redressant de 3°, son masque
  arrondi s'ouvre de 70 % à 100 % et l'image dézoome (1,3 → 1), en expo
  sortie. Le mouvement suit le doigt : il avance et recule avec le
  défilement et se termine quand la carte est entrée en entier ; les cartes
  visibles à l'ouverture sont déjà posées. Le nom et le téléphone sous la
  carte montent à leur tour (14 px).
- L'en-tête de l'accueil et d'un lieu (titre, flux, filtres) n'est pas figé :
  quand on descend, il se range sous la barre d'état en 0,45 s (courbe
  interface) et les photos défilent sur tout l'écran ; dès qu'on remonte,
  il revient en entier, titre et filtres ensemble. Il est plein (fond
  lavande), jamais de photo derrière un texte. Sous la barre d'état et sous
  l'en-tête, pas de coupure nette : le voile de Sika, le fond à 85 % flouté
  de 4 px, qui s'efface vers le bas sur 26 px ; les photos y entrent en douceur.

En Flutter, la physique de défilement native reste : on ne remplace que les
entrées et les effets liés à la vitesse.

## 5. Les micro-interactions, pour jouer

Repris des boutons du site, posés sur le verre liquide :

- **le verre** (SafeVault) : l'arête suit le doigt, une onde de lumière part du
  point touché, la goutte se tasse à 0,965 puis revient au ressort ;
- **libellé qui roule** : un bouton porte deux fois son texte l'un sous
  l'autre ; à l'appui la pile monte de 100 % (« Enregistrer » laisse place à
  « Enregistré ») ;
- **flèche qui entre** : les points d'un bouton se réduisent à 0, le texte
  glisse de 1,5 em, une flèche arrive de la gauche ;
- **deux points qui tournent** : l'icône de menu fait un quart de tour en
  s'ouvrant ;
- **cartes de menu** : elles arrivent de 7,75 em plus bas, penchées de −3,5°,
  avec un délai l'une après l'autre, et repartent dans l'ordre inverse ;
- **pastille** : elle apparaît au rebond (`backOut`) ;
- **appui long** : la carte se tasse, le fond s'assombrit, et le menu
  circulaire sort en éventail autour du doigt.

Le jeu reste discret : une seule surprise par geste.

## 6. Les transitions entre écrans

- **D'une carte à son épingle** : la carte grandit jusqu'à remplir l'écran et
  devient l'image de l'épingle (le « zoom de carte » de Nentem), puis le
  contenu entre par le bas.
- **D'un onglet à l'autre** : le contenu sortant glisse de quelques pixels et
  s'efface, l'entrant arrive avec ses textes révélés (section 3).
- **Feuilles et fenêtres** : elles montent au ressort, sur un voile qui
  s'assombrit.
- **Retour** : le chemin inverse, toujours plus court (0,8 fois la durée).

## 7. L'ouverture de l'application

Le sigle, puis le nom, un mot à la fois. Sur le fond lavande uni, sans
ornement, environ 5 s, à toucher pour passer. Une seule courbe, longue et
sans rebond : `cubic-bezier(0.22, 1, 0.36, 1)`.

1. **0,2 à 2,2 s, le sigle s'écrit.** `U`, puis `S`, puis `W` (en limonade)
   montent de 0,6 em en apparaissant, en 1,1 s chacune, à 0,45 s d'écart :
   chaque lettre a son temps.
2. **1,9 à 5 s, le sigle s'élargit, un mot à la fois.** `United` se déroule
   derrière son `U` (1,9 s), puis `State` (2,6 s), puis le petit `of` se
   glisse entre `State` et `W` (3,25 s), puis `World` (3,75 s). Les lettres
   ajoutées montent une à une, coupées par leur cadre, à 0,06 s d'écart ;
   l'espace avant un mot s'ouvre avec le mot qui le précède.
3. **Ensuite, l'accueil (E03).** Chaque lieu y est une pile de ses photos,
   rangée en paquet : les photos de derrière, alignées et un peu plus
   petites, ne dépassent qu'en haut (8 px puis 15 px). Toutes les 4 s, la
   photo de devant glisse vers le bas en s'effaçant et la suivante avance à
   sa place, en 0,8 s, sur une seule courbe sans rebond
   (`cubic-bezier(0.22, 1, 0.36, 1)`) ; son image se recadre (1,1 → 1).
   Les piles tournent l'une après l'autre, à 0,5 s d'écart dans l'ordre de
   lecture. Toucher une pile ouvre le lieu (E33).

Pendant ce temps, l'application charge le premier fil : si celui-ci est prêt
avant, l'ouverture ne ralentit pas ; s'il ne l'est pas, le nom reste affiché,
sans jamais revenir en arrière.

## 8. Ce qui ne se fait pas

- **La performance d'abord.** On n'anime que `transform` et `opacity`, que le
  téléphone anime sans recalculer la page : pas de `clip-path`, de
  `z-index`, de marges ni de tailles animés. L'ordre des photos d'une pile se
  joue en profondeur (`translateZ`) ; les entrées au défilement sont liées
  au défilement et tournent hors du fil principal. Seule exception, le nom
  de l'ouverture, qui se déroule en largeur sur un écran vide.

- Pas de mouvement qui bloque un geste : on peut toucher pendant une entrée.
- Pas de rebond sur un texte à lire.
- Pas d'animation de plus d'une seconde entre une action et sa réponse.
- Rien qui ne s'arrête quand « réduire les animations » est demandé : alors
  les pièces apparaissent en fondu de 0,2 s, sans déplacement.
