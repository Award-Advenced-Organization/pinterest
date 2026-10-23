import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/jetons.dart';
import 'mouvement.dart';

/// Une photo de demonstration (assets/photos). L API servira plus tard les
/// variantes WebP 480, 1 080 et 2 160 px.
class Photo extends StatelessWidget {
  const Photo(this.id, {super.key, this.fit = BoxFit.cover});

  final String id;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/photos/$id.webp',
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    gaplessPlayback: true,
    errorBuilder: (context, _, _) => ColoredBox(color: Couleurs.photoVide),
  );
}

/// Une photo aux coins arrondis, peinte d un trait : moins cher qu une
/// decoupe (ClipRRect), qui cree un calque.
class PhotoArrondie extends StatelessWidget {
  const PhotoArrondie(this.id, {super.key, this.rayon = Mesures.rayonCarte});

  final String id;
  final double rayon;

  // Elle prend toute la place qu on lui donne : sans enfant, une boite
  // decoree ferait zero de large. Le fond reste visible tant que la photo
  // n est pas la (un emplacement qui defile, meme sans image).
  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Couleurs.photoVide,
        borderRadius: BorderRadius.circular(rayon),
        image: DecorationImage(image: AssetImage('assets/photos/$id.webp'), fit: BoxFit.cover, onError: (_, _) {}),
      ),
    ),
  );
}

/// Une pile de photos d un lieu : la premiere devant, deux derriere, et
/// toutes les 4 s celle de devant glisse et s efface, la suivante avance.
///
/// Performance : entre deux passages, rien ne bouge et rien ne se redessine
/// (une minuterie attend, l animation ne dure que le passage, 0,7 s). Les
/// photos sont peintes avec leur opacite et leurs coins arrondis par le
/// pinceau (DecorationImage) : ni calque d opacite ni decoupe, qui coutent
/// cher aux telephones modestes. Transform seulement pour le reste.
class Pile extends StatefulWidget {
  const Pile({super.key, required this.photos, this.rayon = Mesures.rayonCarte, this.decalage = Duration.zero});

  final List<String> photos;
  final double rayon;

  /// Les piles de l accueil ne tournent pas toutes ensemble.
  final Duration decalage;

  @override
  State<Pile> createState() => _PileState();
}

class _PileState extends State<Pile> with SingleTickerProviderStateMixin {
  static const _attenteEntreDeux = Duration(milliseconds: 3300);
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Courbes.pile);
  int _devant = 0;
  Timer? _attente;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _devant = (_devant + 1) % widget.photos.length);
        _c.value = 0;
        _attendre(_attenteEntreDeux);
      }
    });
    _attendre(widget.decalage + _attenteEntreDeux);
  }

  void _attendre(Duration duree) {
    _attente?.cancel();
    _attente = Timer(duree, () {
      if (!mounted) return;
      // Hors de l ecran (TickerMode coupe) ou mouvements reduits : on attend le tour suivant.
      if (animationsReduites(context) || !TickerMode.valuesOf(context).enabled) {
        _attendre(_attenteEntreDeux);
      } else {
        _c.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _attente?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.photos.length;
    final rayon = BorderRadius.circular(widget.rayon);
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, contraintes) {
          final hauteur = contraintes.maxHeight;
          return AnimatedBuilder(
            animation: _t,
            builder: (context, _) {
              final t = _t.value;
              // A plat, sans ombre, comme les mosaiques de Pinterest.
              Widget carte(int rang) {
                // Le rang effectif : 0 devant, 1 et 2 derriere, 3 cache ; pendant
                // le passage, tout monte d un rang et celle de devant passe a -1.
                final r = rang - t;
                double opacite, dy, echelle;
                if (r < 0) {
                  // Elle part : elle glisse vers le bas et s efface.
                  opacite = 1 + r;
                  dy = -r * 0.12 * hauteur;
                  echelle = 1 - 0.02 * -r;
                } else if (r <= 1) {
                  opacite = 1 - 0.25 * r;
                  dy = -8 * r;
                  echelle = 1 - 0.07 * r;
                } else if (r <= 2) {
                  opacite = 0.75 - 0.3 * (r - 1);
                  dy = -8 - 7 * (r - 1);
                  echelle = 0.93 - 0.07 * (r - 1);
                } else {
                  opacite = 0.45 * (3 - r);
                  dy = -15;
                  echelle = 0.86;
                }
                if (opacite <= 0.01) return const SizedBox.shrink();
                return Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.translationValues(0, dy, 0)..scaleByDouble(echelle, echelle, 1, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: rayon,
                      image: DecorationImage(
                        image: AssetImage('assets/photos/${widget.photos[(_devant + rang) % n]}.webp'),
                        fit: BoxFit.cover,
                        opacity: opacite.clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                );
              }

              return Stack(fit: StackFit.expand, children: [carte(3), carte(2), carte(1), carte(0)]);
            },
          );
        },
      ),
    );
  }
}
