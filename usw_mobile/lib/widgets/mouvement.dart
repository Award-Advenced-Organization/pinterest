// Les entrees de la charte du mouvement : le mouvement explique, il ne decore
// pas. Chaque titre monte mot a mot, chaque bloc monte a son tour. Le reglage
// systeme « reduire les animations » l emporte sur tout.
import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/jetons.dart';

bool animationsReduites(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Un bloc qui monte et apparait, apres `delai`.
class Monte extends StatefulWidget {
  const Monte({super.key, required this.child, this.delai = Duration.zero, this.duree = Durees.entree, this.distance = 18});

  final Widget child;
  final Duration delai;
  final Duration duree;
  final double distance;

  @override
  State<Monte> createState() => _MonteState();
}

class _MonteState extends State<Monte> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duree);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Courbes.signature);
  Timer? _attente;

  @override
  void initState() {
    super.initState();
    if (widget.delai == Duration.zero) {
      _c.forward();
    } else {
      _attente = Timer(widget.delai, _c.forward);
    }
  }

  @override
  void dispose() {
    _attente?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (animationsReduites(context)) return widget.child;
    // FadeTransition : l opacite change sans reconstruire le bloc.
    return FadeTransition(
      opacity: _t,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Transform.translate(offset: Offset(0, (1 - _t.value) * widget.distance), child: child),
        child: widget.child,
      ),
    );
  }
}

/// Un titre qui monte mot a mot, chaque mot sorti de sous sa ligne.
class MotsQuiMontent extends StatelessWidget {
  const MotsQuiMontent(this.texte, {super.key, required this.style, this.delai = Duration.zero, this.centre = false});

  final String texte;
  final TextStyle style;
  final Duration delai;
  final bool centre;

  @override
  Widget build(BuildContext context) {
    final mots = texte.split(' ');
    return Semantics(
      label: texte,
      header: true,
      child: ExcludeSemantics(
        child: Wrap(
          alignment: centre ? WrapAlignment.center : WrapAlignment.start,
          children: [
            for (var k = 0; k < mots.length; k++)
              ClipRect(
                child: Monte(
                  delai: delai + Duration(milliseconds: 60 * k),
                  distance: (style.fontSize ?? 30) * 1.1,
                  child: Text(k < mots.length - 1 ? '${mots[k]} ' : mots[k], style: style),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Les trois traits de progression : celui de l etape se remplit.
class Progression extends StatelessWidget {
  const Progression({super.key, required this.etape, this.total = 3, this.avance});

  final int etape;
  final int total;

  /// La part remplie du trait en cours (0 a 1). Nulle : plein.
  final Animation<double>? avance;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Étape ${etape + 1} sur $total',
    child: Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 3,
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: Couleurs.voile)),
                    if (i < etape) Positioned.fill(child: ColoredBox(color: Couleurs.texte)),
                    if (i == etape)
                      Positioned.fill(
                        child: avance == null
                            ? ColoredBox(color: Couleurs.texte)
                            : AnimatedBuilder(
                                animation: avance!,
                                builder: (context, _) => FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: avance!.value,
                                  child: ColoredBox(color: Couleurs.texte),
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
