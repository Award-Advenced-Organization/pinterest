// E31 Recherche (et E04 Filtres) : une recherche libre (un lieu, une region,
// un type de lieu) et, a cote du champ, les filtres qui etaient sur
// l accueil : pays, types de lieux, distance, tri, captures verifiees. Sans
// texte : les recherches recentes et des idees de voyage. Sans resultat
// (E37) : une suggestion et des lieux proches. Le lot 4 branchera
// GET /api/v1/recherche?q=... (Meilisearch).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../donnees/demo.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/feuille.dart';
import '../widgets/icone.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

/// Les filtres retenus : ils restent d une recherche a l autre.
class Filtres {
  Filtres._();
  static final instance = Filtres._();

  String pays = 'Bénin';
  final types = <String>{};
  int? distanceKm;
  bool verifiees = false;
  String tri = 'Pertinence';

  int get actifs => types.length + (distanceKm != null ? 1 : 0) + (verifiees ? 1 : 0) + (tri != 'Pertinence' ? 1 : 0);

  void effacer() {
    types.clear();
    distanceKm = null;
    verifiees = false;
    tri = 'Pertinence';
  }
}

const _idees = <(String, String, String)>[
  ('Plages du golfe', 'p37', 'Plages'),
  ('Cascades et rivières', 'p15', 'Cascades'),
  ('Savane et parcs', 'p66', 'Savane et parcs'),
  ('Lacs et lagunes', 'p124', 'Lacs et lagunes'),
  ('Collines', 'p62', 'Collines'),
  ('Rues de Porto-Novo', 'p57', 'Villes et rues'),
];

const _populaires = <(String, String, String)>[
  ('Couchers de soleil', 'p110', 'Savane et parcs'),
  ('Pistes et sentiers', 'p17', 'Forêts'),
  ('Bord de mer', 'p12', 'Plages'),
  ('Forêts sacrées', 'p28', 'Forêts'),
];

final _recentes = <String>['Ganvié', 'Cascades du Nord', 'Grand-Popo', '@senan.voyage'];

String _simple(String t) {
  const accents = {'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'à': 'a', 'â': 'a', 'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ç': 'c'};
  return t.toLowerCase().split('').map((c) => accents[c] ?? c).join();
}

class EcranRecherche extends StatefulWidget {
  const EcranRecherche({super.key});

  @override
  State<EcranRecherche> createState() => _EcranRechercheState();
}

class _EcranRechercheState extends State<EcranRecherche> {
  final _texte = TextEditingController();
  final f = Filtres.instance;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  String get _requete => _texte.text.trim();

  List<Lieu> get _resultats {
    final mots = _simple(_requete).split(RegExp(r'\s+')).where((m) => m.isNotEmpty);
    var liste = lieuxDemo.where((l) {
      final champ = _simple('${l.nom} ${l.region} ${l.type}');
      return mots.every(champ.contains);
    });
    if (f.types.isNotEmpty) liste = liste.where((l) => f.types.contains(l.type));
    if (f.distanceKm != null) liste = liste.where((l) => (l.distanceKm ?? 99999) <= f.distanceKm!);
    final resultat = liste.toList();
    if (f.tri == 'Près de moi') resultat.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    if (f.tri == 'Récents') resultat.sort((a, b) => b.nombre.compareTo(a.nombre));
    return resultat;
  }

  // Une suggestion quand rien ne correspond : un lieu dont un mot commence pareil.
  Lieu? get _suggestion {
    final debut = _simple(_requete).split(' ').first;
    if (debut.length < 3) return null;
    return lieuxDemo.where((l) => _simple(l.nom).split(' ').any((m) => m.startsWith(debut.substring(0, 3)))).firstOrNull;
  }

  void _chercher(String t) {
    _texte.text = t;
    _texte.selection = TextSelection.collapsed(offset: t.length);
    setState(() {});
  }

  void _voirType(String type) => setState(() {
    f.types
      ..clear()
      ..add(type);
    _texte.clear();
  });

  Future<void> _filtres() async {
    await montrerFeuille<void>(
      context,
      titre: 'Filtres',
      contenu: (context) => _FeuilleFiltres(onChange: () => setState(() {})),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    final cherche = _requete.isNotEmpty || f.types.isNotEmpty;
    final resultats = cherche ? _resultats : const <Lieu>[];
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 6, marge, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/accueil')),
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
                        Expanded(
                          child: TextField(
                            controller: _texte,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (t) {
                              if (t.trim().isNotEmpty && !_recentes.contains(t.trim())) _recentes.insert(0, t.trim());
                            },
                            style: TextStyle(fontSize: 16, color: Couleurs.texte),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Un lieu, un créateur, une envie',
                              hintStyle: TextStyle(fontSize: 15, color: Couleurs.discret, fontWeight: FontWeight.w300),
                            ),
                          ),
                        ),
                        if (_texte.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(_texte.clear),
                            child: Semantics(
                              button: true,
                              label: 'Effacer',
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icone('fermer', taille: 18, couleur: Couleurs.discret),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RondVerre(icone: 'filtres', semantique: 'Filtres', point: f.actifs > 0, onTap: _filtres),
            ],
          ),
          const SizedBox(height: 16),
          if (!cherche) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final r in _recentes.take(6)) Pastille(texte: r, icone: 'horloge', onTap: () => _chercher(r))],
            ),
            const SizedBox(height: 24),
            const _TitreSection('Des idées de voyage'),
            _Idees(idees: _idees, onTap: _voirType),
            const SizedBox(height: 10),
            const _TitreSection('Populaire sur USW'),
            _Idees(idees: _populaires, onTap: _voirType),
          ] else if (resultats.isEmpty) ...[
            const SizedBox(height: 18),
            Icone('loupe', taille: 40, couleur: Couleurs.discret),
            const SizedBox(height: 12),
            Text(_requete.isEmpty ? 'Aucun lieu avec ces filtres' : 'Aucun résultat pour « $_requete »', style: Textes.sousTitre, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (_suggestion case final s?)
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('Vouliez-vous dire ', style: Textes.discret),
                  GestureDetector(
                    onTap: () => _chercher(s.nom),
                    child: Text(
                      s.nom,
                      style: Textes.discret.copyWith(color: Couleurs.texte, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                    ),
                  ),
                  Text(' ?', style: Textes.discret),
                ],
              )
            else
              Text('Essayez un mot plus court, ou retirez un filtre.', style: Textes.discret, textAlign: TextAlign.center),
            const SizedBox(height: 26),
            const _TitreSection('Lieux proches de votre recherche'),
            _Lieux(lieux: lieuxDemo.take(4).toList(), presDeMoi: false),
          ] else ...[
            Text(
              '${resultats.length} ${resultats.length > 1 ? 'lieux' : 'lieu'}'
              '${f.types.isNotEmpty ? ' · ${f.types.join(', ')}' : ''}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Couleurs.discret),
            ),
            const SizedBox(height: 10),
            _Lieux(lieux: resultats, presDeMoi: f.tri == 'Près de moi'),
          ],
        ],
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      header: true,
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      ),
    ),
  );
}

/// Les idees : des tuiles de photo assombries, le nom au milieu.
class _Idees extends StatelessWidget {
  const _Idees({required this.idees, required this.onTap});

  final List<(String, String, String)> idees;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final colonnes = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;
    return GridView.count(
      crossAxisCount: colonnes,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: colonnes == 3 ? 2 : 1.85,
      padding: const EdgeInsets.only(bottom: 14),
      children: [
        for (final (titre, photo, type) in idees)
          Appuyable(
            semantique: titre,
            onTap: () => onTap(type),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Photo(photo),
                  ColoredBox(color: Couleurs.hsl(229, 40, 8, 0.38)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        titre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Les lieux trouves, en mosaique plate facon Pinterest.
class _Lieux extends StatelessWidget {
  const _Lieux({required this.lieux, required this.presDeMoi});

  final List<Lieu> lieux;
  final bool presDeMoi;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var c = 0; c < 2; c++) ...[
        if (c > 0) const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              for (var i = c; i < lieux.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Appuyable(
                    semantique: lieux[i].nom,
                    onTap: () => context.push('/accueil/lieu/${lieux[i].id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(aspectRatio: lieux[i].ratio, child: PhotoArrondie(lieux[i].photos.first, rayon: 12)),
                        const SizedBox(height: 6),
                        Text(lieux[i].nom, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25)),
                        Text(
                          presDeMoi && lieux[i].distanceKm != null ? 'À ${lieux[i].distanceKm} km · ${lieux[i].nombre} photos' : '${lieux[i].nombre} photos',
                          style: TextStyle(fontSize: 12, color: Couleurs.discret),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ],
  );
}

/// La feuille des filtres (E04).
class _FeuilleFiltres extends StatefulWidget {
  const _FeuilleFiltres({required this.onChange});

  final VoidCallback onChange;

  @override
  State<_FeuilleFiltres> createState() => _FeuilleFiltresState();
}

class _FeuilleFiltresState extends State<_FeuilleFiltres> {
  final f = Filtres.instance;

  void _changer(VoidCallback c) {
    setState(c);
    widget.onChange();
  }

  Widget _groupe(String titre, List<Widget> pastilles) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: pastilles),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final types = {for (final l in lieuxDemo) l.type}.toList();
    final nombre = lieuxDemo
        .where((l) => (f.types.isEmpty || f.types.contains(l.type)) && (f.distanceKm == null || (l.distanceKm ?? 99999) <= f.distanceKm!))
        .length;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        _groupe('Pays', [
          for (final p in ['Bénin', 'Togo', 'Ghana', 'Nigeria']) Pastille(texte: p, retenue: f.pays == p, onTap: () => _changer(() => f.pays = p)),
        ]),
        _groupe('Types de lieux', [
          for (final t in types)
            Pastille(texte: t, retenue: f.types.contains(t), onTap: () => _changer(() => f.types.contains(t) ? f.types.remove(t) : f.types.add(t))),
        ]),
        _groupe('Distance', [
          for (final (nom, km) in const [('Partout', null), ('10 km', 10), ('50 km', 50), ('100 km', 100)])
            Pastille(texte: nom, retenue: f.distanceKm == km, onTap: () => _changer(() => f.distanceKm = km)),
        ]),
        _groupe('Trier', [
          for (final t in ['Pertinence', 'Près de moi', 'Récents']) Pastille(texte: t, retenue: f.tri == t, onTap: () => _changer(() => f.tri = t)),
        ]),
        Row(
          children: [
            Expanded(child: Text('Seulement les captures vérifiées', style: Textes.libelle)),
            Switch(value: f.verifiees, activeTrackColor: Couleurs.ocean, onChanged: (v) => _changer(() => f.verifiees = v)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            TextButton(
              onPressed: () => _changer(f.effacer),
              child: Text(
                'Tout effacer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Couleurs.texte),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BoutonVerre(texte: 'Voir $nombre ${nombre > 1 ? 'lieux' : 'lieu'}', plein: true, onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ],
    );
  }
}
