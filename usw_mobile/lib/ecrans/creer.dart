// Creer : E12 le choix (photo, reel, galerie), E32 autoriser une seule fois,
// E27 la camera des reels, E28 le montage et E29 le son, E15 ce que le
// fichier ne dit pas, E14 les details, E30 choisir le lieu, E16 et E26 les
// envois. Les photos se prennent avec l appareil photo du telephone (tous ses
// modes) ; la camera USW ne sert qu aux reels. Simule ici : le lot 3
// branchera l appareil photo, la lecture EXIF, l envoi par morceaux et R2.
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../donnees/demo.dart';
import '../donnees/envois.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/champ.dart';
import '../widgets/feuille.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

/// Les autorisations ne se demandent qu une fois.
bool _autorise = false;

// ------------------------------------------------------------ E12 creer

void ouvrirCreer(BuildContext context) => montrerFeuille<void>(
  context,
  titre: 'Créer',
  contenu: (f) {
    void aller(String route) {
      Navigator.pop(f);
      context.push(route);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OptionCreer(
            icone: 'camera',
            titre: 'Prendre une photo',
            texte: "Avec l'appareil photo du téléphone, tous ses modes",
            onTap: () => aller(_autorise ? '/creer/details' : '/creer/autoriser'),
          ),
          _OptionCreer(icone: 'reels', titre: 'Tourner un reel', texte: '15, 30 ou 60 secondes, en plusieurs séquences', onTap: () => aller('/creer/reel')),
          _OptionCreer(
            icone: 'image',
            titre: 'Importer de la galerie',
            texte: 'Une photo ou une vidéo déjà prise, même ancienne',
            onTap: () => aller('/creer/completer'),
          ),
        ],
      ),
    );
  },
);

class _OptionCreer extends StatelessWidget {
  const _OptionCreer({required this.icone, required this.titre, required this.texte, required this.onTap});

  final String icone;
  final String titre;
  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(16)),
            child: Icone(icone, taille: 25, couleur: Couleurs.texte),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(texte, style: TextStyle(fontSize: 13, color: Couleurs.discret)),
              ],
            ),
          ),
          Icone('chevron-droite', taille: 18, couleur: Couleurs.discret),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------ E32 autoriser

class EcranAutoriser extends StatefulWidget {
  const EcranAutoriser({super.key});

  @override
  State<EcranAutoriser> createState() => _EcranAutoriserState();
}

class _EcranAutoriserState extends State<EcranAutoriser> {
  final _choix = [true, true, true];

  @override
  Widget build(BuildContext context) => PageFormulaire(
    centre: false,
    enfants: [
      const SizedBox(height: 10),
      Center(
        child: Verre(
          rayon: 44,
          child: SizedBox(
            width: 88,
            height: 88,
            child: Center(child: Icone('camera', taille: 40, couleur: Couleurs.texte)),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Titre('Une seule fois', style: Textes.titre, centre: true),
      const SizedBox(height: 10),
      Text(
        "Les photos se prennent avec l'appareil photo de votre téléphone, avec tous ses modes. USW y ajoute la position et le modèle : elles auront le badge Capture vérifiée.",
        style: Textes.discret,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 22),
      for (final (i, icone, titre, texte) in const [
        (0, 'cible', 'Position', 'Inscrite à chaque photo et chaque reel.'),
        (1, 'telephone', 'Modèle du téléphone', 'Tecno Camon 50 Pro, lu sur l’appareil.'),
        (2, 'micro', 'Caméra et micro', 'Pour tourner les reels dans USW.'),
      ]) ...[
        Plaque(
          rayon: 20,
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Row(
            children: [
              Icone(icone, taille: 24, couleur: Couleurs.texte),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: Textes.libelle),
                    Text(texte, style: Textes.petit),
                  ],
                ),
              ),
              Switch(value: _choix[i], onChanged: (v) => setState(() => _choix[i] = v)),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    ],
    pied: Column(
      children: [
        BoutonVerre(
          texte: 'Autoriser',
          plein: true,
          onTap: () {
            _autorise = true;
            context.pushReplacement('/creer/details');
          },
        ),
        const SizedBox(height: 8),
        Lien('Plus tard', discret: true, onTap: () => context.pop()),
      ],
    ),
  );
}

// ------------------------------------------------------------ E27 camera des reels

class EcranCameraReel extends StatefulWidget {
  const EcranCameraReel({super.key});

  @override
  State<EcranCameraReel> createState() => _EcranCameraReelState();
}

class _EcranCameraReelState extends State<EcranCameraReel> {
  int _limite = 30;
  final _sequences = <int>[11, 7];
  int _enCours = 0;
  bool _enregistre = false;

  // Le minuteur : l enregistrement part 3 ou 10 s apres l appui (0 : coupe).
  int _minuteur = 0;
  Timer? _minuterie;

  int get _total => _sequences.fold(0, (a, b) => a + b) + _enCours;

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }

  void _declencher() {
    HapticFeedback.mediumImpact();
    if (_enregistre) {
      _minuterie?.cancel();
      setState(() {
        if (_enCours > 0) _sequences.add(_enCours);
        _enCours = 0;
        _enregistre = false;
      });
    } else if (_total < _limite) {
      setState(() => _enregistre = true);
      _minuterie = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _enCours++);
        if (_total >= _limite) _declencher();
      });
    }
  }

  String _temps(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final bas = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: barreSombre,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Photo('p15'),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x80000000), Color(0x00000000), Color(0x00000000), Color(0xB3000000)],
                    stops: [0, 0.18, 0.62, 1],
                  ),
                ),
              ),
            ),
            // Les sequences deja tournees, en haut.
            Positioned(
              top: haut + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  for (final s in [..._sequences, if (_enCours > 0) _enCours]) ...[
                    Expanded(
                      flex: s,
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ],
                  if (_limite - _total > 0)
                    Expanded(
                      flex: _limite - _total,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: haut + 22,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  RondVerre(icone: 'fermer', semantique: 'Fermer', surPhoto: true, encre: Colors.white, onTap: () => context.pop()),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        if (_enregistre) ...[
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(color: Couleurs.erreur, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 7),
                        ],
                        Text(
                          '${_temps(_total)} / ${_temps(_limite)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_minuteur > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '$_minuteur s',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  RondVerre(
                    icone: 'minuteur',
                    semantique: _minuteur == 0 ? 'Minuteur coupé' : 'Minuteur : $_minuteur secondes',
                    surPhoto: true,
                    encre: Colors.white,
                    onTap: () {
                      setState(() => _minuteur = switch (_minuteur) {
                        0 => 3,
                        3 => 10,
                        _ => 0,
                      });
                      bulle(context, _minuteur == 0 ? 'Minuteur coupé.' : "L'enregistrement part $_minuteur s après l'appui.", icone: 'minuteur');
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: haut + 82,
              left: 14,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoPrise(icone: 'telephone', texte: 'Tecno Camon 50 Pro'),
                  SizedBox(height: 6),
                  _InfoPrise(icone: 'lieu', texte: 'Cascade de Kota'),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bas + 18,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final d in [15, 30, 60])
                        GestureDetector(
                          onTap: _total == 0 ? () => setState(() => _limite = d) : null,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: _limite == d ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                            child: Text(
                              '$d s',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _limite == d ? Couleurs.texte : Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const SizedBox(width: 28),
                      RondVerre(
                        icone: 'poubelle',
                        semantique: 'Effacer la dernière séquence',
                        surPhoto: true,
                        encre: Colors.white,
                        onTap: _sequences.isEmpty || _enregistre ? null : () => setState(_sequences.removeLast),
                      ),
                      const Spacer(),
                      Semantics(
                        button: true,
                        label: _enregistre ? 'Arrêter' : 'Filmer',
                        child: GestureDetector(
                          onTap: _declencher,
                          child: Container(
                            width: 82,
                            height: 82,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Courbes.ressort,
                              width: _enregistre ? 30 : 64,
                              height: _enregistre ? 30 : 64,
                              decoration: BoxDecoration(color: Couleurs.erreur, borderRadius: BorderRadius.circular(_enregistre ? 8 : 32)),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      BoutonVerre(texte: 'Suivant', plein: true, large: false, onTap: _total > 0 && !_enregistre ? () => context.push('/creer/montage') : null),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => bulle(context, "Les photos se prennent avec l'appareil photo du téléphone."),
                        child: Text(
                          'Photo',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                      const SizedBox(width: 22),
                      const Text(
                        'Reel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPrise extends StatelessWidget {
  const _InfoPrise({required this.icone, required this.texte});

  final String icone;
  final String texte;

  @override
  Widget build(BuildContext context) => Container(
    height: 26,
    padding: const EdgeInsets.fromLTRB(8, 0, 10, 0),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(13)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icone(icone, taille: 15),
        const SizedBox(width: 5),
        Text(
          texte,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------ E28 montage et E29 son

class EcranMontage extends StatefulWidget {
  const EcranMontage({super.key});

  @override
  State<EcranMontage> createState() => _EcranMontageState();
}

class _EcranMontageState extends State<EcranMontage> {
  final _segments = <(String, int)>[('p15', 11), ('p28', 9), ('p10', 8)];
  int _choisi = 1;
  String? _piste;

  void _son() => montrerFeuille<void>(
    context,
    titre: 'Le son',
    contenu: (_) => _FeuilleSon(piste: _piste, onChoix: (p) => setState(() => _piste = p)),
  );

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final bas = MediaQuery.paddingOf(context).bottom;
    final total = _segments.fold(0, (a, s) => a + s.$2);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: barreSombre,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0D14),
        body: Padding(
          padding: EdgeInsets.fromLTRB(14, haut + 8, 14, bas + 14),
          child: Column(
            children: [
              Row(
                children: [
                  RondVerre(icone: 'retour', semantique: 'Retour', surPhoto: true, encre: Colors.white, onTap: () => context.pop()),
                  const Expanded(
                    child: Text(
                      'Monter le reel',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  BoutonVerre(texte: 'Suivant', plein: true, large: false, onTap: () => context.push('/creer/details?reel=1')),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Photo(_segments[_choisi].$1),
                          const Align(
                            alignment: Alignment(0, -0.35),
                            child: Text(
                              'Avant 9 h, personne',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [Shadow(color: Color(0x80000000), blurRadius: 10)],
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                              child: const Icone('lecture', taille: 28, couleur: Colors.white),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Text(
                              '0:07 / 0:${total.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          if (_piste != null)
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Row(
                                children: [
                                  const Icone('musique', taille: 14, couleur: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(_piste!, style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Outil(icone: 'ciseaux', nom: 'Couper', onTap: () => bulle(context, 'Glissez les bords de la séquence pour la couper.')),
                  _Outil(icone: 'texte', nom: 'Texte', onTap: () => bulle(context, 'Touchez la vidéo pour écrire.')),
                  _Outil(icone: 'musique', nom: 'Son', onTap: _son),
                  _Outil(
                    icone: 'retourner',
                    nom: 'Réordonner',
                    onTap: () => setState(() {
                      final s = _segments.removeAt(_choisi);
                      _choisi = (_choisi + 1) % (_segments.length + 1);
                      _segments.insert(_choisi, s);
                    }),
                  ),
                  _Outil(
                    icone: 'poubelle',
                    nom: 'Supprimer',
                    danger: true,
                    onTap: _segments.length > 1
                        ? () => setState(() {
                            _segments.removeAt(_choisi);
                            _choisi = _choisi.clamp(0, _segments.length - 1);
                          })
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < _segments.length; i++)
                      Expanded(
                        flex: _segments[i].$2,
                        child: GestureDetector(
                          onTap: () => setState(() => _choisi = i),
                          child: AnimatedContainer(
                            duration: Durees.interface,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(color: i == _choisi ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                PhotoArrondie(_segments[i].$1, rayon: 9.5),
                                Positioned(
                                  left: 6,
                                  bottom: 4,
                                  child: Text(
                                    '${_segments[i].$2} s',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Outil extends StatelessWidget {
  const _Outil({required this.icone, required this.nom, required this.onTap, this.danger = false});

  final String icone;
  final String nom;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final couleur = danger ? Couleurs.erreur : Colors.white;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Column(
        children: [
          RondVerre(icone: icone, semantique: nom, surPhoto: true, encre: couleur, onTap: onTap),
          const SizedBox(height: 5),
          Text(nom, style: TextStyle(fontSize: 12, color: couleur)),
        ],
      ),
    );
  }
}

class _FeuilleSon extends StatefulWidget {
  const _FeuilleSon({required this.piste, required this.onChoix});

  final String? piste;
  final ValueChanged<String?> onChoix;

  @override
  State<_FeuilleSon> createState() => _FeuilleSonState();
}

class _FeuilleSonState extends State<_FeuilleSon> {
  static const _pistes = [
    ('Lagune au matin', 'Kossi Studio · 1:42'),
    ('Marée haute', 'Atelier Ouidah · 2:10'),
    ('Chemins rouges', 'Nord Sonore · 1:58'),
    ('Pluie sur Ganvié', 'Kossi Studio · 2:31'),
  ];
  late String? _choisie = widget.piste;
  String? _ecoute;
  String _onglet = 'Musiques libres';
  double _origine = 0.4;

  @override
  Widget build(BuildContext context) => ListView(
    shrinkWrap: true,
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final o in ['Musiques libres', "Son d'origine", 'Voix off']) Pastille(texte: o, retenue: _onglet == o, onTap: () => setState(() => _onglet = o)),
        ],
      ),
      const SizedBox(height: 12),
      const ChampVerre(icone: 'loupe', indice: 'Chercher une musique'),
      const SizedBox(height: 8),
      for (final (titre, auteur) in _pistes)
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _choisie = titre);
            widget.onChoix(titre);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _ecoute = _ecoute == titre ? null : titre),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
                    child: Icone(_ecoute == titre ? 'pause' : 'lecture', taille: 20, couleur: Couleurs.texte),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(auteur, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: _choisie == titre ? 1 : 0,
                  duration: const Duration(milliseconds: 360),
                  curve: Courbes.ressort,
                  child: Icone('coche', taille: 22, couleur: Couleurs.texte),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icone('micro', taille: 20, couleur: Couleurs.texte),
          const SizedBox(width: 10),
          const Text("Son d'origine", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          Expanded(
            child: Slider(value: _origine, activeColor: Couleurs.texte, onChanged: (v) => setState(() => _origine = v)),
          ),
        ],
      ),
      Row(
        children: [
          Icone('bouclier', taille: 16, couleur: Couleurs.discret),
          const SizedBox(width: 6),
          Expanded(child: Text('Musiques libres de droits, utilisables dans vos reels.', style: Textes.petit)),
        ],
      ),
    ],
  );
}

// ------------------------------------------------------------ E15 ce que le fichier ne dit pas

class EcranCompleterInfos extends StatefulWidget {
  const EcranCompleterInfos({super.key});

  @override
  State<EcranCompleterInfos> createState() => _EcranCompleterInfosState();
}

class _EcranCompleterInfosState extends State<EcranCompleterInfos> {
  final _modele = TextEditingController();
  final _date = TextEditingController();
  String? _telephone;
  String? _lieu;

  static const _connus = ['Tecno Spark 30 Pro', 'Tecno Spark 20C', 'Tecno Camon 50 Pro', 'Infinix Note 40', 'Samsung Galaxy A15', 'iPhone 12'];

  @override
  void dispose() {
    _modele.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saisie = _modele.text.trim();
    final proches = saisie.length < 2 ? const <String>[] : _connus.where((m) => m.toLowerCase().contains(saisie.toLowerCase())).take(3).toList();
    final pret = _telephone != null && _date.text.trim().isNotEmpty;
    return PageFormulaire(
      centre: false,
      enfants: [
        const SizedBox(height: 10),
        Titre('Ce que le fichier ne dit pas', style: Textes.titre),
        const SizedBox(height: 10),
        Text(
          'Cette photo ancienne n’a ni téléphone ni date. Indiquez-les : elle sera publiée avec le badge « Informations déclarées ».',
          style: Textes.discret,
        ),
        const SizedBox(height: 22),
        ChampVerre(
          libelle: "Le téléphone qui l'a prise",
          icone: 'telephone',
          indice: 'Tapez le modèle',
          controleur: _modele,
          aide: const Text("Choisissez-le s'il est dans la liste, sinon ajoutez-le."),
          onChanged: (_) => setState(() => _telephone = null),
        ),
        if (_telephone == null && saisie.length >= 2) ...[
          const SizedBox(height: 8),
          Plaque(
            rayon: 18,
            child: Column(
              children: [
                if (!_connus.any((m) => m.toLowerCase() == saisie.toLowerCase()))
                  ListTile(
                    leading: Icone('plus', taille: 22, couleur: Couleurs.texte),
                    title: Text('Ajouter « $saisie »', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Il rejoindra la liste pour les suivants'),
                    onTap: () => setState(() => _telephone = saisie),
                  ),
                for (final m in proches)
                  ListTile(
                    leading: Icone('telephone', taille: 22),
                    title: Text(m),
                    subtitle: const Text('Déjà utilisé sur USW'),
                    onTap: () => setState(() {
                      _telephone = m;
                      _modele.text = m;
                    }),
                  ),
              ],
            ),
          ),
        ],
        if (_telephone == null) ...[
          const SizedBox(height: 6),
          Lien(
            "C'est ce téléphone : Tecno Camon 50 Pro",
            onTap: () => setState(() {
              _telephone = 'Tecno Camon 50 Pro';
              _modele.text = _telephone!;
            }),
          ),
        ],
        const SizedBox(height: 16),
        ChampVerre(
          libelle: 'La date de la prise',
          icone: 'calendrier',
          indice: 'Mars 2019',
          controleur: _date,
          aide: const Text("Le mois et l'année suffisent."),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text('Le lieu', style: Textes.libelle),
        const SizedBox(height: 8),
        Appuyable(
          semantique: 'Indiquer le lieu',
          onTap: () async {
            final l = await context.push<String>('/creer/lieu');
            if (l != null) setState(() => _lieu = l);
          },
          child: Verre(
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icone('lieu', taille: 22, couleur: _lieu == null ? Couleurs.discret : null),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _lieu ?? 'Pas de GPS dans le fichier',
                        style: TextStyle(fontSize: 16, color: _lieu == null ? Couleurs.discret : Couleurs.texte),
                      ),
                    ),
                    Text(_lieu == null ? 'Indiquer' : 'Changer', style: Textes.lien.copyWith(color: Couleurs.texte)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('Badge de la publication', style: Textes.petit),
            const SizedBox(width: 10),
            const BadgeCapture(verifie: false),
          ],
        ),
      ],
      pied: BoutonVerre(texte: 'Continuer', plein: true, onTap: pret ? () => context.push('/creer/details?declare=1') : null),
    );
  }
}

// ------------------------------------------------------------ E14 details

class EcranDetails extends StatefulWidget {
  const EcranDetails({super.key, this.reel = false, this.declaree = false});

  final bool reel;
  final bool declaree;

  @override
  State<EcranDetails> createState() => _EcranDetailsState();
}

class _EcranDetailsState extends State<EcranDetails> {
  final _legende = TextEditingController(text: 'Les pirogues rentrent au coucher du soleil, côté Possotomé.');
  String _lieu = 'Lac Ahémé, Possotomé, Mono';
  final _types = <String>{'Lac et lagune'};

  @override
  void dispose() {
    _legende.dispose();
    super.dispose();
  }

  String get _photo => widget.reel ? 'p15' : (widget.declaree ? 'p57' : 'p124');

  void _publier() {
    Envois.instance.publier(titre: _lieu.split(',').first, photo: _photo, poidsMo: widget.reel ? 31 : 6.4);
    context.go('/accueil');
    bulle(context, 'Publication lancée : vous pouvez continuer à naviguer.');
  }

  @override
  Widget build(BuildContext context) => PageFormulaire(
    centre: false,
    titre: 'Nouvelle publication',
    enfants: [
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: widget.reel ? 200 : 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PhotoArrondie(_photo, rayon: 16),
                Positioned(left: 7, bottom: 7, child: BadgeCapture(verifie: !widget.declaree, seul: true)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BadgeCapture(verifie: !widget.declaree, court: true),
                const SizedBox(height: 12),
                for (final (icone, texte) in [
                  ('telephone', widget.declaree ? 'Tecno Spark 30C' : 'Tecno Camon 50 Pro'),
                  ('calendrier', widget.declaree ? 'Mars 2019' : '12 août 2026'),
                  ('lieu', _lieu.split(',').first),
                ]) ...[
                  Row(
                    children: [
                      Icone(icone, taille: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(texte, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      ChampVerre(libelle: 'Légende', icone: 'crayon', controleur: _legende, lignes: 3),
      const SizedBox(height: 16),
      Text('Lieu trouvé', style: Textes.libelle),
      const SizedBox(height: 8),
      Appuyable(
        semantique: 'Changer le lieu',
        onTap: () async {
          final l = await context.push<String>('/creer/lieu');
          if (l != null) setState(() => _lieu = l);
        },
        child: Verre(
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icone('lieu', taille: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_lieu, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
                  ),
                  Icone('chevron-droite', taille: 18, couleur: Couleurs.discret),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in ['Lac et lagune', 'Plage', 'Village', 'Nature'])
            Pastille(texte: t, retenue: _types.contains(t), onTap: () => setState(() => _types.contains(t) ? _types.remove(t) : _types.add(t))),
        ],
      ),
    ],
    pied: BoutonVerre(texte: 'Publier', icone: 'envoyer', plein: true, onTap: _publier),
  );
}

// ------------------------------------------------------------ E30 choisir le lieu

final _sousTest = Platform.environment.containsKey('FLUTTER_TEST');

class EcranChoisirLieu extends StatefulWidget {
  const EcranChoisirLieu({super.key});

  @override
  State<EcranChoisirLieu> createState() => _EcranChoisirLieuState();
}

class _EcranChoisirLieuState extends State<EcranChoisirLieu> {
  final _carte = MapController();
  LatLng _centre = const LatLng(6.2795, 1.8226);
  bool _bouge = false;

  // Le lieu connu le plus proche du centre, ou le point lui-meme.
  (String, String) get _choix {
    Lieu? proche;
    var mieux = 0.05;
    for (final l in lieuxDemo) {
      final d = (l.latitude - _centre.latitude).abs() + (l.longitude - _centre.longitude).abs();
      if (d < mieux) {
        mieux = d;
        proche = l;
      }
    }
    String c(double v, String p, String m) => '${v.abs().toStringAsFixed(4).replaceAll('.', ',')}° ${v >= 0 ? p : m}';
    final gps = '${c(_centre.latitude, 'N', 'S')}, ${c(_centre.longitude, 'E', 'O')}';
    return proche == null ? ('Point choisi', gps) : (proche.nom, '${proche.region} · $gps');
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final bas = MediaQuery.paddingOf(context).bottom;
    final (nom, detail) = _choix;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _carte,
            options: MapOptions(
              initialCenter: _centre,
              initialZoom: 12,
              backgroundColor: Couleurs.sombre ? const Color(0xFF262626) : const Color(0xFFECEEF4),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onPositionChanged: (camera, geste) => setState(() {
                _centre = camera.center;
                _bouge = geste;
              }),
              onMapEvent: (e) {
                if (e is MapEventMoveEnd || e is MapEventFlingAnimationEnd) setState(() => _bouge = false);
              },
            ),
            children: [
              if (!_sousTest)
                TileLayer(
                  key: ValueKey(Couleurs.sombre),
                  // La nuit, le fond de carte sombre de CARTO.
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/${Couleurs.sombre ? 'dark_all' : 'light_all'}/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context),
                  userAgentPackageName: 'bj.usw',
                ),
            ],
          ),
          // L epingle reste au centre ; elle se souleve quand la carte bouge.
          IgnorePointer(
            child: Center(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 380),
                curve: Courbes.ressort,
                offset: Offset(0, _bouge ? -0.75 : -0.5),
                child: const Icone('epingle', taille: 46),
              ),
            ),
          ),
          Positioned(
            top: haut + 8,
            left: 14,
            right: 14,
            child: Row(
              children: [
                RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
                const SizedBox(width: 8),
                Expanded(
                  child: Verre(
                    rayon: 25,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icone('loupe', taille: 21, couleur: Couleurs.discret),
                          const SizedBox(width: 10),
                          Text(nom, style: const TextStyle(fontSize: 15.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: bas + 14,
            child: Verre(
              rayon: 26,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Déplacez la carte pour poser l'épingle.", style: Textes.petit),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icone('lieu', taille: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(detail, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BoutonVerre(texte: 'Choisir ce lieu', plein: true, onTap: () => context.pop(nom == 'Point choisi' ? detail : nom)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ E26 mes envois

class EcranEnvois extends StatelessWidget {
  const EcranEnvois({super.key});

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: ListenableBuilder(
        listenable: Envois.instance,
        builder: (context, _) {
          final liste = Envois.instance.liste;
          Widget groupe(String titre, Iterable<Envoi> envois) => envois.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 6),
                      child: Text(
                        titre,
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte),
                      ),
                    ),
                    for (final e in envois) _LigneEnvoi(envoi: e),
                    const SizedBox(height: 10),
                  ],
                );
          return ListView(
            padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 40 + MediaQuery.paddingOf(context).bottom),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              ),
              const SizedBox(height: 14),
              Titre('Mes envois', style: Textes.titre),
              const SizedBox(height: 8),
              Text("Un envoi coupé reprend où il s'était arrêté, dès que le réseau revient.", style: Textes.discret),
              const SizedBox(height: 18),
              groupe('En cours', liste.where((e) => e.etat == EtatEnvoi.encours || e.etat == EtatEnvoi.pause)),
              groupe('En vérification', liste.where((e) => e.etat == EtatEnvoi.verification)),
              groupe('Terminés', liste.where((e) => e.etat == EtatEnvoi.publie || e.etat == EtatEnvoi.refuse)),
            ],
          );
        },
      ),
    );
  }
}

class _LigneEnvoi extends StatelessWidget {
  const _LigneEnvoi({required this.envoi});

  final Envoi envoi;

  @override
  Widget build(BuildContext context) {
    final e = envoi;
    final pct = (e.avance * 100).round();
    final envoye = (e.poidsMo * e.avance).toStringAsFixed(1).replaceAll('.', ',');
    final (String detail, String? icone, Color? couleur) = switch (e.etat) {
      EtatEnvoi.encours => ('$pct % · $envoye Mo sur ${e.poidsMo.toStringAsFixed(1).replaceAll('.', ',')} Mo · 3G', null, null),
      EtatEnvoi.pause => ('En pause · $pct %${e.detail != null ? ' · ${e.detail}' : ''}', null, null),
      EtatEnvoi.verification => ("Recherche des signes d'IA · environ 1 min", null, null),
      EtatEnvoi.publie => (e.detail ?? 'Publiée', 'verifie', null),
      EtatEnvoi.refuse => (e.detail ?? 'Refusée', 'drapeau', Couleurs.erreur),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Plaque(
        rayon: 20,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(width: 48, height: 60, child: PhotoArrondie(e.photo, rayon: 10)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (icone != null) ...[Icone(icone, taille: 14, couleur: couleur), const SizedBox(width: 4)],
                      Expanded(
                        child: Text(detail, style: TextStyle(fontSize: 12.5, color: couleur ?? Couleurs.discret)),
                      ),
                    ],
                  ),
                  if (e.etat == EtatEnvoi.encours || e.etat == EtatEnvoi.pause) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: e.avance,
                        minHeight: 4,
                        color: e.etat == EtatEnvoi.pause ? Couleurs.discret : Couleurs.ocean,
                        backgroundColor: Couleurs.filet,
                      ),
                    ),
                  ],
                  if (e.etat == EtatEnvoi.verification) ...[const SizedBox(height: 6), const LogoQuiTourne(taille: 18)],
                ],
              ),
            ),
            if (e.etat == EtatEnvoi.encours || e.etat == EtatEnvoi.pause) ...[
              const SizedBox(width: 8),
              RondVerre(
                icone: e.etat == EtatEnvoi.pause ? 'lecture' : 'pause',
                semantique: e.etat == EtatEnvoi.pause ? 'Reprendre' : 'Mettre en pause',
                taille: 38,
                onTap: () => Envois.instance.basculer(e),
              ),
              const SizedBox(width: 4),
              RondVerre(icone: 'fermer', semantique: "Annuler l'envoi", taille: 38, encre: Couleurs.erreur, onTap: () => Envois.instance.annuler(e)),
            ],
            if (e.etat == EtatEnvoi.refuse)
              TextButton(
                onPressed: () => context.push(Uri(path: '/etat/refusee', queryParameters: {'titre': e.titre}).toString()),
                child: Text(
                  'Motif',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Couleurs.texte, decoration: TextDecoration.underline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// La pastille d envoi (E16) : elle flotte au-dessus des onglets tant qu un
/// envoi avance, et mene a « Mes envois ».
class PastilleEnvoi extends StatelessWidget {
  const PastilleEnvoi({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Envois.instance,
    builder: (context, _) {
      final e = Envois.instance.courant;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Courbes.ressort,
        transitionBuilder: (enfant, a) => SlideTransition(
          position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(a),
          child: FadeTransition(opacity: a, child: enfant),
        ),
        child: e == null
            ? const SizedBox.shrink()
            : Appuyable(
                key: const ValueKey('envoi'),
                semantique: 'Envoi en cours, ${(e.avance * 100).round()} %',
                onTap: () => context.push('/creer/envois'),
                child: Verre(
                  rayon: 22,
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Envoi en cours · ${(e.avance * 100).round()} %', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                            Text('réseau 3G, reprise automatique', style: TextStyle(fontSize: 12, color: Couleurs.discret)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(value: e.avance, minHeight: 3.5, color: Couleurs.ocean, backgroundColor: Couleurs.filet),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      RondVerre(icone: 'pause', semantique: 'Mettre en pause', taille: 38, onTap: () => Envois.instance.basculer(e)),
                    ],
                  ),
                ),
              ),
      );
    },
  );
}
