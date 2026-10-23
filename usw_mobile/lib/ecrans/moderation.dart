// E24 Moderation et E25 Decision : l equipe trie les publications douteuses
// (signes d IA, signalements, informations declarees) et decide. Le reste est
// publie sans attendre. Le lot 6 branchera l API de moderation.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/avatar.dart';
import '../widgets/feuille.dart';
import '../widgets/feuilles.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

class _Dossier {
  const _Dossier(this.photo, this.titre, this.auteur, this.type, this.icone, this.raison, this.quand, {this.forte = false});
  final String photo;
  final String titre;
  final String auteur;
  final String type;
  final String icone;
  final String raison;
  final String quand;

  /// Une raison forte (IA probable, plusieurs signalements) passe en rouge.
  final bool forte;
}

const _dossiers = [
  _Dossier('p37', 'Côte de Sèmè au matin', 'koffi.photo', 'photo', 'etincelle', "Signes d'IA · 72 %", '12 min', forte: true),
  _Dossier('p15', 'Cascade de Kota', 'senan.voyage', 'reel', 'drapeau', 'Signalé 3 fois · pas pris à cet endroit', '40 min', forte: true),
  _Dossier('p62', 'Collines de Dassa', 'aminata.d', 'photo', 'telephone', 'Téléphone déclaré, pas lu dans le fichier', '1 h'),
  _Dossier('p46', 'Marché Dantokpa', 'yao.b', 'photo', 'profil', 'Visages en gros plan', '2 h'),
  _Dossier('p116', 'Ganvié au lever', 'lagune.229', 'reel', 'etincelle', "Signes d'IA · 41 %", '3 h'),
];

const _files = [('À vérifier', 12), ('Signalements', 5), ('Demandes', 2)];

class EcranModeration extends StatefulWidget {
  const EcranModeration({super.key});

  @override
  State<EcranModeration> createState() => _EcranModerationState();
}

// L ordre de la file : les plus urgents (score d IA, nombre de signalements)
// ou les plus anciens (personne n attend trop longtemps), et le type.
const _tris = <Motif>[("Les plus urgents d'abord", 'Signes d’IA forts et signalements nombreux en tête'), ("Les plus anciens d'abord", null)];
const _types = <Motif>[('Photos et reels', null), ('Photos', null), ('Reels', null)];

class _EcranModerationState extends State<EcranModeration> {
  int _file = 0;
  int _tri = 0;
  int _type = 0;

  Future<void> _filtres() => montrerFeuille<void>(
    context,
    titre: 'Trier la file',
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: StatefulBuilder(
        builder: (context, maj) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListeMotifs(
              motifs: _tris,
              choisi: _tri,
              onChoisi: (i) {
                setState(() => _tri = i);
                maj(() {});
              },
            ),
            const SizedBox(height: 14),
            Text('Afficher', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte)),
            const SizedBox(height: 8),
            ListeMotifs(
              motifs: _types,
              choisi: _type,
              onChoisi: (i) {
                setState(() => _type = i);
                maj(() {});
              },
            ),
            const SizedBox(height: 14),
            BoutonVerre(texte: 'Voir la file', plein: true, onTap: () => Navigator.pop(f)),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    var dossiers = switch (_file) {
      0 => _dossiers,
      1 => _dossiers.where((d) => d.icone == 'drapeau').toList(),
      _ => _dossiers.where((d) => d.icone == 'telephone').toList(),
    };
    if (_type > 0) dossiers = dossiers.where((d) => d.type == (_type == 1 ? 'photo' : 'reel')).toList();
    // La demonstration est rangee du plus recent au plus ancien.
    if (_tri == 1) dossiers = dossiers.reversed.toList();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              const Spacer(),
              RondVerre(icone: 'filtres', semantique: 'Filtres', onTap: _filtres),
            ],
          ),
          const SizedBox(height: 14),
          Titre('Modération', style: Textes.titre),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final (i, (nom, n)) in _files.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Pastille(texte: '$nom  $n', retenue: _file == i, onTap: () => setState(() => _file = i)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('${_tris[_tri].$1}. Le reste est publié sans attendre.', style: Textes.petit),
          const SizedBox(height: 8),
          for (final d in dossiers)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/moderation/decision?n=${_dossiers.indexOf(d)}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 2),
                    SizedBox(width: 64, height: 64, child: PhotoArrondie(d.photo, rayon: 12)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.titre, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                          Text('@${d.auteur} · ${d.type}', style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icone(d.icone, taille: 14, couleur: d.forte ? Couleurs.erreur : Couleurs.texte),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  d.raison,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: d.forte ? Couleurs.erreur : Couleurs.texte),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(d.quand, style: TextStyle(fontSize: 12, color: Couleurs.discret)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _motifsRefus = <Motif>[('Image générée ou retouchée par IA', null), ('Informations fausses', null), ('Autre motif', null)];

class EcranDecision extends StatefulWidget {
  const EcranDecision({super.key, this.index = 0});

  final int index;

  @override
  State<EcranDecision> createState() => _EcranDecisionState();
}

class _EcranDecisionState extends State<EcranDecision> {
  int? _motif = 0;

  void _decider(bool publier) {
    bulle(context, publier ? 'Publiée. L’auteur est prévenu.' : 'Refusée. L’auteur reçoit le motif.', icone: publier ? 'coche' : 'drapeau');
    final suivant = widget.index + 1;
    if (suivant < _dossiers.length) {
      context.pushReplacement('/moderation/decision?n=$suivant');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _dossiers[widget.index.clamp(0, _dossiers.length - 1)];
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    final ia = d.icone == 'etincelle';
    final score = d.forte ? 72 : 41;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              Expanded(
                child: Text(
                  'Dossier ${widget.index + 1} sur 12',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(aspectRatio: 4 / 3, child: PhotoArrondie(d.photo, rayon: 20)),
          const SizedBox(height: 14),
          Row(
            children: [
              Avatar(nom: d.auteur, taille: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.titre, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                    Text('@${d.auteur} · 214 publications, aucun retrait', style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Plaque(
            rayon: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icone(ia ? 'etincelle' : d.icone, taille: 20, couleur: Couleurs.texte),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ia ? "Signes d'image générée" : d.raison, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    if (ia)
                      Text(
                        '$score %',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: d.forte ? Couleurs.erreur : Couleurs.texte),
                      ),
                  ],
                ),
                if (ia) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 6,
                      color: d.forte ? Couleurs.erreur : Couleurs.texte,
                      backgroundColor: Couleurs.filet,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  ia
                      ? 'Textures répétées dans le ciel et la végétation, pas de bruit de capteur, contours trop nets sur les rochers.'
                      : 'Trois membres indiquent un autre lieu. La position du fichier est à comparer avec le lieu déclaré.',
                  style: Textes.petit.copyWith(fontSize: 13.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Plaque(
            rayon: 20,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fichier et déclaration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const _Compare(icone: 'telephone', quoi: 'Téléphone', fichier: 'Aucun dans le fichier', declare: 'Samsung Galaxy A54', accord: false),
                const _Compare(icone: 'calendrier', quoi: 'Prise le', fichier: '3 septembre 2026, 10 h 12', declare: '3 septembre 2026', accord: true),
                const _Compare(icone: 'lieu', quoi: 'Lieu', fichier: '6,3712° N, 2,6203° E · Sèmè-Kpodji', declare: 'Sèmè-Kpodji', accord: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Motif du refus', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ListeMotifs(motifs: _motifsRefus, choisi: _motif, onChoisi: (i) => setState(() => _motif = i)),
          const SizedBox(height: 10),
          Text("L'auteur reçoit le motif et peut demander une seconde vérification.", style: Textes.petit),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BoutonVerre(texte: 'Refuser', icone: 'fermer', teinte: TeinteVerre.rouge, onTap: _motif == null ? null : () => _decider(false)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BoutonVerre(texte: 'Publier', icone: 'coche', teinte: TeinteVerre.limonade, onTap: () => _decider(true)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Une ligne de comparaison : ce que dit le fichier, ce qui est declare.
class _Compare extends StatelessWidget {
  const _Compare({required this.icone, required this.quoi, required this.fichier, required this.declare, required this.accord});

  final String icone;
  final String quoi;
  final String fichier;
  final String declare;
  final bool accord;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icone(icone, taille: 20, couleur: Couleurs.texte),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(quoi, style: TextStyle(fontSize: 12, color: Couleurs.discret)),
              Text(fichier, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('Déclaré : $declare', style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: accord ? Couleurs.limonade.withValues(alpha: 0.35) : Couleurs.erreur.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icone(accord ? 'coche' : 'alerte', taille: 13, couleur: accord ? Couleurs.encreLimonade : Couleurs.erreur),
              const SizedBox(width: 4),
              Text(
                accord ? 'Concorde' : 'Diffère',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accord ? Couleurs.encreLimonade : Couleurs.erreur),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
