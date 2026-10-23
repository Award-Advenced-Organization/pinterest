// Les pages a lire : E35 Aide, E23 Regles communautaires, E34 Conditions
// generales, E38 Confidentialite. Une seule route, /document/:id. Ce sont des
// pages de lecture : elles defilent, le titre reste immobile.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/champ.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';
import 'etats.dart';

class EcranDocument extends StatelessWidget {
  const EcranDocument({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => switch (id) {
    'aide' => const EcranAide(),
    'regles' => const _Regles(),
    'cgu' => const _Conditions(),
    'confidentialite' => const _Confidentialite(),
    _ => const EcranEtat(etat: 'introuvable'),
  };
}

Future<void> _ecrire(BuildContext context, String adresse) async {
  final ouvert = await launchUrl(Uri(scheme: 'mailto', path: adresse));
  if (!ouvert && context.mounted) bulle(context, 'Écrivez-nous à $adresse.', icone: 'enveloppe');
}

/// La page de lecture : le retour, puis le contenu qui defile.
class _Lecture extends StatelessWidget {
  const _Lecture({required this.enfants});

  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 40 + MediaQuery.paddingOf(context).bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/accueil')),
                ),
                const SizedBox(height: 16),
                ...enfants,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La tete d un document : la feuille de papier, le titre, la date.
class _Tete extends StatelessWidget {
  const _Tete({required this.titre, required this.sousTitre});

  final String titre;
  final String sousTitre;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 44, height: 52, child: CustomPaint(painter: _Papier())),
      const SizedBox(height: 14),
      Titre(titre, style: Textes.titre),
      const SizedBox(height: 8),
      Text(sousTitre, style: Textes.discret),
      const SizedBox(height: 20),
    ],
  );
}

/// La feuille de la maquette (document-vivant) : un coin plie et des lignes
/// d ecriture, la premiere a l ocean.
class _Papier extends CustomPainter {
  const _Papier();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 48);
    final papier = Path()
      ..moveTo(8, 2.5)
      ..lineTo(25.5, 2.5)
      ..lineTo(35.5, 12.5)
      ..lineTo(35.5, 41)
      ..arcToPoint(const Offset(31, 45.5), radius: const Radius.circular(4.5))
      ..lineTo(8, 45.5)
      ..arcToPoint(const Offset(3.5, 41), radius: const Radius.circular(4.5))
      ..lineTo(3.5, 7)
      ..arcToPoint(const Offset(8, 2.5), radius: const Radius.circular(4.5))
      ..close();
    canvas.drawPath(papier, Paint()..color = Colors.white);
    final bord = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..strokeJoin = StrokeJoin.round
      ..color = Couleurs.hsl(229, 25, 60, 0.55);
    canvas.drawPath(papier, bord);
    final pli = Path()
      ..moveTo(25.5, 2.5)
      ..lineTo(25.5, 9)
      ..arcToPoint(const Offset(29, 12.5), radius: const Radius.circular(3.5), clockwise: false)
      ..lineTo(35.5, 12.5)
      ..close();
    canvas.drawPath(pli, Paint()..color = Couleurs.hsl(229, 30, 86));
    canvas.drawPath(pli, bord);
    final lignes = [(18.5, 22.5), (24.5, 30.0), (29.5, 28.0), (34.5, 30.0), (39.5, 18.0)];
    for (var i = 0; i < lignes.length; i++) {
      final (y, fin) = lignes[i];
      final trait = Path()..moveTo(9, y);
      for (var x = 9.0; x < fin; x += 4.5) {
        trait.relativeQuadraticBezierTo(1.1, -1.4, 2.25, 0);
        trait.relativeQuadraticBezierTo(1.1, 1.4, 2.25, 0);
      }
      canvas.drawPath(
        trait,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = i == 0 ? 1.9 : 1.4
          ..color = i == 0 ? Couleurs.ocean : Couleurs.hsl(229, 25, 55, 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_Papier old) => false;
}

TextStyle get _sectionTitre => const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.3);

/// Un article numerote (CGU, confidentialite).
class _Article extends StatelessWidget {
  const _Article({super.key, required this.numero, required this.titre, required this.texte});

  final int numero;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Numero(numero),
            const SizedBox(width: 10),
            Expanded(
              child: Text(titre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(texte, style: Textes.corps.copyWith(height: 1.55)),
      ],
    ),
  );
}

class _Numero extends StatelessWidget {
  const _Numero(this.n, {this.couleur});

  final int n;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: couleur ?? Couleurs.texte, borderRadius: BorderRadius.circular(8)),
    child: Text(
      '$n',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Couleurs.surEncre),
    ),
  );
}

/// « Voir aussi les ... et la ... », chaque lien mene a son document.
class _VoirAussi extends StatelessWidget {
  const _VoirAussi(this.liens);

  /// (texte avant, lien, id du document)
  final List<(String, String, String)> liens;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (avant, lien, id) in liens) ...[
          Text(avant, style: Textes.petit),
          GestureDetector(
            onTap: () => context.pushReplacement('/document/$id'),
            child: Text(
              lien,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Couleurs.texte, decoration: TextDecoration.underline),
            ),
          ),
        ],
        Text('.', style: Textes.petit),
      ],
    ),
  );
}

// ------------------------------------------------------------ E23 regles

class _Regle {
  const _Regle(this.icone, this.titre, this.texte, [this.oui, this.non]);
  final String icone;
  final String titre;
  final String texte;
  final String? oui;
  final String? non;
}

const _regles = [
  _Regle(
    'camera',
    'Pris sur place, par vous',
    "Publiez ce que vous avez photographié ou filmé vous-même, à l'endroit indiqué. Une photo ancienne est bienvenue.",
    'Votre photo de la plage de Fidjrossè, prise dimanche.',
    'Une image trouvée sur Internet ou envoyée par un ami.',
  ),
  _Regle(
    'etincelle',
    "Pas d'image générée",
    "USW montre des lieux tels qu'ils sont. Les images créées ou transformées par une IA sont refusées.",
    'Recadrer, redresser, régler la lumière.',
    'Remplacer le ciel, ajouter ou effacer des éléments.',
  ),
  _Regle(
    'carte',
    'Des informations vraies',
    "Le lieu, la date et le téléphone aident les autres à y aller. Indiquez-les tels qu'ils sont.",
    '« Cascade de Tanougou » pour une vidéo de Tanougou.',
    'Un lieu célèbre pour attirer plus de vues.',
  ),
  _Regle('profil', 'Le respect des personnes', "Demandez avant de photographier quelqu'un de près. Pas d'insulte, de moquerie ni de harcèlement."),
  _Regle(
    'bouclier',
    'Les lieux sacrés et privés',
    "Respectez les lieux où la photo est interdite, comme certaines forêts sacrées. Ne montrez pas l'adresse d'une maison.",
  ),
  _Regle('drapeau', 'Pas de spam', 'Pas de publicité déguisée, de faux comptes ni de liens trompeurs.'),
];

class _Regles extends StatelessWidget {
  const _Regles();

  @override
  Widget build(BuildContext context) => _Lecture(
    enfants: [
      const _Tete(titre: 'Règles communautaires', sousTitre: 'Six règles pour que chaque photo dise vrai · 3 min de lecture'),
      for (final r in _regles)
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Couleurs.surface, borderRadius: BorderRadius.circular(13)),
                child: Icone(r.icone, taille: 22, couleur: Couleurs.texte),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.titre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(r.texte, style: Textes.corps.copyWith(height: 1.5)),
                    if (r.oui != null) ...[const SizedBox(height: 8), _Exemple(oui: true, texte: r.oui!), _Exemple(oui: false, texte: r.non!)],
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 4),
      Text("Si une règle n'est pas respectée", style: _sectionTitre),
      const SizedBox(height: 12),
      Plaque(
        rayon: 22,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            for (final (i, (titre, texte)) in const [
              ('Le contenu est retiré', 'Vous recevez le motif et pouvez demander une vérification.'),
              ('Le compte est suspendu 7 jours', "Après plusieurs retraits dans l'année."),
              ('Le compte est supprimé', 'En cas de manquement grave ou répété.'),
            ].indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Numero(i + 1, couleur: i == 2 ? Couleurs.erreur : null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text(texte, style: Textes.petit),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const _VoirAussi([('Voir aussi les ', 'conditions générales', 'cgu'), (' et la ', 'politique de confidentialité', 'confidentialite')]),
    ],
  );
}

class _Exemple extends StatelessWidget {
  const _Exemple({required this.oui, required this.texte});

  final bool oui;
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icone(oui ? 'coche' : 'fermer', taille: 15, couleur: oui ? Couleurs.succes : Couleurs.erreur),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(texte, style: Textes.petit.copyWith(fontSize: 13.5))),
      ],
    ),
  );
}

// ------------------------------------------------------------ E34 conditions

const _articlesCgu = [
  (
    'Objet',
    "Les présentes conditions encadrent l'utilisation de USW (United State of World), application de partage de photos et de reels de lieux, prises sur place par leurs auteurs. En créant un compte, vous les acceptez.",
  ),
  (
    'Votre compte',
    'Vous fournissez un e-mail valide et gardez votre mot de passe secret. Un compte est personnel. Vous pouvez le supprimer à tout moment depuis les réglages : vos contenus sont alors retirés.',
  ),
  (
    'Ce que vous publiez',
    'Vous ne publiez que des photos et des vidéos que vous avez prises vous-même, sur le lieu indiqué. Les images générées ou retouchées par une intelligence artificielle sont refusées. Une photo ancienne est acceptée.',
  ),
  (
    'Les informations de capture',
    "USW lit dans le fichier le téléphone, la date et la position de la prise. Ce que le fichier ne dit pas, vous l'indiquez vous-même : l'information est alors marquée « déclarée ». Indiquer une information fausse peut entraîner le retrait du contenu.",
  ),
  (
    'Vos droits sur vos contenus',
    "Vous restez propriétaire de vos photos et de vos reels. Vous accordez à USW le droit de les afficher, de les redimensionner et de les convertir pour l'application, le temps de leur publication.",
  ),
  (
    "Le téléchargement de l'original",
    "Les autres membres peuvent télécharger l'original d'une photo pour un usage personnel. Toute autre utilisation demande votre accord.",
  ),
  (
    'Modération et signalement',
    'Chaque contenu peut être signalé. L’équipe de modération vérifie les signalements et peut retirer un contenu ou suspendre un compte qui ne respecte pas les règles communautaires.',
  ),
  ('Données personnelles', "USW ne collecte que ce dont l'application a besoin. Le détail figure dans la politique de confidentialité."),
  ('Nous écrire', 'Pour toute question sur ces conditions : support@usw.app.'),
];

class _Conditions extends StatefulWidget {
  const _Conditions();

  @override
  State<_Conditions> createState() => _ConditionsState();
}

class _ConditionsState extends State<_Conditions> {
  final _cles = [for (final _ in _articlesCgu) GlobalKey()];

  void _aller(int i) {
    final cible = _cles[i].currentContext;
    if (cible != null) Scrollable.ensureVisible(cible, duration: const Duration(milliseconds: 650), curve: Courbes.signature, alignment: 0.08);
  }

  @override
  Widget build(BuildContext context) => _Lecture(
    enfants: [
      const _Tete(titre: "Conditions générales d'utilisation", sousTitre: 'En vigueur le 22 octobre 2026 · 4 min de lecture'),
      // Le sommaire : une pastille par article, elle y fait defiler.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (var i = 0; i < _articlesCgu.length; i++) ...[if (i > 0) const SizedBox(width: 8), Pastille(texte: _articlesCgu[i].$1, onTap: () => _aller(i))],
          ],
        ),
      ),
      const SizedBox(height: 24),
      for (var i = 0; i < _articlesCgu.length; i++) _Article(key: _cles[i], numero: i + 1, titre: _articlesCgu[i].$1, texte: _articlesCgu[i].$2),
      const _VoirAussi([('Voir aussi les ', 'règles communautaires', 'regles'), (' et la ', 'politique de confidentialité', 'confidentialite')]),
    ],
  );
}

// ------------------------------------------------------------ E38 confidentialite

class _Confidentialite extends StatelessWidget {
  const _Confidentialite();

  @override
  Widget build(BuildContext context) => _Lecture(
    enfants: [
      const _Tete(titre: 'Politique de confidentialité', sousTitre: 'En vigueur le 22 octobre 2026 · 3 min de lecture'),
      Plaque(
        rayon: 22,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('En bref', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (final t in const [
              'Nous ne vendons pas vos données et ne montrons pas de publicité ciblée.',
              "La position n'est lue qu'au moment de publier, dans le fichier de la photo.",
              'Vous pouvez tout télécharger ou tout supprimer, à tout moment.',
            ])
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icone('coche', taille: 16, couleur: Couleurs.texte),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t, style: Textes.corps.copyWith(fontSize: 14.5))),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text('Ce que nous gardons, et pourquoi', style: _sectionTitre),
      const SizedBox(height: 12),
      Plaque(
        rayon: 22,
        child: Column(
          children: [
            for (final (i, (icone, quoi, pourquoi, duree)) in const [
              ('enveloppe', 'E-mail et mot de passe', 'Vous connecter', 'Tant que le compte existe'),
              ('carte', 'Position de la prise', 'Afficher le lieu, Y aller', 'Avec la publication'),
              ('telephone', 'Modèle du téléphone, date', 'Les informations de capture', 'Avec la publication'),
              ('image', 'Fichiers originaux', "Le téléchargement de l'original", 'Avec la publication'),
              ('drapeau', 'Signalements', 'La modération', '1 an'),
            ].indexed) ...[
              if (i > 0) Divider(height: 1, thickness: 1, indent: 52, color: Couleurs.filet),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Icone(icone, taille: 22, couleur: Couleurs.texte),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quoi, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text(pourquoi, style: Textes.petit),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: Text(duree, textAlign: TextAlign.end, style: Textes.petit.copyWith(fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 24),
      for (final (i, (titre, texte)) in const [
        (
          'Ce que les autres voient',
          "Votre nom, votre photo de profil, vos publications et leurs informations de capture. Une collection secrète n'est visible que par vous.",
        ),
        (
          "Les copies pour l'écran",
          "Les versions légères affichées dans l'application ne contiennent aucune information du fichier. Seul l'original les garde.",
        ),
        (
          'Vos droits',
          "Vous pouvez consulter, corriger, télécharger ou supprimer vos données. Vous pouvez aussi saisir l'Autorité de protection des données personnelles (APDP).",
        ),
      ].indexed)
        _Article(numero: i + 1, titre: titre, texte: texte),
      BoutonVerre(
        texte: 'Télécharger mes données',
        icone: 'telecharger',
        onTap: () => bulle(context, 'Vous recevrez vos données par e-mail sous 48 h.', icone: 'telecharger'),
      ),
      const SizedBox(height: 4),
      Center(
        child: TextButton(
          onPressed: () => context.push('/profil/reglages'),
          child: Text(
            'Supprimer mon compte',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Couleurs.erreur),
          ),
        ),
      ),
      Center(
        child: GestureDetector(
          onTap: () => _ecrire(context, 'vie-privee@usw.app'),
          child: Text.rich(
            TextSpan(
              text: 'Une question : ',
              style: Textes.petit,
              children: [
                TextSpan(
                  text: 'vie-privee@usw.app',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Couleurs.texte, decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// ------------------------------------------------------------ E35 aide

const _sujets = [
  ('camera', 'Publier une photo'),
  ('verifie', 'Capture vérifiée'),
  ('carte', 'Y aller et Maps'),
  ('profil', 'Mon compte'),
  ('telecharger', 'Envoi en 3G'),
  ('bouclier', 'Signaler un contenu'),
];

const _questions = [
  (
    "Pourquoi ma photo n'a pas le badge « Capture vérifiée » ?",
    'Le badge vient quand le téléphone, la date et le lieu sont lus dans le fichier lui-même, ou quand la photo est prise avec la caméra USW. Si vous les avez indiqués à la main, la photo porte « Informations déclarées » : elle est publiée de la même façon.',
    'Capture vérifiée',
  ),
  (
    'Puis-je publier une photo prise il y a longtemps ?',
    "Oui. Importez-la depuis la galerie : si le fichier ne dit ni le téléphone ni la date, indiquez-les. Elle portera le badge « Informations déclarées ».",
    'Publier une photo',
  ),
  (
    'Pourquoi USW refuse les images générées par IA ?',
    "USW montre des lieux tels qu'ils sont, pour donner envie d'y aller. Une image générée ou un ciel remplacé trompe celui qui fera le voyage.",
    'Signaler un contenu',
  ),
  (
    "Mon envoi s'est arrêté en 3G, que faire ?",
    "Rien : l'envoi reprend où il s'était arrêté dès que le réseau revient. Suivez-le dans Profil, Mes envois. Vous pouvez aussi le réserver au Wi-Fi dans les réglages.",
    'Envoi en 3G',
  ),
  (
    "Comment télécharger l'original d'une photo ?",
    "Touchez la photo pour l'ouvrir en grand, puis « Original ». Ou, sur la page de la photo, Télécharger : choisissez l'original ou la taille de l'écran.",
    'Publier une photo',
  ),
  (
    'Comment Y aller fonctionne ?',
    "« Y aller » ouvre l'itinéraire jusqu'au lieu dans Google Maps, depuis votre position. La distance affichée est à vol d'oiseau.",
    'Y aller et Maps',
  ),
  ('Comment changer mon e-mail ou mon mot de passe ?', 'Dans Profil, Réglages, E-mail et mot de passe. Un code vous est envoyé pour confirmer.', 'Mon compte'),
];

class EcranAide extends StatefulWidget {
  const EcranAide({super.key});

  @override
  State<EcranAide> createState() => _EcranAideState();
}

class _EcranAideState extends State<EcranAide> {
  final _recherche = TextEditingController();
  String? _sujet;
  int? _ouverte = 0;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  String _sansAccent(String t) {
    const de = 'àâäéèêëîïôöùûüç';
    const vers = 'aaaeeeeiioouuuc';
    final b = StringBuffer();
    for (final c in t.toLowerCase().split('')) {
      final i = de.indexOf(c);
      b.write(i < 0 ? c : vers[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cherche = _sansAccent(_recherche.text.trim());
    final questions = [
      for (final (i, q) in _questions.indexed)
        if ((_sujet == null || q.$3 == _sujet) && (cherche.isEmpty || _sansAccent('${q.$1} ${q.$2}').contains(cherche))) (i, q),
    ];
    return _Lecture(
      enfants: [
        Titre('Comment pouvons-nous vous aider ?', style: Textes.titre),
        const SizedBox(height: 18),
        ChampVerre(icone: 'loupe', indice: "Rechercher dans l'aide", controleur: _recherche, action: TextInputAction.search, onChanged: (_) => setState(() {})),
        const SizedBox(height: 24),
        Text('Les sujets', style: _sectionTitre),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: [
            for (final (icone, texte) in _sujets)
              Appuyable(
                semantique: texte,
                verre: true,
                rayonVerre: 18,
                gonflement: 0.04,
                onTap: () => setState(() => _sujet = _sujet == texte ? null : texte),
                child: Verre(
                  rayon: 18,
                  teinte: _sujet == texte ? TeinteVerre.retenu : TeinteVerre.clair,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icone(icone, taille: 22, couleur: Couleurs.texte),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(texte, maxLines: 2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(_sujet ?? 'Questions fréquentes', style: _sectionTitre),
        const SizedBox(height: 8),
        if (questions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Aucune réponse pour « ${_recherche.text.trim()} ». Écrivez-nous, on vous répond.', style: Textes.discret),
          ),
        for (final (i, q) in questions)
          _Question(question: q.$1, reponse: q.$2, ouverte: _ouverte == i, onTap: () => setState(() => _ouverte = _ouverte == i ? null : i)),
        const SizedBox(height: 20),
        Plaque(
          rayon: 22,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Couleurs.surface, borderRadius: BorderRadius.circular(13)),
                child: Icone('enveloppe', taille: 22, couleur: Couleurs.texte),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pas trouvé la réponse ?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text("L'équipe répond sous 48 h.", style: Textes.petit),
                  ],
                ),
              ),
              BoutonVerre(texte: 'Écrire', large: false, onTap: () => _ecrire(context, 'support@usw.app')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Plaque(
          rayon: 22,
          child: Column(
            children: [
              for (final (i, (icone, texte, id)) in const [
                ('bouclier', 'Règles communautaires', 'regles'),
                ('document', 'Conditions générales', 'cgu'),
                ('cadenas', 'Confidentialité', 'confidentialite'),
              ].indexed) ...[
                if (i > 0) Divider(height: 1, thickness: 1, indent: 52, color: Couleurs.filet),
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => context.push('/document/$id'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        Icone(icone, taille: 22, couleur: Couleurs.texte),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(texte, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500)),
                        ),
                        Icone('chevron-droite', taille: 18, couleur: Couleurs.discret),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.question, required this.reponse, required this.ouverte, required this.onTap});

  final String question;
  final String reponse;
  final bool ouverte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Couleurs.filet)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: ouverte,
          button: true,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(question, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, height: 1.3)),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: ouverte ? 0.5 : 0,
                    duration: const Duration(milliseconds: 420),
                    curve: Courbes.ressort,
                    child: Icone('chevron-bas', taille: 18, couleur: Couleurs.discret),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 380),
          curve: Courbes.interface,
          alignment: Alignment.topCenter,
          child: ouverte
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(reponse, style: Textes.discret.copyWith(fontSize: 14.5)),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    ),
  );
}
