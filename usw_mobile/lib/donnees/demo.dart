// Les donnees de demonstration, celles de la maquette, en attendant l API
// (lot 2). Meme forme que les ressources JSON prevues dans ARCHITECTURE.md,
// section 8 : brancher l API ne changera que la source.

class Lieu {
  const Lieu({
    required this.id,
    required this.nom,
    required this.region,
    required this.photos,
    required this.nombre,
    required this.ratio,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  final String id;
  final String nom;
  final String region;

  /// Les 4 meilleures photos, la premiere devant.
  final List<String> photos;
  final int nombre;

  /// Largeur sur hauteur de la pile.
  final double ratio;
  final String type;

  /// Le point ou « Y aller » mene, dans Maps.
  final double latitude;
  final double longitude;
  final int? distanceKm;
}

const lieuxDemo = <Lieu>[
  Lieu(
    id: 'grand-popo',
    nom: 'Plage de Grand-Popo',
    region: 'Mono, Bénin',
    photos: ['p108', 'p92', 'p12', 'p37'],
    nombre: 186,
    ratio: 3 / 4,
    type: 'Plages',
    latitude: 6.2833,
    longitude: 1.8222,
    distanceKm: 82,
  ),
  Lieu(
    id: 'kota',
    nom: 'Cascade de Kota',
    region: 'Atacora, Bénin',
    photos: ['p15', 'p28', 'p127', 'p10'],
    nombre: 97,
    ratio: 4 / 5,
    type: 'Cascades',
    latitude: 10.2667,
    longitude: 1.4333,
    distanceKm: 512,
  ),
  Lieu(
    id: 'pendjari',
    nom: 'Parc de la Pendjari',
    region: 'Atacora, Bénin',
    photos: ['p110', 'p66', 'p46', 'p116'],
    nombre: 248,
    ratio: 1,
    type: 'Savane et parcs',
    latitude: 11.05,
    longitude: 1.5,
    distanceKm: 620,
  ),
  Lieu(
    id: 'aheme',
    nom: 'Lac Ahémé, Possotomé',
    region: 'Mono, Bénin',
    photos: ['p124', 'p128', 'p74', 'p71'],
    nombre: 131,
    ratio: 3 / 4,
    type: 'Lacs et lagunes',
    latitude: 6.5167,
    longitude: 1.9833,
    distanceKm: 38,
  ),
  Lieu(
    id: 'dassa',
    nom: 'Collines de Dassa-Zoumé',
    region: 'Collines, Bénin',
    photos: ['p62', 'p54', 'p118', 'p29'],
    nombre: 74,
    ratio: 4 / 5,
    type: 'Collines',
    latitude: 7.75,
    longitude: 2.1833,
    distanceKm: 205,
  ),
  Lieu(
    id: 'ouidah',
    nom: 'Ponton de Ouidah',
    region: 'Atlantique, Bénin',
    photos: ['p77', 'p58', 'p101', 'p132'],
    nombre: 112,
    ratio: 1,
    type: 'Plages',
    latitude: 6.3256,
    longitude: 2.0886,
    distanceKm: 41,
  ),
  Lieu(
    id: 'porto-novo',
    nom: 'Rues de Porto-Novo',
    region: 'Ouémé, Bénin',
    photos: ['p57', 'p78', 'p76', 'p49'],
    nombre: 163,
    ratio: 3 / 4,
    type: 'Villes et rues',
    latitude: 6.4969,
    longitude: 2.6283,
    distanceKm: 33,
  ),
  Lieu(
    id: 'atacora',
    nom: "Sentiers de l'Atacora",
    region: 'Atacora, Bénin',
    photos: ['p17', 'p11', 'p28', 'p66'],
    nombre: 59,
    ratio: 4 / 5,
    type: 'Forêts',
    latitude: 10.3045,
    longitude: 1.3796,
    distanceKm: 540,
  ),
];

/// Une photo ou un reel publie sur un lieu (E33, E05). Le lot 2 donnera
/// GET /api/v1/lieux/{id}/publications.
class Publication {
  const Publication({required this.photo, required this.auteur, required this.appareil, this.verifiee = true, this.dureeReel});

  /// L image (pour un reel, sa couverture).
  final String photo;
  final String auteur;

  /// Le telephone de la prise, lu dans l EXIF ou indique par l auteur.
  final String appareil;
  final bool verifiee;

  /// En secondes ; nul pour une photo.
  final int? dureeReel;

  bool get reel => dureeReel != null;
}

/// La largeur sur la hauteur de chaque photo de demonstration
/// (assets/photos/images.json).
const ratiosPhotos = <String, double>{
  'p10': 440 / 660,
  'p11': 440 / 550,
  'p12': 438 / 780,
  'p15': 440 / 660,
  'p17': 440 / 352,
  'p28': 440 / 704,
  'p29': 440 / 528,
  'p37': 440 / 352,
  'p46': 440 / 616,
  'p49': 440 / 528,
  'p54': 1,
  'p57': 440 / 352,
  'p58': 440 / 704,
  'p62': 438 / 780,
  'p66': 440 / 616,
  'p71': 440 / 550,
  'p74': 1,
  'p76': 440 / 616,
  'p77': 440 / 352,
};

const _auteurs = <(String, String)>[
  ('@senan.voyage', 'iPhone 14 Pro'),
  ('@aicha.k', 'Tecno Camon 30'),
  ('@kofi_dzi', 'Samsung Galaxy A55'),
  ('@marius.b', 'Infinix Note 40'),
  ('@ola.photo', 'Tecno Camon 50 Pro'),
  ('@hounkpe', 'Redmi Note 13'),
];

/// Les publications d un lieu : celles de la maquette pour Grand-Popo, et
/// pour les autres, ses photos puis celles de lieux voisins.
List<Publication> publicationsDe(Lieu lieu) {
  final photos = lieu.id == 'grand-popo'
      ? const ['p108', 'p92', 'p12', 'p37', 'p77', 'p74', 'p124', 'p71', 'p116']
      : [
          ...lieu.photos,
          ...lieuxDemo.where((l) => l.region == lieu.region && l.id != lieu.id).expand((l) => l.photos),
          ...lieu.photos.reversed,
        ].take(9).toList();
  return [
    for (var i = 0; i < photos.length; i++)
      Publication(
        photo: photos[i],
        auteur: _auteurs[i % _auteurs.length].$1,
        appareil: _auteurs[i % _auteurs.length].$2,
        // Un reel sur trois, comme dans la maquette (0:18, 0:31).
        dureeReel: i % 3 == 2 ? 18 + 13 * (i ~/ 3) : null,
      ),
  ];
}

/// Ce que la page d une photo (E05) montre en plus de la carte. Le lot 2
/// donnera GET /api/v1/publications/{id}.
class DetailPublication {
  const DetailPublication({
    required this.titre,
    required this.legende,
    required this.priseLe,
    required this.gps,
    required this.jaime,
    required this.commentaires,
    required this.createur,
    required this.abonnes,
  });

  final String titre;
  final String legende;
  final String priseLe;

  /// Les coordonnees lues dans le fichier, telles qu affichees.
  final String gps;
  final int jaime;
  final int commentaires;
  final String createur;
  final int abonnes;
}

DetailPublication detailDe(Lieu lieu, int n) {
  if (lieu.id == 'grand-popo' && n == 0) {
    return const DetailPublication(
      titre: 'Les cocotiers de Grand-Popo',
      legende: "Fin d'après-midi sur la Route des pêches, juste avant la marée haute. Le chemin de sable part derrière le dernier cocotier.",
      priseLe: '14 mars 2026, 17 h 52',
      gps: '6,2795° N, 1,8226° E',
      jaime: 2140,
      commentaires: 48,
      createur: 'Akouavi K.',
      abonnes: 1284,
    );
  }
  String coord(double v, String plus, String moins) => '${v.abs().toStringAsFixed(4).replaceAll('.', ',')}° ${v >= 0 ? plus : moins}';
  return DetailPublication(
    titre: lieu.nom,
    legende: 'Prise sur place, ${lieu.region}.',
    priseLe: '${2 + n * 3} février 2026, ${9 + n} h ${((n * 7) % 60).toString().padLeft(2, '0')}',
    gps: '${coord(lieu.latitude, 'N', 'S')}, ${coord(lieu.longitude, 'E', 'O')}',
    jaime: 120 + 37 * n,
    commentaires: 3 + n,
    createur: const ['Sènan A.', 'Aïcha K.', 'Kofi D.', 'Marius B.', 'Ola P.', 'Hounkpè T.'][n % 6],
    abonnes: 310 + 45 * n,
  );
}

/// Un nombre court : 2140 -> « 2,1 k ».
String nombreCourt(int n) => n < 1000 ? '$n' : '${(n / 1000).toStringAsFixed(1).replaceAll('.', ',').replaceAll(',0', '')} k';

/// Les types de lieux de « Compléter le profil », etape 3.
const typesDeLieux = <(String, String)>[
  ('Plages', 'p108'),
  ('Cascades', 'p15'),
  ('Savane et parcs', 'p110'),
  ('Lacs et lagunes', 'p124'),
  ('Villes et rues', 'p57'),
  ('Collines', 'p62'),
  ('Forêts', 'p28'),
  ('Couchers de soleil', 'p37'),
  ('Patrimoine', 'p78'),
];

/// Les colonnes de la mosaique qui defile derriere l entree (E02).
const colonnesEntree = <List<String>>[
  ['p110', 'p15', 'p77', 'p124', 'p57'],
  ['p108', 'p62', 'p76', 'p49', 'p12'],
  ['p37', 'p17', 'p58', 'p71', 'p46'],
  ['p92', 'p28', 'p116', 'p54', 'p74'],
  ['p66', 'p78', 'p10', 'p118', 'p101'],
];

/// Un compte deja inscrit, pour essayer le parcours « Bon retour ».
const emailDemo = 'akouavi.k@gmail.com';

/// Une publication retrouvee par son lieu et son rang : de quoi ouvrir sa page.
typedef RefPublication = (String, int);

Lieu lieuDe(String id) => lieuxDemo.firstWhere((l) => l.id == id);

Publication publicationDe(RefPublication r) => publicationsDe(lieuDe(r.$1))[r.$2];

/// Les publications du compte de demonstration (E18).
const mesPublications = <RefPublication>[
  ('grand-popo', 0),
  ('ouidah', 1),
  ('aheme', 2),
  ('porto-novo', 0),
  ('grand-popo', 4),
  ('dassa', 1),
  ('kota', 2),
  ('ouidah', 3),
];

/// Une collection d enregistrements (E19), secrete ou non.
class Collection {
  const Collection({required this.nom, required this.refs, this.secrete = false, required this.nombre});

  final String nom;
  final List<RefPublication> refs;
  final bool secrete;
  final int nombre;
}

/// Les collections du compte ; « Créer une collection » en ajoute.
final collectionsDemo = <Collection>[
  Collection(nom: 'Plages', secrete: true, nombre: 25, refs: [('grand-popo', 1), ('ouidah', 0), ('grand-popo', 3), ('aheme', 0), ('grand-popo', 6)]),
  Collection(nom: 'Cascades', nombre: 12, refs: [('kota', 0), ('kota', 1), ('atacora', 2), ('kota', 3)]),
  Collection(nom: 'Week-end à Ouidah', nombre: 8, refs: [('ouidah', 2), ('ouidah', 4), ('porto-novo', 2)]),
  Collection(nom: 'Idées de voyage', nombre: 31, refs: [('pendjari', 0), ('dassa', 0), ('atacora', 1), ('pendjari', 2)]),
];

/// Un createur (E20).
class Createur {
  const Createur({required this.pseudo, required this.nom, required this.bio, required this.ville, required this.abonnes, required this.refs});

  final String pseudo;
  final String nom;
  final String bio;
  final String ville;
  final int abonnes;
  final List<RefPublication> refs;
}

const createursDemo = <Createur>[
  Createur(
    pseudo: 'senan.voyage',
    nom: 'Sènan Voyage',
    bio: 'Les cascades et les sentiers du Nord, à pied.',
    ville: 'Natitingou, Bénin',
    abonnes: 3420,
    refs: [('kota', 0), ('atacora', 0), ('pendjari', 1), ('kota', 3), ('atacora', 3), ('grand-popo', 0)],
  ),
  Createur(
    pseudo: 'aicha.k',
    nom: 'Aïcha K.',
    bio: 'Lagunes et bords de mer, au lever du jour.',
    ville: 'Ouidah, Bénin',
    abonnes: 1190,
    refs: [('aheme', 1), ('ouidah', 1), ('grand-popo', 1), ('aheme', 3)],
  ),
];

/// Le createur d un pseudo (« @aicha.k »), ou un createur general.
Createur createurDe(String pseudo) {
  final p = pseudo.replaceFirst('@', '');
  return createursDemo.where((c) => c.pseudo == p).firstOrNull ??
      Createur(pseudo: p, nom: p, bio: 'Des lieux du Bénin, en vraies photos.', ville: 'Bénin', abonnes: 240, refs: mesPublications.take(4).toList());
}

/// Un reel (E06). Sans video de demonstration : sa couverture, qui avance
/// lentement comme un plan filme. Le lot 4 branchera la lecture HLS.
class Reel {
  const Reel({
    required this.photo,
    required this.pseudo,
    required this.nom,
    required this.legende,
    required this.appareil,
    required this.lieu,
    required this.duree,
    required this.jaime,
    required this.commentaires,
    required this.enregistres,
    required this.partages,
    this.son = "Son d'origine",
  });

  final String photo;
  final String pseudo;
  final String nom;
  final String legende;
  final String appareil;
  final String lieu;
  final int duree;
  final int jaime;
  final int commentaires;
  final int enregistres;
  final int partages;
  final String son;
}

const reelsDemo = <Reel>[
  Reel(
    photo: 'p15',
    pseudo: 'senan.voyage',
    nom: 'Sènan Voyage',
    legende: "Le bruit de la chute couvre tout. Arrivez avant 9 h, l'eau est encore fraîche et il n'y a personne.",
    appareil: 'Infinix Note 30',
    lieu: 'kota',
    duree: 31,
    jaime: 12400,
    commentaires: 326,
    enregistres: 1024,
    partages: 418,
  ),
  Reel(
    photo: 'p12',
    pseudo: 'kofi_dzi',
    nom: 'Kofi D.',
    legende: 'Marée montante à Grand-Popo, le vent du soir. Restez jusqu’au coucher du soleil.',
    appareil: 'Samsung Galaxy A55',
    lieu: 'grand-popo',
    duree: 18,
    jaime: 5300,
    commentaires: 88,
    enregistres: 402,
    partages: 96,
  ),
  Reel(
    photo: 'p62',
    pseudo: 'marius.b',
    nom: 'Marius B.',
    legende: 'Le lever du jour depuis la colline sacrée de Dassa. Quarante minutes de montée, ça vaut tout.',
    appareil: 'Tecno Camon 30',
    lieu: 'dassa',
    duree: 24,
    jaime: 3100,
    commentaires: 41,
    enregistres: 230,
    partages: 57,
  ),
  Reel(
    photo: 'p110',
    pseudo: 'aicha.k',
    nom: 'Aïcha K.',
    legende: 'Les éléphants traversent la piste vers 17 h. Gardez vos distances, restez dans le véhicule.',
    appareil: 'iPhone 13',
    lieu: 'pendjari',
    duree: 42,
    jaime: 21800,
    commentaires: 612,
    enregistres: 3300,
    partages: 1200,
  ),
];
