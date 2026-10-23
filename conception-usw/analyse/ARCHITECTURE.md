# USW : architecture du backend

Ce document fixe l'architecture du backend de USW avant d'écrire la première ligne de code.
Il complète `ANALYSE.md` (acteurs, cas d'utilisation, écrans) et le diagramme de classes.
Les figures sont dans `analyse/architecture.puml`, rendues dans `analyse/rendus/`.

Il suit la méthode du cours **Projet d'initiation aux frameworks avec Laravel**
(IFRI, GL3, Mme Maryse GAHOU, support du 13 octobre 2026, TP du 19 octobre 2026) :
les numéros « Partie n » renvoient à ce support.

Version du 22 octobre 2026.

---

## 1. Les choix de départ

| Sujet | Choix | Pourquoi |
|---|---|---|
| Framework | **Laravel 13** | Dernière version stable, correctifs de sécurité jusqu'au 17 mars 2028 (Partie 2.5) |
| PHP | **8.5.12 au minimum** (ou 8.4.27) | Versions qui corrigent *php2shell* (section 9) |
| Base de données | **MySQL 8.4** (ou MariaDB 11.4) ; SQLite en mémoire pour les tests | Base du TP ; index spatiaux pour « Près de moi » et la carte |
| Cache, files d'attente, limites de débit | Fichiers et base en développement ; **Redis** en production | Partie 15.2 et Partie 18 |
| Fichiers | Disque `medias` : local en développement, **Cloudflare R2** en production (pilote `s3` de Laravel, adresse R2) ; les versions publiques passent par le réseau de Cloudflare | Abstraction des disques (Partie 23). R2 ne fait pas payer la sortie des données : décisif pour une application de photos. Gratuit jusqu'à 10 Go, 1 million d'écritures et 10 millions de lectures par mois |
| E-mails | **Resend** (codes de vérification, mot de passe oublié), en file d'attente | Gratuit jusqu'à 3 000 e-mails par mois et 100 par jour ; un domaine vérifié pour écrire à toutes les adresses |
| Authentification | **Sanctum, jetons personnels** pour l'application mobile | Une application mobile utilise des jetons, jamais le mode cookie (Partie 21) |
| Connexion Google | L'application obtient un jeton d'identité Google ; l'API **vérifie sa signature**, son émetteur, son audience et son expiration | Pas de redirection web dans une application mobile |
| Tests | **PHPUnit**, tests unitaires et *feature tests*, `RefreshDatabase`, *factories* | Partie 22 |
| Style de code | Laravel Pint | Un seul style dans le groupe |

**Un monolithe modulaire, pas des microservices.** Pinterest a tenu ses premières années avec une
règle : « keep it simple » ; son équipe a ajouté des bases et des serveurs seulement quand la charge
l'imposait ([Scaling Pinterest, QCon 2012](https://qconsf.com/sf2012/sf2012/presentation/Scaling+Pinterest.html)).
USW démarre en un seul projet Laravel, découpé en modules qui ne se parlent que par leurs services.
Un module pourra partir dans un service séparé le jour où il le faudra, sans réécrire les autres.

**Des identifiants publics non devinables.** Pinterest code dans chaque identifiant de 64 bits le
numéro de la base qui le porte (16 bits), le type de donnée (10 bits) et le rang local (36 bits)
([Sharding Pinterest](https://highscalability.com/scaling-pinterest-from-0-to-10s-of-billions-of-page-views-a/)).
USW prend l'idée à son échelle : chaque ressource exposée a un **ULID** (trait `HasUlids`).
Il est trié par date, ne révèle pas le nombre de contenus, ne se devine pas d'un voisin à l'autre,
et pourra un jour porter un numéro de base. La clé primaire interne reste un entier auto-incrémenté.

---

## 2. Vue d'ensemble (figure *archi-composants*)

```
Application Flutter (téléphone, tablette)
   │  HTTPS, JSON, jeton Sanctum
   ▼
Nginx ──► PHP-FPM 8.5.12 ──► API Laravel 13 (monolithe modulaire)
                               │        │          │
                               ▼        ▼          ▼
                            MySQL     Redis     Disque « medias » (S3) ──► CDN (versions WebP)
                               ▲        │
                               │        ▼
                      Workers de file d'attente (variantes, analyse, notifications)
                      Planificateur (une entrée crontab, Partie 24)

Services extérieurs : Google (vérification du jeton), Resend (e-mails), Cloudflare R2 (photos et vidéos), FCM (notifications push),
l'application de cartographie du téléphone (« Y aller » : aucun appel du serveur).
```

Ce que fait le téléphone, et non le serveur :
- **lire les métadonnées** du fichier (EXIF), avant tout envoi ;
- **fabriquer la version légère** (WebP 2 160 px, ~400 Ko) envoyée en premier en 3G ;
- **ouvrir l'application de cartographie** pour « Y aller ».

Le serveur relit les métadonnées du fichier reçu : il ne fait jamais confiance au seul téléphone.

---

## 3. Les modules

| Module | Ce qu'il porte | Cas d'utilisation |
|---|---|---|
| **Compte** | Inscription, connexion e-mail et Google, code e-mail, profil, abonnements, blocages, jetons | UC01, UC02, UC03, UC45, UC51 |
| **Dépôt** | Contenus (photo, reel), informations de capture, modèles de téléphone, fichiers originaux, variantes | UC10 à UC14, UC27 |
| **Envoi** | Envoi par morceaux reprenable, en deux temps, suivi des envois | UC15, UC16, UC17 |
| **Lieux** | Pays, villes, lieux, rapprochement des coordonnées, recherche de lieu | UC22, UC30 |
| **Exploration** | Accueil en piles, fil de reels, Près de moi, filtres, carte, recherche | UC20 à UC26, UC31 |
| **Communauté** | Réactions, commentaires, mentions, collections, partage | UC40 à UC48 |
| **Modération** | Signalements, file de validation, décisions, règles | UC50, UC52, UC53, UC54 |
| **Notifications** | Centre de notifications, push | UC46 |

---

## 4. L'organisation du code (Partie 4)

Les contrôleurs restent fins : ils reçoivent la requête validée, appellent un service ou une
action, renvoient une ressource. La logique métier ne vit jamais dans un contrôleur.

```
app/
├── Http/
│   ├── Controllers/Api/V1/     Un contrôleur par ressource : ContenuController, EnvoiController…
│   ├── Requests/               Form Requests : validation et autorisation (Partie 10)
│   ├── Resources/              Ressources JSON exposées à l'application
│   └── Middleware/             VerifierRole, ExigerPhpCorrige (section 9)
├── Models/                     Modèles Eloquent, $fillable explicite partout (Partie 27.2)
├── Policies/                   ContenuPolicy, CommentairePolicy, CollectionPolicy… (Partie 20)
├── Services/                   Logique métier réutilisable, hors HTTP
│   ├── Capture/                LecteurMetadonnees, DetecteurSignesIA, ControleCoherence
│   ├── Envoi/                  ReceveurMorceaux, AssembleurFichier
│   ├── Lieux/                  RapprocheurLieu (coordonnées → lieu)
│   └── Flux/                   ConstructeurFlux, ClassementDecouverte
├── Actions/                    Une action métier par classe : PublierContenu, ReagirAContenu…
├── Jobs/                       AnalyserCapture, GenererVariantesImage, GenererVariantesVideo…
├── Events/  Listeners/         ContenuPublie → NotifierAbonnes, MettreAJourLieu… (Partie 14)
├── Notifications/              NouvelleReaction, ContenuRefuse… (base + push, Partie 17)
├── Observers/                  Mise à jour des compteurs (réactions, commentaires)
├── Rules/                      Règles de validation : CoordonneesValides, ModeleTelephoneConnu…
└── Console/Commands/           usw:purger-envois, usw:verifier-php…
```

Conventions (Partie 4.2) : modèles au singulier en PascalCase, tables au pluriel en snake_case,
noms métier en français comme dans le diagramme de classes (`Contenu` → `contenus`).

Les liaisons d'interfaces se déclarent dans des *Service Providers* (Parties 12 et 13) :
`StockageMedias` (local ou S3), `VerificateurJetonGoogle`, `EnvoyeurPush`. Les tests remplacent
ces implémentations par des doubles, sans toucher au code métier.

---

## 5. Le trajet d'une requête (figure *archi-requete*, Partie 3)

```
Requête HTTPS
 → public/index.php
 → middlewares globaux : TrustProxies, gestion CORS, taille maximale du corps
 → routeur : /api/v1/…
 → middlewares de route : throttle (limites par route), auth:sanctum, SubstituteBindings
 → Form Request : authorize() (Policy) puis rules()
 → contrôleur → action ou service → modèles Eloquent (chargement anticipé, Partie 7)
 → ressource JSON
 → réponse ; le travail lent part en file d'attente (Partie 15)
```

Une seule forme d'erreur, que l'application affiche telle quelle :

```json
{ "message": "Mot de passe incorrect.", "erreurs": { "mot_de_passe": ["Encore 4 essais."] } }
```

Codes : 401 non connecté, 403 interdit (Policy), 404 introuvable, 409 conflit (morceau déjà
reçu), 413 trop gros, 422 validation, 429 trop de requêtes. `APP_DEBUG=false` hors du poste de
développement (Partie 27.3).

---

## 6. Les traitements clés

### 6.1 Se connecter (figure *seq-connexion*)

- **Par e-mail.** L'application envoie l'e-mail. Si un compte existe, elle demande le mot de passe
  (écran sans nom ni photo) ; sinon, elle fait créer un mot de passe, puis vérifier un code à
  6 chiffres reçu par e-mail.
  - Le code est **haché** en base, valable 10 minutes, 5 essais au plus.
  - Le mot de passe est haché par `Hash::make` (bcrypt, coût par défaut de Laravel 13).
- **Avec Google.** L'application obtient un jeton d'identité Google. L'API vérifie sa signature
  avec les clés publiques de Google, l'émetteur, l'audience (notre identifiant client) et
  l'expiration, puis crée ou retrouve le compte.
- **Dans les deux cas**, l'API renvoie un jeton Sanctum qui expire après 30 jours sans usage.
  - Changer de mot de passe révoque tous les jetons (Partie 21.4).
  - Le premier jeton ouvre « Compléter le profil ».
- **Limites.**
  - 5 essais de mot de passe par compte, puis une pause de 15 minutes (écran E37).
  - 10 vérifications d'e-mail par minute et par adresse IP.
- **Ce qu'on assume.** Le parcours de Pinterest (e-mail d'abord, puis mot de passe ou création)
  révèle qu'une adresse est inscrite. On le limite :
  - débit strict sur cette vérification ;
  - aucun nom ni aucune photo du compte dans la réponse.

### 6.2 Publier une photo (figures *seq-publication* et *activite-verification*)

1. L'application ouvre l'**appareil photo du téléphone** (ou la galerie), puis lit le fichier
   obtenu : modèle, date, GPS.
2. Elle crée le contenu en **brouillon** avec ces informations et leur origine.
   - `POST /api/v1/contenus` répond par l'identifiant du contenu et deux envois à remplir :
     l'aperçu et l'original.
   - Si une empreinte SHA-256 est déjà connue, cet envoi est marqué « déjà reçu ».
3. **Envoi en deux temps** :
   - l'aperçu léger (WebP 2 160 px) part d'abord ;
   - l'original suit, de préférence en Wi-Fi.
4. Quand l'aperçu est complet, le job **AnalyserCapture** décide, sans écran pour le membre :
   - signes d'IA dans le fichier (logiciel de génération, marque de provenance
     *digitalSourceType* « trainedAlgorithmicMedia ») : **refusé**, avec le motif ;
   - information manquante : le contenu reste en brouillon, l'application ouvre E15 ;
   - incohérence (modèle sorti après la date de prise, date dans le futur, position impossible) :
     **file humaine** ;
   - sinon : **publié**, badge « Capture vérifiée » ou « Informations déclarées ».
5. Le job **GenererVariantesImage** fabrique, à partir de l'aperçu puis de l'original :
   - les versions 32 px (flou), 480, 1 080 et 2 160 px ;
   - en WebP, en sRGB, **sans métadonnées**.
6. L'événement `ContenuPublie` déclenche ses écouteurs : notification des abonnés, mise à jour
   du lieu et de sa pile, invalidation du cache du flux.

### 6.3 Envoyer par morceaux, reprendre après une coupure (figure *seq-envoi*)

Inspiré du protocole *tus* :

| Requête | Rôle |
|---|---|
| `POST /api/v1/envois` | Annonce le fichier : taille, type, empreinte SHA-256. Réponse : identifiant et décalage 0 |
| `HEAD /api/v1/envois/{id}` | Renvoie le décalage déjà reçu (`Upload-Offset`) : c'est la reprise |
| `PATCH /api/v1/envois/{id}` | Un morceau brut (`application/offset+octet-stream`), à partir de `Upload-Offset` |
| `POST /api/v1/envois/{id}/terminer` | Vérifie l'empreinte du fichier assemblé et le range comme `FichierOriginal` |

- Les morceaux font de 256 Ko en 3G à 2 Mo en Wi-Fi. Un morceau dont le décalage ne correspond
  pas est refusé (409) : l'application redemande `HEAD`.
- Le corps d'un morceau est brut et n'est jamais un formulaire : PHP ne le découpe pas en
  `$_POST`, ce qui réduit aussi l'exposition à *php2shell* (section 9).
- Le type réel du fichier est vérifié par sa signature binaire (`finfo`), pas par son extension.
- La commande `usw:purger-envois` supprime chaque nuit les envois abandonnés depuis 7 jours.

### 6.4 Afficher l'accueil en piles (figure *seq-flux*)

- `GET /api/v1/flux/decouverte?curseur=…` renvoie des **lieux**, chacun avec ses 4 meilleures
  photos et leur nombre.
- La pagination se fait par **curseur** (`cursorPaginate`) : stable pendant le défilement infini,
  sans `OFFSET` coûteux.
- Le chargement est anticipé (`with('photos.variantes')`), donc pas de N+1 (Partie 7).
- `Model::preventLazyLoading()` est actif hors production pour attraper les oublis.
- Chaque page de Découverte est gardée **60 secondes** en cache (`Cache::remember`, Partie 18),
  invalidée par l'événement `ContenuPublie`.
- **Près de moi** : colonne `POINT` avec index spatial, `ST_Distance_Sphere`, rayon borné.
- **Abonnements** : jointure sur les créateurs suivis, tri par date.

### 6.5 Signaler et modérer (figure *seq-moderation*)

- Un **signalement** porte un motif parmi six, reste anonyme pour l'auteur du contenu, et reçoit
  une réponse sous 24 heures.
- La **file** classe les dossiers par urgence : score de signes d'IA, nombre de signalements,
  ancienneté.
- La **décision** (publier ou refuser, avec un motif) est enregistrée dans `DecisionModeration`
  et notifiée à l'auteur.
- Seul un modérateur y accède : *Gate* `moderer` et middleware `role:moderateur` (Parties 11
  et 20).

---

## 7. Le modèle physique (figure *donnees*)

Les tables suivent le diagramme de classes. Les points qui comptent :

| Table | Points d'attention |
|---|---|
| `utilisateurs` | `ulid` unique, `email` unique, `fournisseur` (email, google), `google_sub` unique et nul possible, `mot_de_passe` nul possible (compte Google) |
| `contenus` | `ulid`, `type` (photo, reel), `statut`, `badge`, `lieu_id`, `publie_le` ; index (`statut`, `publie_le`) et (`utilisateur_id`, `publie_le`) |
| `captures` | Une par contenu : source, `modele_telephone_id`, date, `position POINT SRID 4326` (index spatial), origine de chaque information |
| `modeles_telephone` | `marque`, `nom` unique ensemble, `ajoute_par`, `nombre_contenus` ; recherche par préfixe |
| `fichiers_originaux` | `empreinte_sha256` unique (déduplication), format, dimensions, poids, chemin **privé** |
| `variantes` | `usage` (flou, 480, 1080, 2160, vidéo, affiche), chemin public, dimensions |
| `envois` | `ulid`, `taille`, `recu`, `empreinte`, `statut`, `derniere_activite` |
| `lieux` | `nom`, `ville_id`, `type`, `position POINT` (index spatial), `nombre_contenus` |
| `reactions` | Clé unique (`utilisateur_id`, `contenu_id`) : une réaction par membre et par contenu |
| `commentaires` | `parent_id` (réponses), `epingle`, `masque` ; mentions dans `mentions` |
| `collections`, `enregistrements` | `secrete` ; clé unique (`collection_id`, `contenu_id`) |
| `signalements`, `decisions_moderation` | Motif, précision, statut ; l'auteur du signalement n'est jamais exposé |
| `notifications` | Table standard de Laravel (canal `database`) |
| `personal_access_tokens` | Table de Sanctum |

Les compteurs (réactions, commentaires, enregistrements) sont tenus à jour par des *observers*
plutôt que recalculés à chaque affichage. Les index se décident à partir des requêtes réelles
(Partie 26.2), pas par précaution.

---

## 8. L'API (version 1)

Toutes les routes sont préfixées par `/api/v1`, en JSON. ✓ signifie qu'un jeton Sanctum est
exigé ; les autres routes sont ouvertes aux visiteurs (regarder sans compte).

| Domaine | Routes |
|---|---|
| Compte | `POST auth/email` (existe ?), `POST auth/inscription`, `POST auth/code`, `POST auth/connexion`, `POST auth/google`, `POST auth/oubli`, `POST auth/nouveau-mot-de-passe`, ✓ `POST auth/deconnexion`, ✓ `GET/PATCH moi`, ✓ `POST moi/avatar` |
| Exploration | `GET flux/decouverte`, ✓ `GET flux/abonnements`, `GET flux/pres-de-moi`, `GET reels`, `GET carte?zone=…`, `GET recherche?q=…`, `GET lieux/{lieu}`, `GET lieux/{lieu}/contenus` |
| Contenus | `GET contenus/{contenu}`, ✓ `POST contenus`, ✓ `PATCH contenus/{contenu}` (compléter), ✓ `DELETE contenus/{contenu}`, ✓ `GET contenus/{contenu}/original` (lien signé temporaire) |
| Envoi | ✓ `POST envois`, ✓ `HEAD/PATCH envois/{envoi}`, ✓ `POST envois/{envoi}/terminer`, ✓ `GET moi/envois` |
| Téléphones | ✓ `GET modeles-telephone?q=…`, ✓ `POST modeles-telephone` |
| Communauté | ✓ `PUT/DELETE contenus/{contenu}/reaction`, `GET contenus/{contenu}/reactions`, `GET contenus/{contenu}/commentaires`, ✓ `POST contenus/{contenu}/commentaires`, ✓ `PATCH/DELETE commentaires/{commentaire}`, ✓ `PUT/DELETE utilisateurs/{utilisateur}/abonnement`, ✓ `GET/POST collections`, ✓ `PUT/DELETE collections/{collection}/contenus/{contenu}` |
| Modération | ✓ `POST signalements`, ✓ `POST utilisateurs/{utilisateur}/blocage`, ✓ `GET moderation/file`, ✓ `POST moderation/{contenu}/decision`, `GET regles` |
| Notifications | ✓ `GET notifications`, ✓ `POST notifications/lues`, ✓ `POST appareils` (jeton push) |

Chaque route qui touche une ressource d'un membre passe par sa **Policy** : on vérifie, à chaque
fois, que la ressource appartient bien à celui qui la demande. C'est la faille d'API la plus
courante (accès à l'objet d'un autre).

---

## 9. Sécurité

### 9.1 *php2shell* : CVE-2026-109618 et CVE-2026-109619 (publiées le 21 octobre 2026)

Deux failles critiques du moteur PHP lui-même (CVSS 9,2). Elles permettent d'exécuter du code à
distance sans être connecté, et touchent **toute installation de PHP qui sert des requêtes web**
(PHP-FPM, mod_php, php-cgi, FrankenPHP, LiteSpeed).
- La première passe par une **corruption de mémoire** pendant la lecture d'un formulaire POST,
  avant même que notre code ne s'exécute.
- La seconde réutilise un **état laissé par une requête précédente** (rapport d'erreur fatale,
  progression d'envoi).

Aucun code Laravel ne peut les bloquer : seule la mise à jour de PHP les corrige
([avis de la CISA](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching),
[analyse de Datadog](https://securitylabs.datadoghq.com/articles/php2shell-critical-vulnerabilities-in-php/)).

Ce que USW en retient :

| Mesure | Où |
|---|---|
| PHP **8.5.12** au minimum (ou 8.4.27, 8.3.36, 8.2.35) ; fait sur le poste de développement le 22 octobre 2026 | Serveurs, intégration continue, postes du groupe |
| `composer.json` exige `"php": "~8.4.27 \|\| ^8.5.12"` : Composer refuse de s'installer sur une version vulnérable | Projet |
| La commande `usw:verifier-php` échoue au déploiement si la version est vulnérable | Déploiement |
| `session.upload_progress.enabled = 0` et `fatal_error_backtraces = 0` (défense en profondeur) | `php.ini` ; fait sur le poste |
| **PHP-FPM derrière Nginx**, jamais mod_php (le cas le plus exposé) | Serveur |
| Nginx limite la taille du corps : 64 Ko sur les routes JSON, 2 Mo sur les morceaux d'envoi ; les noms de champs géants sont refusés avant PHP | Nginx |
| Surveillance : processus PHP qui lancent un shell ; erreurs « Allowed memory size » en « Unknown on line 0 » | Journaux |

### 9.2 Les règles du cours (Partie 27) et celles d'une API

- **Validation côté serveur** dans des Form Requests, avec messages en français (Partie 10).
- **`$fillable` explicite** sur chaque modèle ; jamais `create($request->all())` (Partie 27.2).
- **Autorisation à chaque ressource** : Policies (Partie 20).
- **Requêtes SQL** : Eloquent ou bindings, jamais de concaténation (Partie 9.3).
- **Secrets** dans `.env`, jamais commité ; `APP_DEBUG=false` en production (Partie 27.3).
- **Fichiers reçus** :
  - type vérifié par la signature binaire ;
  - taille bornée ;
  - images ré-encodées en WebP, ce qui élimine tout contenu caché ;
  - originaux privés, servis par lien signé temporaire (`Storage::temporaryUrl`).
- **Limites de débit** par route : connexion, code e-mail, envoi, commentaires, signalements.
- **HTTPS** partout ; les jetons ne sont jamais écrits dans les journaux.
- **Confidentialité** :
  - versions d'affichage sans métadonnées ;
  - coordonnées publiées : celles de la prise de vue, jamais la position en direct ;
  - aucun nom ni aucune photo sur la page du mot de passe.

---

## 10. Production (figure *archi-deploiement*)

- Nginx (TLS) → PHP-FPM 8.5.12 → Laravel ; `php artisan config:cache`, `route:cache`,
  `event:cache` (Partie 26.3).
- Workers de file d'attente sous Supervisor, deux files : `medias` (variantes, vidéo) et
  `defaut` (analyse, notifications) ; `--tries=3`, échecs gardés dans `failed_jobs`
  (Partie 15.3).
- Planificateur : une seule entrée crontab, `schedule:run` chaque minute (Partie 24).
  - Purge des envois abandonnés et des codes expirés.
  - Recalcul horaire du classement de Découverte.
  - `model:prune` et nettoyage des jetons Sanctum expirés.
- MySQL avec sauvegarde quotidienne. Redis pour le cache, les files et les limites de débit.
- Disque S3 compatible pour les médias, versions publiques derrière un CDN.
- Déploiement (Partie 27.4) :
  1. récupérer le code ;
  2. `composer install --no-dev --optimize-autoloader` ;
  3. `php artisan usw:verifier-php` ;
  4. `php artisan migrate --force` ;
  5. reconstruire les caches ;
  6. `php artisan queue:restart`.

---

## 11. Méthode de réalisation (d'après le TP)

Le TP pose la règle : **avancer dans l'ordre et tester chaque étape avant la suivante**, ne
changer qu'une chose à la fois, lire le message d'erreur exact. Chaque lot suit le même ordre :

> migration → modèle (`$fillable`, *casts*, relations) → *factory* et *seeder* → Form Request →
> service ou action → contrôleur → ressource JSON → Policy → route (`route:list`) →
> *feature tests* → contrôle sur le téléphone.

| Lot | Contenu | Prêt quand… |
|---|---|---|
| 0. Socle | `composer create-project laravel/laravel:^13.0 usw_api`, `.env`, MySQL, `php artisan install:api` (Sanctum), format d'erreur, Pint, PHPUnit, `usw:verifier-php` | `php artisan serve` répond, `/up` est vert, les tests passent |
| 1. Compte | Inscription, code, connexion e-mail et Google, profil, déconnexion | Les écrans E01, E02, E36 fonctionnent sur le téléphone |
| 2. Lieux et contenus | Pays, villes, lieux, contenus, captures, modèles de téléphone ; données de départ tirées de la maquette | L'accueil en piles affiche de vraies données |
| 3. Envoi et vérification | Envoi par morceaux, deux temps, AnalyserCapture, variantes WebP | Une photo du Camon 50 Pro est publiée en 3G simulée, coupure comprise |
| 4. Exploration | Flux, reels, Près de moi, carte, recherche, filtres | E03, E04, E06, E11, E31, E33 |
| 5. Communauté | Réactions, commentaires, collections, abonnements, partage | E05, E07, E09, E10, E19 |
| 6. Modération | Signalements, file, décisions, blocages, règles | E22, E24, E25 |
| 7. Notifications | Centre, push FCM | E17 |
| 8. Production | Performances, revue de sécurité, déploiement | Contrôle de la section 9 entièrement coché |

Chaque lot se termine par sa liste de scénarios (comme la section 12.2 du TP) et un contrôle des
points de sécurité de la Partie 27.

---

## 12. Ce qui reste à décider avec le groupe

1. **L'hébergement du serveur** (PHP, MySQL, Redis). Décidé le 22 octobre 2026 : les e-mails passent par **Resend**, les photos et les vidéos par **Cloudflare R2**.
2. **Le service push** : Firebase Cloud Messaging (Android et iOS).
3. **Le projet à part ou dans le dépôt existant** : on propose `usw_api` à côté de `pinterest_api`.
   - On reprend de `pinterest_api` : le rendu JSON des erreurs, la lecture des médias, les tests.
   - On laisse le reste : il n'a pas d'authentification et sert un seul utilisateur fixe.
