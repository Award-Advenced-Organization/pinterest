"""Fabrique la liste des taches du groupe (taches/taches.html) et l imprime en PDF.

    python outils/taches.py

Chaque tache : code, titre, detail, fini quand, taille (S, M, L), taches prealables.
La colonne Membre reste vide : la repartition se fait a la main.
"""
import pathlib
import subprocess

RACINE = pathlib.Path(__file__).resolve().parent.parent
SORTIE = RACINE / 'taches'
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
POINTS = {'S': 1, 'M': 2, 'L': 4}

# (titre du lot, phrase, [(sous-titre, [(code, titre, detail, fini quand, taille, apres)])])
LOTS = [
    ('Préparation', "À régler avant le premier lot. Certaines tâches se font en réunion.", [
        ('Groupe', [
            ('T01', "Choisir l'hébergement", "Où vivront la base MySQL, Redis et les photos (stockage S3 compatible). Comparer 2 ou 3 offres, prix compris.", "Le choix est écrit dans ARCHITECTURE.md, section 12.", 'S', ''),
            ('T02', 'Créer le projet Firebase', "Pour les notifications push (FCM). Ajouter l'application Android, récupérer google-services.json.", 'Le fichier est partagé au groupe, hors du dépôt.', 'S', 'T01'),
            ('T03', 'Créer les identifiants Google', "Console Google Cloud : identifiant client Android (avec l'empreinte SHA-1 de chaque poste) et identifiant web, pour la connexion Google.", "Les identifiants sont notés dans le .env.example, sans secret.", 'S', ''),
            ('T04', 'Mettre PHP à jour sur chaque poste', "PHP 8.5.12 au minimum (failles php2shell). Ajouter session.upload_progress.enabled = 0 et fatal_error_backtraces = 0 au php.ini.", 'php -v affiche 8.5.12 ou plus sur les postes de tous les membres.', 'S', ''),
            ('T05', 'Fixer les règles Git', "Une branche par tâche, partie de USW (tache/B13-connexion-email) ; demande de fusion vers USW relue par un autre membre ; protéger la branche USW.", 'Les règles sont dans le README et la branche est protégée.', 'S', ''),
            ('T06', 'Intégrer le logo officiel', "Icône de l'application, écran d'ouverture (E00), maquette et cahier des charges.", "Le logo apparaît sur le téléphone et dans les documents.", 'S', 'M01'),
            ('T07', 'Rédiger les textes définitifs', "Conditions générales, politique de confidentialité, règles communautaires, aide. La maquette en donne la structure (E23, E34, E35, E38).", 'Les textes sont relus par le groupe et servis par l\'API.', 'M', ''),
        ]),
    ]),
    ('Lot 0 · Socle', "Le squelette des deux projets. Prêt quand l'API répond, que les tests passent et que l'application démarre sur le téléphone.", [
        ('Backend (Laravel)', [
            ('B01', 'Créer le projet usw_api', "composer create-project laravel/laravel:^13.0 usw_api, à côté de pinterest_api. composer.json exige \"php\": \"~8.4.27 || ^8.5.12\". Base MySQL, .env.example complet.", 'php artisan serve répond et /up est vert.', 'S', 'T04'),
            ('B02', 'Installer Sanctum et la version 1', "php artisan install:api ; toutes les routes sous /api/v1 ; CORS pour l'application.", 'Une route de test protégée renvoie 401 sans jeton.', 'S', 'B01'),
            ('B03', 'Un seul format d\'erreur', "{ \"message\", \"erreurs\" } pour 401, 403, 404, 409, 413, 422, 429 ; messages de validation en français.", 'Un test par code d\'erreur.', 'M', 'B02'),
            ('B04', 'Commande usw:verifier-php', "Échoue si la version de PHP est vulnérable. Lancée au déploiement et dans l'intégration continue.", 'Testée avec une fausse version vulnérable.', 'S', 'B01'),
            ('B05', 'Tests et intégration continue', "PHPUnit avec SQLite en mémoire, Pint, GitHub Actions : tests, style et version de PHP à chaque demande de fusion.", 'Une demande de fusion affiche les vérifications au vert.', 'M', 'B01'),
            ('B06', 'Services remplaçables', "Interfaces StockageMedias (disque medias local ou S3), VerificateurJetonGoogle, EnvoyeurPush, déclarées dans un Service Provider, avec leurs doubles pour les tests.", 'Les tests tournent sans réseau.', 'M', 'B01'),
            ('B07', 'Limites de débit', "RateLimiter nommés : connexion, code e-mail, envoi, commentaires, signalements.", 'Un test atteint la limite et reçoit 429.', 'S', 'B02'),
        ]),
        ('Application (Flutter)', [
            ('M01', "Préparer l'application USW", "Partir de pinterest_mobile : nom USW, identifiant du paquet, icône ; retirer les écrans Pinterest non repris ; ranger le code par fonctionnalité.", "L'application USW démarre sur le Camon 50 Pro.", 'M', ''),
            ('M02', 'Thème et verre', "Couleurs, rayons et espacements de maquette/styles/tokens.css ; police Wura Mi ; composants en verre (verre.css, bouton-verre.css).", 'Un écran de démonstration reprend les éléments de la maquette.', 'L', 'M01'),
            ('M03', "Pack d'icônes", "Les 65 icônes de pack-icones/ en SVG dans les assets, un widget Icone unique.", 'Toutes les icônes s\'affichent sur un écran de contrôle.', 'S', 'M01'),
            ('M04', 'Client API', "Adresse de l'API configurable, jeton Sanctum gardé dans un stockage sécurisé, affichage des erreurs { message, erreurs }, retour à l'entrée sur 401.", "Un appel à /up et une erreur 422 sont bien affichés.", 'M', 'M01'),
            ('M05', 'Navigation et onglets', "Barre d'onglets en verre (Accueil, Reels, +, Carte, Profil), routes nommées, retour arrière Android.", 'On passe d\'un onglet à l\'autre sans perdre le défilement.', 'M', 'M02'),
            ('M06', 'Composants communs', "Boutons, champs, feuilles du bas, bulle de message, fenêtre de confirmation, états vide, erreur et hors ligne (E37).", 'Chaque composant est utilisé sur un écran de démonstration.', 'L', 'M02'),
            ('M07', 'Mouvement', "Courbes et durées de MOUVEMENT.md ; le réglage « réduire les animations » coupe tout.", 'Les transitions suivent la charte, réglage système compris.', 'S', 'M05'),
        ]),
    ]),
    ('Lot 1 · Compte', "Inscription, connexion, profil. Prêt quand E01, E02, E36, E18 et E21 marchent sur le téléphone avec la vraie API.", [
        ('Backend (Laravel)', [
            ('B10', 'Table et modèle Utilisateur', "ulid, email unique, fournisseur (email, google), google_sub, mot de passe nul possible, nom d'utilisateur, avatar, pays, ville, rôle ; factory.", 'Migration, modèle et factory testés.', 'S', 'B02'),
            ('B11', "Vérifier si l'e-mail existe", "POST auth/email : répond seulement existe ou non, jamais le nom ni la photo ; limite de 10 par minute et par adresse IP.", 'Tests : connu, inconnu, limite atteinte.', 'S', 'B10, B07'),
            ('B12', 'Inscription et code e-mail', "POST auth/inscription puis POST auth/code. Code à 6 chiffres haché, valable 10 minutes, 5 essais ; e-mail envoyé en file d'attente.", 'Tests : bon code, mauvais code, code expiré.', 'M', 'B11'),
            ('B13', 'Connexion par e-mail', "POST auth/connexion : jeton Sanctum de 30 jours ; 5 essais puis pause de 15 minutes ; POST auth/deconnexion.", 'Tests : succès, erreur, blocage, déconnexion.', 'M', 'B10'),
            ('B14', 'Connexion avec Google', "POST auth/google : vérifier la signature du jeton d'identité, l'émetteur, l'audience et l'expiration ; créer ou retrouver le compte.", 'Tests avec un vérificateur simulé, jeton faux refusé.', 'M', 'B06, T03'),
            ('B15', 'Mot de passe oublié', "POST auth/oubli et POST auth/nouveau-mot-de-passe ; changer de mot de passe révoque tous les jetons.", 'Tests : parcours complet, anciens jetons refusés.', 'M', 'B12'),
            ('B16', 'Mon compte', "GET et PATCH moi, POST moi/avatar (ré-encodé en WebP), suppression du compte et de ses données.", 'Tests, dont la Policy : impossible de modifier un autre compte.', 'M', 'B13, B06'),
        ]),
        ('Application (Flutter)', [
            ('M10', 'Ouverture et bienvenue', "E00 puis les trois écrans de bienvenue qui avancent seuls (E01) ; Créer un compte, Se connecter, Explorer sans compte.", 'Conforme à la maquette, sur téléphone et tablette.', 'M', 'M06'),
            ('M11', 'Entrée par e-mail', "E02 : e-mail, mot de passe, créer le mot de passe, code, mot de passe oublié, nouveau mot de passe, erreur de mot de passe (E37).", 'Tout le parcours marche avec l\'API.', 'L', 'M04, B12, B13, B15'),
            ('M12', 'Continuer avec Google', "google_sign_in, envoi du jeton d'identité à l'API.", 'Connexion réussie avec un compte Google réel.', 'M', 'M04, B14'),
            ('M13', 'Compléter le profil', "E36 en trois étapes : photo et noms ; pays, ville, position ; types de lieux aimés.", 'Le profil est enregistré par l\'API.', 'M', 'M11, B16'),
            ('M14', 'Mon profil et réglages', "E18 (publications, collections), modifier le profil, réglages (E21) : données mobiles, autorisations, se déconnecter, supprimer le compte.", 'Chaque réglage est enregistré.', 'L', 'M13'),
        ]),
    ]),
    ('Lot 2 · Lieux et contenus', "Les données de base. Prêt quand l'accueil affiche de vraies données.", [
        ('Backend (Laravel)', [
            ('B20', 'Pays, villes, lieux', "Tables et modèles ; position POINT SRID 4326 avec index spatial ; type de lieu ; compteur de contenus.", 'Migrations et modèles testés.', 'M', 'B01'),
            ('B21', 'Contenus et captures', "Tables contenus, captures, modeles_telephone, fichiers_originaux, variantes ; relations ; $fillable explicite partout.", 'Diagramme donnees respecté, tests des relations.', 'M', 'B20, B10'),
            ('B22', 'Données de départ', "Seeders tirés de la maquette : lieux du Bénin, créateurs, photos et reels de démonstration.", 'php artisan migrate --seed remplit l\'accueil.', 'M', 'B21'),
            ('B23', 'Lire un lieu et un contenu', "GET lieux/{lieu}, GET lieux/{lieu}/contenus, GET contenus/{contenu} ; ressources JSON ; identifiants ULID.", 'Tests, sans requêtes N+1.', 'M', 'B21'),
            ('B24', 'Modèles de téléphone', "GET modeles-telephone?q= (recherche par début du nom), POST modeles-telephone.", 'Tests : recherche, ajout, doublon refusé.', 'S', 'B21'),
            ('B25', 'Rapprocher une position d\'un lieu', "Service RapprocheurLieu : coordonnées → lieu connu le plus proche, dans un rayon borné.", 'Tests avec des positions réelles.', 'M', 'B20'),
        ]),
        ('Application (Flutter)', [
            ('M20', 'Page Lieu', "E33 : nom, région, nombre de photos, Y aller (ouvre l'application de cartes), onglets Tout, Photos, Reels.", 'Conforme à la maquette, avec l\'API.', 'M', 'M06, B23'),
            ('M21', 'Page Photo', "E05 : image pleine largeur, badge, lieu, appareil, date, Y aller, boutons d'action.", 'Conforme à la maquette, avec l\'API.', 'M', 'M06, B23'),
        ]),
    ]),
    ('Lot 3 · Envoi et vérification', "Le cœur de USW. Prêt quand une photo du Camon 50 Pro est publiée en 3G simulée, coupure comprise.", [
        ('Backend (Laravel)', [
            ('B30', 'Envoi par morceaux', "POST envois, HEAD et PATCH envois/{envoi}, POST envois/{envoi}/terminer ; 409 si le décalage est faux ; type vérifié par sa signature ; empreinte SHA-256 et déduplication.", 'Tests : envoi complet, coupure puis reprise, mauvais morceau.', 'L', 'B21, B06'),
            ('B31', 'Créer et compléter un contenu', "POST contenus (brouillon et ses deux envois : aperçu et original), PATCH (compléter), DELETE ; Policy.", 'Tests, dont l\'accès refusé au contenu d\'un autre.', 'M', 'B30'),
            ('B32', 'Job AnalyserCapture', "Relire les métadonnées, chercher les signes d'IA, contrôler la cohérence ; décider : publié, refusé, à compléter ou file humaine.", 'Un test par décision, avec des fichiers d\'exemple.', 'L', 'B31'),
            ('B33', 'Variantes des photos', "Job GenererVariantesImage : 32, 480, 1 080, 2 160 px en WebP, sRGB, sans métadonnées.", 'Tests : tailles et absence de métadonnées.', 'M', 'B30'),
            ('B34', 'Variantes des reels', "Vidéo ré-encodée en plusieurs débits et image d'affiche, en file medias.", 'Un reel du téléphone est lisible en 3G.', 'L', 'B30'),
            ('B35', 'Original et ménage', "GET contenus/{contenu}/original par lien signé temporaire ; commande usw:purger-envois chaque nuit ; GET moi/envois.", 'Tests ; la commande apparaît dans schedule:list.', 'S', 'B30'),
        ]),
        ('Application (Flutter)', [
            ('M30', 'Créer et autorisations', "E12 (photo, reel, galerie, rappel « pas d'IA ») et E32 (position, modèle du téléphone, caméra, micro), demandées une seule fois.", 'Les refus d\'autorisation sont gérés (E37).', 'M', 'M06'),
            ('M31', 'Photo avec l\'appareil du téléphone', "Ouvrir l'appareil photo natif ; au retour, vérifier que la prise vient d'avoir lieu ; lire modèle, date et GPS du fichier. Noter quels modes du Camon 50 Pro gardent ces informations.", 'Une photo prise revient avec ses informations.', 'L', 'M30'),
            ('M32', 'Caméra USW pour les reels', "E27 : plein écran, durée 15, 30 ou 60 s, séquences, minuterie, retourner la caméra.", 'Un reel de plusieurs séquences est filmé.', 'L', 'M30'),
            ('M33', 'Monter le reel', "E28 (couper, réordonner, texte) et E29 (son d'origine, voix off, musique libre).", 'Le reel monté est exporté en un fichier.', 'L', 'M32'),
            ('M34', 'Publier', "E14 (détails), E15 (compléter : modèle de téléphone, date, lieu), E30 (indiquer le lieu sur la carte), E37 (publication refusée).", 'Les trois cas d\'AnalyserCapture sont affichés.', 'L', 'M31, B31, B24'),
            ('M35', 'Envoi en arrière-plan', "Aperçu WebP 2 160 px d'abord, original ensuite (Wi-Fi de préférence) ; morceaux de 256 Ko à 2 Mo ; reprise après coupure ; E16 et Mes envois (E26).", 'Coupure du réseau en plein envoi, puis reprise sans tout renvoyer.', 'L', 'M34, B30'),
        ]),
    ]),
    ('Lot 4 · Exploration', "Regarder les lieux. Prêt quand E03, E04, E06, E11, E31 et E33 marchent avec la vraie API.", [
        ('Backend (Laravel)', [
            ('B40', 'Accueil Découverte en piles', "GET flux/decouverte : des lieux avec leurs 4 meilleures photos ; pagination par curseur ; cache de 60 s vidé à chaque publication.", 'Tests ; pas de N+1 (preventLazyLoading).', 'M', 'B23'),
            ('B41', 'Abonnements, Près de moi, filtres', "GET flux/abonnements, GET flux/pres-de-moi (ST_Distance_Sphere, rayon borné) ; filtres pays, ville, type, distance, captures vérifiées.", 'Tests avec des positions réelles.', 'M', 'B40, B53'),
            ('B42', 'Fil des reels', "GET reels, pagination par curseur.", 'Tests.', 'S', 'B23'),
            ('B43', 'Carte', "GET carte?zone= : contenus d'un rectangle, regroupés quand ils sont nombreux.", 'Tests ; réponse rapide sur 10 000 contenus de test.', 'M', 'B23'),
            ('B44', 'Recherche', "GET recherche?q= : lieux, contenus, créateurs.", 'Tests, recherche vide comprise.', 'M', 'B23'),
        ]),
        ('Application (Flutter)', [
            ('M40', 'Accueil en piles', "E03 : onglets Découverte, Abonnements, Près de moi ; piles qui défilent ; défilement infini.", 'Fluide sur le Camon 50 Pro, conforme à la maquette.', 'L', 'M05, B40'),
            ('M41', 'Filtres', "E04 : feuille de filtres, « Voir N lieux » avant de valider.", 'Les filtres changent l\'accueil.', 'M', 'M40, B41'),
            ('M42', 'Fil des reels', "E06 : plein écran, glisser vers le haut, lecture muette, badge, lieu, appareil, Y aller.", 'Lecture fluide, la vidéo suivante est préchargée.', 'L', 'M05, B42'),
            ('M43', 'Carte des reels', "E11 : vignettes posées sur leur lieu, groupes chiffrés, filtres, aperçu en bas, ma position.", 'La carte suit les données de l\'API.', 'L', 'M05, B43'),
            ('M44', 'Recherche', "E31 : récents, onglets Lieux, Contenus, Créateurs, recherche sans résultat (E37).", 'Conforme à la maquette, avec l\'API.', 'M', 'M05, B44'),
        ]),
    ]),
    ('Lot 5 · Communauté', "Réagir, commenter, enregistrer, partager. Prêt quand E05, E07, E09, E10, E19 et E20 marchent avec la vraie API.", [
        ('Backend (Laravel)', [
            ('B50', 'Réactions', "PUT et DELETE contenus/{contenu}/reaction (4 types, une par membre), GET la liste par type ; compteurs tenus par un observer.", 'Tests, compteurs compris.', 'M', 'B23'),
            ('B51', 'Commentaires', "Lire, écrire, modifier, supprimer ; réponses, commentaire épinglé, mentions @, commentaire masqué ; Policy.", 'Tests, dont la suppression par un autre membre refusée.', 'M', 'B23'),
            ('B52', 'Collections', "GET et POST collections, ajouter et retirer un contenu ; collection secrète visible de son seul auteur.", 'Tests, dont une collection secrète demandée par un autre.', 'M', 'B23'),
            ('B53', 'Abonnements', "PUT et DELETE utilisateurs/{utilisateur}/abonnement ; profil public d'un créateur.", 'Tests.', 'S', 'B10'),
        ]),
        ('Application (Flutter)', [
            ('M50', 'Réactions', "Appui long sur le cœur pour les quatre réactions, liste des réactions par type ; photo et reel.", 'Conforme à la maquette, avec l\'API.', 'M', 'M21, B50'),
            ('M51', 'Commentaires', "E07 et feuille des reels : réponses, « Réponse à », suggestions de @mentions, épinglé.", 'Conforme à la maquette, avec l\'API.', 'M', 'M21, B51'),
            ('M52', 'Enregistrer et collections', "E09 (feuille Enregistrer, créer une collection) et E19 (page Collection).", 'Conforme à la maquette, avec l\'API.', 'M', 'M21, B52'),
            ('M53', 'Partager et télécharger', "E10 (lien, WhatsApp, autres applications) et E08 (original ou taille écran, avertissement en 3G, attendre le Wi-Fi).", 'Partage réel vers WhatsApp ; fichier téléchargé.', 'M', 'M21, B35'),
            ('M54', "Profil d'un créateur", "E20 : ses contenus, s'abonner, bloquer, signaler.", 'Conforme à la maquette, avec l\'API.', 'M', 'M21, B53'),
        ]),
    ]),
    ('Lot 6 · Modération', "Garder USW propre. Prêt quand E22, E23, E24 et E25 marchent avec la vraie API.", [
        ('Backend (Laravel)', [
            ('B60', 'Signalements et blocages', "POST signalements (6 motifs, anonyme pour l'auteur), POST utilisateurs/{utilisateur}/blocage.", 'Tests ; l\'auteur du signalement n\'apparaît jamais.', 'M', 'B23'),
            ('B61', 'File et décisions', "GET moderation/file classée par urgence, POST moderation/{contenu}/decision ; rôle modérateur (Gate et middleware) ; décision notifiée à l'auteur.", 'Tests, dont l\'accès refusé à un membre ordinaire.', 'M', 'B60, B32'),
            ('B62', 'Règles et pages', "GET regles et textes des CGU, de la confidentialité et de l'aide.", 'Tests.', 'S', 'T07'),
        ]),
        ('Application (Flutter)', [
            ('M60', 'Signaler et règles', "E22 (feuille Signaler) et E23 (règles communautaires).", 'Conforme à la maquette, avec l\'API.', 'S', 'M06, B60'),
            ('M61', 'Écrans de modération', "E24 (file) et E25 (décision), visibles pour un modérateur seulement.", 'Une décision prise sur le téléphone est enregistrée.', 'M', 'M06, B61'),
            ('M62', 'Aide et documents', "E35 (aide), E34 (CGU), E38 (confidentialité).", 'Les textes viennent de l\'API.', 'S', 'B62'),
        ]),
    ]),
    ('Lot 7 · Notifications', "Prêt quand une réaction sur un téléphone fait sonner un autre téléphone.", [
        ('Backend (Laravel)', [
            ('B70', 'Notifications', "Canal database et push FCM ; GET notifications, POST notifications/lues, POST appareils (jeton push) ; envoi en file d'attente.", 'Tests avec un EnvoyeurPush simulé.', 'M', 'B06, T02, B50'),
        ]),
        ('Application (Flutter)', [
            ('M70', 'Centre de notifications et push', "E17 ; firebase_messaging ; un appui sur une notification ouvre le bon écran.", 'Notification reçue téléphone fermé.', 'M', 'M05, B70'),
        ]),
    ]),
    ('Lot 8 · Production', "Mettre USW en ligne. Prêt quand toute la section 9 d'ARCHITECTURE.md est cochée.", [
        ('Groupe', [
            ('B80', 'Revue des performances', "Requêtes lentes, index utiles, cache, taille des réponses.", 'Accueil sous 300 ms côté serveur avec les données de test.', 'M', 'Lots 1 à 7'),
            ('B81', 'Revue de sécurité', "Liste de la section 9 et de la Partie 27 du cours : validation, Policies, $fillable, secrets, limites, fichiers reçus.", 'Chaque point est vérifié et noté.', 'M', 'Lots 1 à 7'),
            ('B82', 'Déploiement', "Nginx, PHP-FPM 8.5.12, Supervisor (files medias et defaut), crontab, sauvegarde quotidienne de la base, HTTPS.", 'L\'API répond en HTTPS sur le serveur choisi.', 'L', 'T01, B81'),
            ('M80', 'Essais sur les téléphones', "Camon 50 Pro, autres téléphones du groupe, tablette ; 3G simulée ; hors ligne.", 'Liste de scénarios passée sans erreur.', 'M', 'Lots 1 à 7'),
            ('M81', 'Version de diffusion', "APK signé, nom et icône définitifs, adresse de l'API de production.", "L'APK s'installe sur un téléphone neuf.", 'S', 'B82'),
            ('T10', 'Rapport et soutenance', "Mettre à jour le cahier des charges, rédiger le rapport final, préparer la démonstration.", 'Rapport relu par tout le groupe.', 'M', ''),
        ]),
    ]),
]


def e(t):
    return t.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def points(taches):
    return sum(POINTS[t[4]] for t in taches)


toutes = [t for _, _, parts in LOTS for _, ts in parts for t in ts]
codes = [t[0] for t in toutes]
assert len(codes) == len(set(codes)), 'code en double'

recap = ''.join(
    f'<tr><td>{e(titre)}</td><td class="n">{sum(len(ts) for _, ts in parts)}</td>'
    f'<td class="n">{sum(points(ts) for _, ts in parts)}</td></tr>'
    for titre, _, parts in LOTS)
recap += f'<tr class="total"><td>Total</td><td class="n">{len(toutes)}</td><td class="n">{points(toutes)}</td></tr>'

corps = ''
for titre, phrase, parts in LOTS:
    n = sum(len(ts) for _, ts in parts)
    p = sum(points(ts) for _, ts in parts)
    corps += f'<section class="lot"><h2>{e(titre)}</h2><p class="phrase">{e(phrase)} <span class="compte">{n} tâches · {p} points</span></p>'
    for sous, ts in parts:
        lignes = ''.join(
            f'<tr><td class="code">{c}</td>'
            f'<td><strong>{e(ti)}</strong><div class="detail">{e(de)}</div><div class="fini"><b>Fini quand :</b> {e(fi)}</div></td>'
            f'<td class="taille">{ta}</td><td class="apres">{e(ap) or "–"}</td><td class="membre"></td></tr>'
            for c, ti, de, fi, ta, ap in ts)
        corps += (f'<h3>{e(sous)}</h3><table class="taches"><thead><tr><th>Code</th><th>Tâche</th>'
                  f'<th>Taille</th><th>Après</th><th>Membre</th></tr></thead><tbody>{lignes}</tbody></table>')
    corps += '</section>'

grille = ''.join('<tr><td></td><td></td><td></td></tr>' for _ in range(8))

html = f'''<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>USW · Tâches à accomplir</title>
<style>
  @page {{ size: A4; margin: 16mm 14mm 18mm; @bottom-center {{ content: counter(page); font: 8.5pt "Segoe UI", Arial, sans-serif; color: #555; }} }}
  :root {{ --encre: #1b1b1b; --discret: #5b6170; --olive: #7d8c2a; --lime: #c9d47a; --lime-clair: #dde5a8; --creme: #fafde9; --bord: #d4d4d4; }}
  * {{ box-sizing: border-box; }}
  html {{ font-family: "Segoe UI", Arial, sans-serif; color: var(--encre); font-size: 9.5pt; line-height: 1.4; }}
  body {{ margin: 0; }}
  .surtitre {{ font-size: 7.5pt; font-weight: 700; letter-spacing: .32em; text-transform: uppercase; color: var(--olive); margin: 0 0 4pt; }}
  h1 {{ font-size: 22pt; margin: 0 0 6pt; padding-bottom: 8pt; border-bottom: 1.5px solid var(--lime); }}
  h2 {{ font-size: 13pt; margin: 0 0 3pt; break-after: avoid; }}
  h3 {{ font-size: 10pt; margin: 9pt 0 3pt; color: var(--discret); break-after: avoid; }}
  p {{ margin: 0 0 7pt; }}
  ul {{ margin: 0 0 8pt; padding-left: 14pt; }} li {{ margin-bottom: 2pt; }}
  .chapeau {{ color: var(--discret); margin-bottom: 12pt; }}
  .encart {{ background: var(--creme); border-left: 3px solid var(--lime); padding: 8pt 11pt; margin: 8pt 0 12pt; break-inside: avoid; }}
  .encart p:last-child, .encart ul:last-child {{ margin-bottom: 0; }}
  table {{ width: 100%; border-collapse: collapse; margin: 4pt 0 8pt; }}
  tr {{ break-inside: avoid; }}
  th, td {{ border: 1px solid var(--bord); padding: 4pt 6pt; vertical-align: top; text-align: left; }}
  thead th {{ background: var(--lime-clair); font-weight: 700; }}
  td.n {{ text-align: right; width: 18%; }}
  tr.total td {{ font-weight: 700; background: var(--creme); }}
  .colonnes {{ display: grid; grid-template-columns: 1fr 1fr; gap: 14pt; }}
  .lot {{ break-before: page; }}
  .phrase {{ color: var(--discret); }}
  .compte {{ white-space: nowrap; color: var(--olive); font-weight: 700; }}
  table.taches {{ font-size: 8.8pt; }}
  table.taches th:nth-child(1) {{ width: 9%; }}
  table.taches th:nth-child(3) {{ width: 8%; }}
  table.taches th:nth-child(4) {{ width: 13%; }}
  table.taches th:nth-child(5) {{ width: 19%; }}
  td.code {{ font-weight: 700; color: var(--olive); white-space: nowrap; }}
  td.taille {{ text-align: center; font-weight: 700; }}
  td.apres {{ font-size: 8pt; color: var(--discret); }}
  .detail {{ margin-top: 2pt; }}
  .fini {{ margin-top: 3pt; font-size: 8.3pt; color: var(--discret); }}
  .grille td {{ height: 26pt; }}
  .saut {{ break-before: page; }}
</style>
</head>
<body>
<p class="surtitre">USW · United State of World · Groupe 4</p>
<h1>Tâches à accomplir</h1>
<p class="chapeau">Version du 22 octobre 2026. Tout le travail du code, du socle à la mise en ligne,
découpé en tâches à répartir entre les membres. Les détails techniques sont dans
<b>conception-usw/analyse/ARCHITECTURE.md</b>, les écrans (E00 à E38) dans la maquette, sur la branche USW.</p>

<div class="colonnes">
  <div>
    <h3>Lire une tâche</h3>
    <ul>
      <li><b>Code</b> : T pour le groupe, B pour le backend Laravel, M pour l'application Flutter. Le chiffre des dizaines est le lot.</li>
      <li><b>Taille</b> : S, environ une demi-journée (1 point) ; M, un à deux jours (2 points) ; L, trois à cinq jours (4 points).</li>
      <li><b>Après</b> : les tâches à finir avant de la commencer.</li>
      <li><b>Fini quand</b> : ce qu'il faut montrer pour la déclarer terminée.</li>
      <li><b>Membre</b> : à remplir à la répartition.</li>
    </ul>
  </div>
  <div>
    <h3>Les lots</h3>
    <table><thead><tr><th>Lot</th><th>Tâches</th><th>Points</th></tr></thead><tbody>{recap}</tbody></table>
  </div>
</div>

<div class="encart">
  <p class="surtitre">Règles pour tous</p>
  <ul>
    <li>On avance lot par lot, comme dans le TP : chaque tâche est testée avant la suivante.</li>
    <li>Une tâche backend suit toujours le même ordre : migration, modèle, factory, Form Request, service ou action, contrôleur, ressource JSON, Policy, route, tests.</li>
    <li>Une tâche mobile peut commencer avant sa tâche backend, avec des données simulées au format de l'API (section 8 d'ARCHITECTURE.md), puis se brancher sur la vraie API.</li>
    <li>Une branche par tâche, partie de USW ; une demande de fusion relue par un autre membre ; tests au vert avant de fusionner.</li>
    <li>PHP 8.5.12 au minimum sur chaque poste ; aucun secret (.env, clés) dans le dépôt.</li>
  </ul>
</div>

<p>Pour équilibrer la charge, il vaut mieux qu'un membre ait le backend et le mobile d'une même
fonction (par exemple B13 et M11) : il connaît les deux côtés de l'échange.</p>

{corps}

<section class="saut">
  <p class="surtitre">Répartition</p>
  <h2>Qui fait quoi</h2>
  <table class="grille"><thead><tr><th style="width:26%">Membre</th><th>Tâches</th><th style="width:12%">Points</th></tr></thead><tbody>{grille}</tbody></table>
</section>
</body>
</html>
'''

SORTIE.mkdir(exist_ok=True)
page = SORTIE / 'taches.html'
page.write_text(html, encoding='utf-8')
pdf = SORTIE / 'USW_Taches_Groupe4.pdf'
subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                f'--print-to-pdf={pdf}', page.as_uri()], check=True, capture_output=True)
print(f'{len(toutes)} tâches, {points(toutes)} points -> {pdf}')
