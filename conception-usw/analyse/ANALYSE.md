# USW : analyse du cahier des charges

United State of World. Source : `Cahier_De_Charges_Groupe4.pdf` (Groupe 4,
L3 IFRI, cours de Développement d'applications mobiles, Mme Limuse A. TIKPON).

Trois documents qui se répondent, pour que maquettes et diagrammes restent
alignés :

- `cas-utilisation.puml` : qui fait quoi ;
- `classes.puml` : les données que ça manipule ;
- ce fichier : le lien entre chaque cas, ses classes et ses écrans.

Les images des diagrammes sont dans `rendus/`, refaites par
`outils/diagrammes.cmd`.

Une règle : **un cas d'utilisation sans écran, ou un écran sans cas
d'utilisation, est une erreur**. La section 7 le vérifie.

---

## 1. Les acteurs

| acteur | qui | hérite de |
|---|---|---|
| **Visiteur** | ouvre l'application sans compte : regarde le flux, la carte, peut se rendre sur place | |
| **Membre** | a un compte : publie, réagit, commente, enregistre, télécharge, signale | Visiteur |
| **Créateur** | le membre auteur d'un contenu : épingle et modère les commentaires de ce contenu | Membre |
| **Modérateur** | traite la file de validation humaine et les signalements | Membre |
| Application de cartographie | Google Maps, Waze, Maps : reçoit la destination et fait **tout** l'itinéraire (section 3.3) | système |
| GPS du téléphone | donne la position actuelle, pour Près de moi et le filtre de proximité | système |
| Messagerie | WhatsApp et la feuille de partage du téléphone (section 3.4) | système |

Le contributeur et le voyageur des parcours A et B ne sont pas deux acteurs :
c'est le même membre, dans deux rôles.

## 2. Les cas d'utilisation

| n° | cas | acteur | cahier | parcours |
|---|---|---|---|---|
| UC01 | S'inscrire | Visiteur | 4 (authentification) | |
| UC02 | Se connecter | Visiteur | 4 | |
| UC03 | Gérer son profil | Membre | | |
| UC10 | Publier un contenu (photo ou reel) | Membre | 3.1, 3.4 Publication | A1 à A5 |
| UC11 | Prendre une photo avec la caméra USW (réglages par défaut, sans filtre) | Membre | 3.4 | A2 |
| UC12 | Importer depuis la galerie, même une photo ancienne | Membre | 3.1 Importation, 3.4 | A2 |
| UC18 | Tourner un reel par séquences, à la manière de TikTok et Instagram | Membre | 3.4 Publication | A2 |
| UC19 | Monter le reel : couper, ordonner les séquences, texte, son | Membre | 3.4 Publication | A2 |
| UC13 | Extraire les métadonnées (téléphone, GPS, date) sur le téléphone et pré-remplir le formulaire | système | 3.1 EXIF, 3.4, 4 native_exif | A3 |
| UC14 | Vérifier l'authenticité : signes d'IA, cohérence, niveau du badge | système | 3.1 Garantie non-IA, Critère | A4 |
| UC27 | Compléter les informations manquantes : téléphone, date, lieu | Membre | | A3 |
| UC15 | Envoyer le média par morceaux, avec reprise | système | 3.1 Importation | A5 |
| UC16 | Préparer les versions WebP pour l'affichage | système | | A5 |
| UC17 | Suivre ses envois : pause, reprise, annulation | Membre | | |
| UC20 | Parcourir un flux : Découverte, Abonnements, Près de moi | Visiteur | 3.2 Flux, 3.4 Feeds | B1, C1 |
| UC21 | Filtrer le flux : pays, ville, type de lieu, proximité | Visiteur | 3.2 Filtres | B3 |
| UC22 | Consulter un contenu : lieu, appareil, badge | Visiteur | 3.2 Lieu, Affichage transparent | B2, B4 |
| UC23 | Explorer la carte des reels | Visiteur | 3.4 Carte des reels | |
| UC24 | Télécharger l'original, dans son format d'origine | Membre | | |
| UC25 | Regarder les reels en fil vertical plein écran (glisser vers le haut) | Visiteur | 3.4 Feeds vidéo | C1 |
| UC26 | Rechercher librement : lieux, contenus, créateurs, mots-clés | Visiteur | | |
| UC30 | Lancer l'itinéraire « Y aller » : ouvre l'application de cartographie | Visiteur | 3.3 | B5, B6 |
| UC31 | Obtenir la position actuelle | système | 3.2 proximité, 3.4 Près de moi | |
| UC40 | Aimer, réagir | Membre | 3.4 Likes & réactions | C2 |
| UC41 | Commenter, répondre, mentionner | Membre | 3.4 Commentaires | C3 |
| UC42 | Partager (WhatsApp) | Membre | 3.4 Partage | C4 |
| UC43 | Enregistrer dans une collection | Membre | 3.4 Sauvegarde | C4 |
| UC44 | Gérer ses collections | Membre | 3.4 | |
| UC45 | S'abonner à un créateur | Membre | 3.4 (feed Abonnements) | |
| UC46 | Consulter ses notifications | Membre | | C5 |
| UC47 | Épingler un commentaire | Créateur | 3.4 Commentaires | C5 |
| UC48 | Modérer les commentaires de ses contenus | Créateur | | C5 |
| UC50 | Signaler un contenu ou un commentaire | Membre | 3.4 Modération | C6 |
| UC51 | Bloquer un utilisateur | Membre | 3.4 Modération | |
| UC52 | Consulter les règles communautaires | Visiteur | 3.4 Modération | |
| UC53 | Traiter la file de validation | Modérateur | 3.4 Modération | C6 |
| UC54 | Traiter les signalements | Modérateur | 3.4 Modération | C6 |

Relations :

- UC10 inclut UC13, UC14 et UC15 ; UC15 inclut UC16 ;
- UC11, UC12 et UC18 étendent UC10 ; UC19 étend UC18 et UC12 (une vidéo importée se monte aussi) ;
- UC27 étend UC10, quand une information manque au fichier ;
- UC21 étend UC20 et UC25 ; UC20 et UC25 incluent UC31 (Près de moi) ;
- UC30 étend UC22, UC23, UC25 et UC26 ;
- UC43 inclut UC44.

## 3. Les informations de capture : d'où elles viennent

Chaque contenu publié porte toujours trois informations : **le téléphone**
qui l'a pris, **la date** et **le lieu** (un point précis). Elles ont trois
origines possibles, et l'application dit toujours laquelle.

| origine | quand | ce qui se passe |
|---|---|---|
| **la caméra USW** | le membre prend la photo ou tourne le reel dans USW, comme dans Snapchat, avec les réglages par défaut de la caméra et **sans filtre** | à la première utilisation, le membre **autorise** USW à lire le modèle du téléphone et sa position ; ensuite, **chaque prise** reçoit d'office le modèle, la date et la position, sans rien demander |
| **les métadonnées du fichier** | le membre importe une photo ou une vidéo de sa galerie, **même ancienne** | USW lit sur le téléphone ce que le fichier contient (EXIF, ou métadonnées MP4 et MOV) et **remplit le formulaire tout seul** |
| **l'auteur** | le fichier importé ne contient pas une information | le membre la **complète** (UC27) : il choisit le téléphone qui a servi dans une liste de modèles, donne la date, et indique le lieu en le cherchant ou en posant une épingle sur une carte |

Le niveau de confiance se voit sur le contenu :

- **« Capture vérifiée »** : le téléphone et le lieu viennent de la caméra USW
  ou des métadonnées du fichier ;
- **« Informations déclarées par l'auteur »** : au moins l'un des deux a été
  complété à la main. Le contenu est publié, mais le badge le dit.

Rien n'est refusé parce qu'une information manque. Est refusé, ou envoyé à
la file humaine, un fichier qui **porte des signes de génération par IA** :
un logiciel de génération inscrit dans ses métadonnées, une marque de
provenance qui le déclare généré, ou des informations incohérentes (un
modèle de téléphone qui n'existait pas à la date annoncée, par exemple).

Chaque contenu publié a un point précis : « Y aller » fonctionne toujours.

## 4. L'itinéraire : dans Maps, pas dans USW

« Y aller » ne dessine aucune carte ni aucun trajet dans l'application. Il
envoie les coordonnées du point de prise de vue (GPS du fichier, ou lieu
indiqué par l'auteur) à l'application de cartographie du téléphone, qui
calcule et guide (section 3.3, « Navigation externe ») :

- Android : `google.navigation:q=<lat>,<lng>`, ou `geo:<lat>,<lng>?q=<lat>,<lng>(<nom du lieu>)`
  pour laisser le choix de l'application ;
- iOS : `maps://?daddr=<lat>,<lng>`, ou Google Maps s'il est installé ;
- par `url_launcher` (section 4).

Si plusieurs applications de cartographie sont installées, c'est le
sélecteur du système qui s'affiche, pas un écran de USW. USW n'a donc pas
besoin de la position du voyageur pour l'itinéraire : Maps la prend lui-même.

La **carte des reels** (UC23, écran E11) reste dans USW : c'est une carte de
découverte (où sont les contenus), pas un itinéraire. Son bouton « Y aller »
ouvre Maps comme partout ailleurs.

## 5. L'envoi des médias : rapide en 3G, la meilleure qualité à l'arrivée

Deux exigences : publier doit être **facile, rapide et fluide même en 3G**,
et la plateforme garde **la meilleure qualité**, affichée en **WebP**, avec
**l'original téléchargeable dans son format d'origine**.

### Sur le téléphone, avant d'envoyer quoi que ce soit

1. **Le contrôle se fait sur place** (UC13, UC14) : `native_exif` lit
   l'appareil, le GPS et la date dans le fichier et pré-remplit le
   formulaire ; ce qui manque est demandé au membre (section 3). Un fichier
   qui porte des signes d'IA est arrêté là, **sans avoir dépensé un octet**
   de données.
2. **L'empreinte du fichier** (SHA-256) est calculée : le serveur reconnaît un
   fichier déjà reçu, ou déjà en partie reçu, et ne le redemande pas.

### Pendant l'envoi (UC15)

3. **Par morceaux** : le fichier part en morceaux de 256 Ko (en 3G) à 2 Mo
   (en Wi-Fi), réglés selon le débit mesuré. Chaque morceau reçu est acquis.
4. **Reprise** : une coupure, un passage en arrière-plan ou un redémarrage
   du téléphone ne fait rien perdre ; l'envoi repart du dernier morceau reçu,
   tout seul, dès que le réseau revient.
5. **En arrière-plan** : le membre continue à naviguer ; une pastille montre
   la progression, et l'écran Mes envois (E26) permet pause, reprise et
   annulation (UC17).
6. **L'original n'est jamais recompressé sur le téléphone** : c'est lui qui
   part, intact, pour que la plateforme garde la meilleure qualité. Seule la
   coupure en morceaux et la reprise rendent l'envoi supportable en 3G.

### Sur le serveur, à l'arrivée (UC16)

7. **L'original est gardé tel quel** (JPEG, HEIC, PNG ; MP4, MOV pour les
   reels), avec sa résolution d'origine : classe `FichierOriginal`.
8. Le serveur relit l'EXIF de l'original pour confirmer le contrôle fait sur
   le téléphone (le téléphone peut mentir, le fichier non).
9. **Les versions d'affichage** sont fabriquées : classe `Variante`.

| usage | photo | reel |
|---|---|---|
| aperçu flou (pendant le chargement) | WebP 32 px, moins de 1 Ko | WebP 32 px |
| miniature (mosaïque, carte) | WebP 400 px | affiche WebP 400 px |
| flux | WebP 1080 px | vidéo légère, 480p |
| plein écran | WebP 2048 px (tablette comprise), qualité haute | vidéo HD, 720p ou 1080p |

10. Le contenu passe **en ligne** quand l'original est reçu, vérifié et que
    ses versions sont prêtes ; le membre reçoit une notification.

### À l'affichage

11. L'application choisit la version selon la taille de l'écran **et le
    réseau** : en 3G, la version flux ; en Wi-Fi, la pleine.
12. La couleur dominante, puis l'aperçu flou, puis l'image nette : jamais de
    case vide.

### Au téléchargement (UC24)

13. « Télécharger l'original » donne le fichier d'origine, dans son format et
    sa résolution d'origine. L'écran E08 annonce le format et le poids avant
    de lancer, pour ne pas surprendre en 3G.

## 6. Les écrans

Formats : **tablette 800 × 1280**, **téléphone 412 × 915**. Chaque écran
existe dans les deux.

Barre d'onglets (5), à la manière d'Instagram : **Accueil** (la mosaïque),
**Reels** (le fil vertical), **Créer** (+), **Carte**, **Profil**. En haut de
l'Accueil : la loupe de recherche et la cloche des notifications.

| n° | écran | cas | classes |
|---|---|---|---|
| E00 | Ouverture : USW devient United State of World | | |
| E01 | Bienvenue, en trois écrans qui avancent seuls (6 s) : des lieux en vraies photos ; chaque photo dit d'où elle vient ; Y aller. Créer un compte, se connecter ou explorer sans compte | UC01, UC02, UC52 | |
| E02 | Entrée façon Pinterest : mosaïque de photos qui glisse, e-mail puis « Continuer », ou « Continuer avec Google ». E-mail connu : mot de passe (« Bon retour »). Inconnu : créer le mot de passe, puis code de vérification de l'e-mail. Mot de passe oublié, nouveau mot de passe | UC01, UC02 | Utilisateur, FournisseurConnexion |
| E36 | Compléter le profil, à la première connexion (e-mail ou Google), en trois étapes : photo, nom affiché, nom d'utilisateur, bio ; pays, ville, position pour « Près de moi » ; types de lieux aimés (3 au moins) | UC01, UC03 | Utilisateur, TypeLieu |
| E03 | Accueil : mosaïque de piles de photos par lieu, qui défilent ; toucher une pile ouvre le lieu (E33) ; onglets Découverte, Abonnements, Près de moi | UC20, UC31 | Contenu, Variante, Lieu, Capture, FiltreFlux |
| E33 | Lieu : nom, région, nombre de photos, **Y aller**, onglets Tout / Photos / Reels, mosaïque des contenus pris à ce lieu | UC20, UC22, UC30 | Lieu, Contenu, Capture |
| E04 | Filtres du flux (feuille) : pays, ville, types de lieu, distance (curseur), captures vérifiées seulement ; « Voir N lieux » donne le nombre avant de valider | UC21 | FiltreFlux, Pays, Ville, TypeLieu |
| E05 | Photo : image pleine largeur, badge « Capture vérifiée », lieu, appareil, date, **Y aller**, réactions, enregistrer, partager, télécharger | UC22, UC30, UC40, UC42, UC43, UC24 | Photo, Capture, Lieu, Reaction, Itineraire |
| E06 | Reels : fil vertical plein écran, on glisse vers le haut ; appui long sur le cœur pour les quatre réactions, le compteur ouvre la liste des réactions par type ; commentaires, partager (avec télécharger, enregistrer, pas intéressé, signaler), enregistrer, télécharger le reel en feuilles ; onglets Découverte, Abonnements, Près de moi ; lecture muette, badge, lieu, appareil, s'abonner, aimer, commenter, partager, Y aller | UC25, UC22, UC30, UC40, UC41, UC42, UC43, UC45 | Reel, Capture, Lieu, Itineraire |
| E07 | Commentaires (feuille haute) : commentaire épinglé par l'auteur, réponses imbriquées, j'aime, saisie avec « Réponse à » et suggestions de @mentions | UC41, UC47, UC48 | Commentaire |
| E08 | Télécharger l'original (feuille) : nom, format, résolution, Mpx ; choix original ou taille écran (2 160 px, sans les informations du fichier) ; avertissement en 3G avec la durée ; attendre le Wi-Fi ; usage personnel | UC24 | FichierOriginal, Variante |
| E09 | Enregistrer (feuille) : collections avec vignettes, secrètes marquées d'un cadenas ; un appui enregistre, un message permet de changer ; en créer une | UC43, UC44 | Collection, Enregistrement |
| E10 | Partager (feuille) : aperçu et lien court, envoyer à un membre, WhatsApp, copier le lien, message, e-mail, autres applications ; le lien ouvre la photo sans l'application | UC42 | |
| E11 | Carte des reels : chaque contenu est une vignette posée sur son lieu (reel marqué ▶), groupes chiffrés, filtres Reels/Photos/Captures vérifiées, aperçu en bas avec « Voir le reel » et « Y aller » vers Maps | UC23, UC30 | Lieu, Reel, Variante |
| E12 | Créer, choisir : photo, reel, ou importer de la galerie ; rappel du contrat « pas d'IA » | UC10, UC11, UC12, UC18 | |
| E13 | Lecture du fichier, sans écran : téléphone, date, lieu et signes d'IA sont lus en arrière-plan et rangés d'eux-mêmes dans les détails (E14). On ne montre quelque chose qu'en cas de problème : il manque une information (E15) ou la publication est refusée (E37) | UC13, UC14 | Capture |
| E14 | Publier, détails : légende, lieu trouvé et son type, aperçu avec le badge | UC10 | Contenu, Lieu |
| E15 | Publier, compléter, seulement s'il manque quelque chose : ce que le fichier ne dit pas. Le téléphone est saisi par l'utilisateur : s'il est dans la liste des modèles déjà vus sur USW, il le choisit, sinon il l'ajoute (pas de base de tous les téléphones) ; raccourci « C'est ce téléphone ». La date (mois et année suffisent), le lieu ; le badge qui en résulte | UC27 | Capture, OrigineInformation |
| E16 | Publier, en route : l'envoi part en arrière-plan, on peut continuer à naviguer | UC15, UC16 | Envoi |
| E17 | Notifications : réactions, commentaires, mentions, abonnés, contenu en ligne | UC46 | Notification |
| E18 | Mon profil : mes publications, mes collections | UC03, UC44 | Utilisateur, Contenu, Collection |
| E19 | Collection : couverture de trois photos, secrète ou publique, la renommer, la partager ; ses contenus en mosaïque | UC44 | Collection |
| E20 | Profil d'un créateur : ses contenus, s'abonner, bloquer, signaler | UC45, UC51, UC50 | Utilisateur, Abonnement, Blocage |
| E21 | Modifier le profil ; réglages : compte, données mobiles (qualité réduite en 3G, reels et envois en Wi-Fi), autorisations, aide et documents, se déconnecter et supprimer le compte en rouge | UC03, UC51 | Utilisateur, Blocage |
| E22 | Signaler (feuille) : six motifs (IA, faux lieu, pas l'auteur, choquant, harcèlement, spam), précision facultative, anonyme, réponse sous 24 h | UC50 | Signalement |
| E23 | Règles communautaires : six règles avec un exemple accepté et un refusé, puis les suites d'un manquement (retrait, suspension 7 jours, suppression) | UC52 | RegleCommunautaire |
| E24 | Modération, file : à vérifier, signalements, demandes de vérification ; les plus urgents d'abord, avec la raison (score d'IA, signalements, information déclarée) ; le reste est publié sans attendre | UC53, UC54 | Contenu, Signalement |
| E25 | Modération, décision : le contenu, l'auteur et son historique, le score d'IA et ses raisons, le fichier comparé à la déclaration ; motif du refus ; Refuser (rouge) ou Publier (limonade) | UC53, UC54 | DecisionModeration, Capture |
| E26 | Mes envois : en cours, en pause, en vérification, avec pause, reprise, annulation | UC17 | Envoi |
| E27 | Caméra USW, pour les reels seulement (les photos se prennent avec l'appareil photo du téléphone et tous ses modes) : plein écran, sans filtre, durée 15, 30 ou 60 s, appuyer pour filmer une séquence, minuterie, retourner la caméra, barre des séquences ; le téléphone et la position affichés en haut | UC18 | Reel, Capture |
| E28 | Monter le reel : frise des séquences, couper, réordonner, supprimer, ajouter un texte, son d'origine ou musique | UC19 | Reel |
| E29 | Choisir un son (feuille) : son d'origine, voix off, bibliothèque de musiques libres de droits | UC19 | PisteAudio |
| E30 | Indiquer le lieu : le fichier n'a pas de GPS ; chercher le lieu ou poser une épingle sur la carte | UC27 | Capture, Lieu, OrigineInformation |
| E32 | Autorisations, une seule fois : position et modèle du téléphone (ajoutés à chaque prise), caméra et micro pour les reels. Les photos se prennent avec l'appareil photo du téléphone, tous ses modes ; au retour, USW vérifie que la prise vient d'avoir lieu et ajoute la position | UC11, UC18 | Capture |
| E34 | Conditions générales d'utilisation : sommaire, articles | UC01, UC52 | |
| E35 | Aide : recherche, sujets, questions fréquentes, écrire à l'équipe, liens vers les règles, les CGU et la confidentialité | UC52 | |
| E37 | Messages et erreurs : champ en erreur, pas de connexion, contenu introuvable, publication refusée (demander une vérification), fenêtre de confirmation (se déconnecter), bulle d'aide, message après une action, position désactivée, recherche sans résultat. Rien n'arrête l'utilisateur quand tout va bien | UC02, UC14, UC26, UC31 | |
| E38 | Politique de confidentialité : en bref, ce que nous gardons et combien de temps, ce que les autres voient, vos droits (télécharger mes données, supprimer le compte, APDP) | UC52 | Utilisateur |
| E31 | Recherche : champ libre, recherches récentes, résultats en trois onglets (Lieux, Contenus, Créateurs), filtres applicables | UC26, UC21, UC30 | Recherche, Lieu, Contenu, Utilisateur |

## 7. Contrôle d'alignement

Chaque cas a au moins un écran :

| cas | écrans |
|---|---|
| UC01, UC02 | E01, E02 |
| UC03 | E18, E21 |
| UC10 | E12, E14 |
| UC11, UC12 | E12, E32 |
| UC18 | E12, E27 |
| UC19 | E28, E29 |
| UC25 | E06 |
| UC26 | E31 |
| UC27 | E15, E30 |
| UC13, UC14 | E13 |
| UC15, UC16 | E16 |
| UC17 | E26 |
| UC20, UC31 | E03 |
| UC21 | E04 |
| UC22 | E05, E06 |
| UC23 | E11 |
| UC24 | E05, E08 |
| UC30 | E05, E06, E11, E31 |
| UC40 | E05, E06 |
| UC41, UC47, UC48 | E07 |
| UC42 | E10 |
| UC43, UC44 | E09, E18, E19 |
| UC45 | E20 |
| UC46 | E17 |
| UC50 | E20, E22 |
| UC52 | E01, E23, E34, E38 |
| UC52 | E01, E23 |
| UC53, UC54 | E24, E25 |

E00 (ouverture) est le seul écran sans cas : c'est l'identité de
l'application, pas une fonction.

## 8. Les choix faits là où le cahier ne dit rien

À valider par le groupe :

1. **On peut regarder sans compte.** Le visiteur parcourt le flux, la carte,
   et peut lancer « Y aller » ; publier, réagir, commenter et télécharger
   l'original demandent un compte.
2. **Les réactions rapides** sont quatre : J'aime, Waou, Envie d'y aller,
   Merci. Le cahier dit seulement « réagir rapidement ».
3. **Rien n'est refusé pour une information manquante** : le membre la
   complète, et le badge passe de « Capture vérifiée » à « Informations
   déclarées par l'auteur » (section 3). Un contenu douteux part dans la file
   de validation humaine ; un fichier qui porte des signes de génération par
   IA est refusé.
4. **Le modérateur est un membre** avec un rôle de plus, dans la même
   application (écrans E24 et E25), et non un back-office séparé.
5. **La recherche est libre** : un champ unique cherche dans les lieux, les
   contenus (légendes, mots-clés) et les créateurs ; les filtres de lieu
   s'appliquent aussi aux résultats.
6. **Le montage d'un reel reste fidèle au réel** : couper, réordonner, texte,
   son d'origine, voix off, musique libre de droits. Pas de filtre beauté, pas
   d'effet ni de décor générés par IA, pas de changement de voix.
7. **Une prise faite avec la caméra USW est la plus sûre** : réglages par
   défaut, sans filtre ; l'application inscrit elle-même l'appareil, le GPS
   et la date à chaque prise, une fois l'autorisation donnée. Une vidéo
   importée est lue sur ses métadonnées (MP4, MOV : lieu, fabricant,
   modèle, date de création).
