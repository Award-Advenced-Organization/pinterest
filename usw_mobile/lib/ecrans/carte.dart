// E11 Carte : chaque lieu est un repere en forme de photo (un petit triangle
// de lecture pour les reels). Toucher un repere ouvre son apercu en bas :
// voir le reel ou le lieu, et Y aller. Fond de carte clair et sobre (CARTO,
// donnees OpenStreetMap). Le lot 4 branchera GET /api/v1/carte?bbox=...
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../donnees/demo.dart';
import '../donnees/session.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/feuille.dart';
import '../widgets/icone.dart';
import '../widgets/lentille.dart';
import '../widgets/page.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

/// Sous les tests, pas de fond de carte : ni reseau ni cache de tuiles.
final _sousTest = Platform.environment.containsKey('FLUTTER_TEST');

/// Cotonou : la position de demonstration du membre.
const _maPosition = LatLng(6.3703, 2.3912);

class EcranCarte extends StatefulWidget {
  const EcranCarte({super.key});

  @override
  State<EcranCarte> createState() => _EcranCarteState();
}

class _EcranCarteState extends State<EcranCarte> {
  final _carte = MapController();
  String _filtre = 'Tout';
  Lieu? _choisi;
  double _zoom = 6.4;

  // Les reperes trop proches a ce zoom (moins de 52 px) se regroupent.
  List<List<Lieu>> get _groupes {
    final echelle = 256 * math.pow(2, _zoom) / 360;
    final groupes = <List<Lieu>>[];
    for (final l in _lieux) {
      final proche = groupes.where((g) {
        final dx = (g.first.longitude - l.longitude) * echelle;
        final dy = (g.first.latitude - l.latitude) * echelle * 1.01;
        return math.sqrt(dx * dx + dy * dy) < 52;
      }).firstOrNull;
      if (proche != null) {
        proche.add(l);
      } else {
        groupes.add([l]);
      }
    }
    return groupes;
  }

  void _ouvrirGroupe(List<Lieu> g) {
    final lat = g.map((l) => l.latitude).reduce((a, b) => a + b) / g.length;
    final lon = g.map((l) => l.longitude).reduce((a, b) => a + b) / g.length;
    _carte.move(LatLng(lat, lon), (_zoom + 2).clamp(4.0, 18.0));
  }

  bool _aUnReel(Lieu l) => reelsDemo.any((r) => r.lieu == l.id);

  List<Lieu> get _lieux => switch (_filtre) {
    'Reels' => lieuxDemo.where(_aUnReel).toList(),
    'Photos' => lieuxDemo.where((l) => !_aUnReel(l)).toList(),
    _ => lieuxDemo,
  };

  void _choisir(Lieu l) {
    setState(() => _choisi = l);
    _carte.move(LatLng(l.latitude - 0.6, l.longitude), _carte.camera.zoom.clamp(7.0, 18.0));
  }

  // E37 position : refusee a l inscription, on propose de l autoriser ou de
  // choisir une ville.
  Future<void> _positionDesactivee() => montrerFeuille<void>(
    context,
    titre: 'La position est désactivée',
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pour voir les lieux autour de vous, autorisez la position. Vous pouvez aussi choisir une ville.', style: Textes.discret),
          const SizedBox(height: 18),
          BoutonVerre(
            texte: 'Autoriser la position',
            plein: true,
            onTap: () {
              Navigator.pop(f);
              setState(() => Session.instance.position = true);
              _carte.move(_maPosition, 9);
            },
          ),
          const SizedBox(height: 10),
          BoutonVerre(
            texte: 'Choisir une ville',
            onTap: () {
              Navigator.pop(f);
              _carte.move(const LatLng(6.3703, 2.3912), 11);
              bulle(context, 'Cotonou', titre: 'Ville choisie', icone: 'lieu');
            },
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final bas = MediaQuery.paddingOf(context).bottom + Mesures.hautOnglets + 26;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _carte,
            options: MapOptions(
              initialCenter: const LatLng(8.6, 2.2),
              initialZoom: 6.4,
              minZoom: 4,
              maxZoom: 18,
              backgroundColor: Couleurs.sombre ? const Color(0xFF262626) : const Color(0xFFECEEF4),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onTap: (_, _) => setState(() => _choisi = null),
              onPositionChanged: (camera, _) {
                if ((camera.zoom - _zoom).abs() > 0.05) setState(() => _zoom = camera.zoom);
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
              MarkerLayer(
                markers: [
                  for (final g in _groupes)
                    Marker(
                      point: LatLng(g.first.latitude, g.first.longitude),
                      width: 62,
                      height: 62,
                      child: g.length == 1
                          ? _Repere(lieu: g.first, reel: _aUnReel(g.first), choisi: _choisi?.id == g.first.id, onTap: () => _choisir(g.first))
                          : _Repere(lieu: g.first, reel: false, choisi: false, nombre: g.length, onTap: () => _ouvrirGroupe(g)),
                    ),
                  // Ma position : un point ocean cercle de blanc.
                  Marker(
                    point: _maPosition,
                    width: 22,
                    height: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Couleurs.ocean,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Le haut : la recherche et les filtres, en verre sur la carte.
          Positioned(
            top: haut + 6,
            left: marge,
            right: marge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Appuyable(
                        semantique: 'Rechercher un lieu',
                        verre: true,
                        rayonVerre: 25,
                        gonflement: 0.03,
                        onTap: () => context.push('/accueil/recherche'),
                        child: _Givre(
                          rayon: 25,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icone('loupe', taille: 21, couleur: Couleurs.discret),
                                const SizedBox(width: 10),
                                Text('Rechercher un lieu', style: TextStyle(fontSize: 15, color: Couleurs.discret)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Appuyable(
                      semantique: 'Filtres',
                      verre: true,
                      rayonVerre: 25,
                      onTap: () => context.push('/accueil/recherche'),
                      child: _Givre(
                        rayon: 25,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: Icone('filtres', taille: 22, couleur: Couleurs.texte)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      for (final f in ['Tout', 'Reels', 'Photos', 'Captures vérifiées']) ...[
                        Pastille(texte: f, retenue: _filtre == f, onTap: () => setState(() => _filtre = f)),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // L attribution du fond de carte, discrete.
          Positioned(
            left: marge + 4,
            bottom: bas - 18,
            child: IgnorePointer(
              child: Text('© OpenStreetMap · CARTO', style: TextStyle(fontSize: 10.5, color: Couleurs.discret)),
            ),
          ),
          // Revenir a ma position.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 520),
            curve: Courbes.ressort,
            right: marge,
            bottom: _choisi == null ? bas : bas + 168,
            child: Appuyable(
              semantique: 'Ma position',
              verre: true,
              rayonVerre: 25,
              onTap: () => Session.instance.position ? _carte.move(_maPosition, 9) : _positionDesactivee(),
              child: _Givre(
                rayon: 25,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(child: Icone('cible', taille: 23, couleur: Couleurs.texte)),
                ),
              ),
            ),
          ),
          // L apercu du repere choisi : il monte du bas, au ressort.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 560),
            curve: Courbes.ressort,
            left: marge,
            right: marge,
            bottom: _choisi == null ? -240 : bas,
            child: _choisi == null ? const SizedBox(height: 150) : _Apercu(lieu: _choisi!, reel: reelsDemo.where((r) => r.lieu == _choisi!.id).firstOrNull),
          ),
        ],
      ),
    );
  }
}

/// Le verre sur la carte : depoli leger (lentille quand elle est la) et blanc.
class _Givre extends StatelessWidget {
  const _Givre({required this.rayon, required this.child});

  final double rayon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Lentille(
    rayon: rayon,
    flou: 10,
    child: DecoratedBox(
      decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(rayon)),
      child: Verre(rayon: rayon, surFond: false, ombre: false, child: child),
    ),
  );
}

class _Repere extends StatelessWidget {
  const _Repere({required this.lieu, required this.reel, required this.choisi, required this.onTap, this.nombre = 1});

  final Lieu lieu;
  final bool reel;
  final bool choisi;
  final VoidCallback onTap;

  /// Un groupe de reperes : leur nombre, en pastille.
  final int nombre;

  @override
  Widget build(BuildContext context) => Appuyable(
    semantique: nombre > 1 ? '$nombre lieux' : lieu.nom,
    verre: true,
    gonflement: 0.15,
    onTap: onTap,
    child: Center(
      child: AnimatedScale(
        scale: choisi ? 1.18 : 1,
        duration: const Duration(milliseconds: 420),
        curve: Courbes.ressort,
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: choisi ? Couleurs.texte : Couleurs.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Couleurs.hsl(229, 40, 20, 0.28), offset: const Offset(0, 4), blurRadius: 10, spreadRadius: -2)],
          ),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              PhotoArrondie(lieu.photos.first, rayon: 11.5),
              if (nombre > 1)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Couleurs.texte,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$nombre',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              if (reel)
                Positioned(
                  right: 3,
                  bottom: 3,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                    child: const Icone('lecture', taille: 10, couleur: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Apercu extends StatelessWidget {
  const _Apercu({required this.lieu, required this.reel});

  final Lieu lieu;
  final Reel? reel;

  Future<void> _yAller(BuildContext context) async {
    final itineraire = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${lieu.latitude},${lieu.longitude}');
    final ouvert = await launchUrl(itineraire, mode: LaunchMode.externalApplication);
    if (!ouvert && context.mounted) bulle(context, "Maps n'a pas pu s'ouvrir.");
  }

  @override
  Widget build(BuildContext context) {
    final r = reel;
    return _Givre(
      rayon: 26,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              height: 128,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoArrondie(r?.photo ?? lieu.photos.first, rayon: 16),
                  if (r != null)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          '${r.duree ~/ 60}:${(r.duree % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lieu.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icone('telephone', taille: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          r != null ? '${r.appareil} · ${r.pseudo}' : '${lieu.nombre} photos · ${lieu.region}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: Couleurs.discret),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const BadgeCapture(verifie: true, court: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: BoutonVerre(
                          texte: r != null ? 'Voir le reel' : 'Voir le lieu',
                          onTap: () => r != null ? context.go('/reels') : context.push('/accueil/lieu/${lieu.id}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BoutonVerre(
                        texte: lieu.distanceKm != null ? '${lieu.distanceKm} km' : 'Y aller',
                        plein: true,
                        large: false,
                        widgetIcone: const Icone('y-aller', taille: 19),
                        onTap: () => _yAller(context),
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
