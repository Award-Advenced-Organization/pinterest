// E00 Ouverture : USW devient United State of World. Le logo arrive en
// tournant, puis U, S et W montent l un apres l autre, et chaque mot se deroule.
// Enfin l ecran se leve comme un rideau et decouvre la bienvenue, deja la
// dessous : elle arrive pendant que le rideau monte, sans changer de page.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/jetons.dart';
import '../widgets/icone.dart';
import '../widgets/mouvement.dart';
import 'bienvenue.dart';

class EcranOuverture extends StatefulWidget {
  const EcranOuverture({super.key});

  @override
  State<EcranOuverture> createState() => _EcranOuvertureState();
}

class _EcranOuvertureState extends State<EcranOuverture> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4600));
  late final AnimationController _rideau = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final Animation<double> _leve = CurvedAnimation(parent: _rideau, curve: Courbes.signature);
  Timer? _suite;

  /// La bienvenue est montee sous le rideau quand il commence a se lever.
  bool _dessous = false;

  /// Le rideau est parti : il ne reste que la bienvenue.
  bool _parti = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _suite = Timer(const Duration(milliseconds: 4900), _lever);
    _rideau.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() => _parti = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (animationsReduites(context)) _c.value = 1;
  }

  void _lever() {
    if (!mounted) return;
    setState(() => _dessous = true);
    if (animationsReduites(context)) {
      _rideau.value = 1;
    } else {
      _rideau.forward();
    }
  }

  @override
  void dispose() {
    _suite?.cancel();
    _c.dispose();
    _rideau.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Toujours a la meme place dans la pile : elle garde son etat quand
      // le rideau s en va.
      if (_dessous)
        AnimatedBuilder(
          animation: _leve,
          builder: (context, child) => Transform.translate(offset: Offset(0, 48 * (1 - _leve.value)), child: child),
          child: const EcranBienvenue(),
        )
      else
        ColoredBox(color: Couleurs.fond, child: const SizedBox.expand()),
      if (!_parti)
        AnimatedBuilder(
          animation: _leve,
          builder: (context, child) {
            final v = _leve.value;
            final rayon = Radius.circular(32 * (v * 6).clamp(0.0, 1.0));
            return FractionalTranslation(
              translation: Offset(0, -v),
              // Un filet sous le bord du rideau : les deux ecrans ont le meme fond.
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: v > 0 ? Couleurs.voile : null,
                  borderRadius: BorderRadius.vertical(bottom: rayon),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: v > 0 ? 1 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(bottom: rayon),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: _rideauOuverture(context),
        ),
    ],
  );

  // Une tranche de l animation, en secondes, sur la courbe souple.
  Animation<double> _tranche(double debut, double duree) => CurvedAnimation(
    parent: _c,
    curve: Interval(debut / 4.6, ((debut + duree) / 4.6).clamp(0, 1), curve: Courbes.souple),
  );

  Widget _rideauOuverture(BuildContext context) {
    final taille = (MediaQuery.sizeOf(context).width * 0.074).clamp(28.0, 60.0);
    final style = TextStyle(fontSize: taille, fontWeight: FontWeight.w700, letterSpacing: -0.02 * taille, color: Couleurs.texte, height: 1.1);

    Widget mot(String initiale, String suite, Color couleur, double tInitiale, double tSuite, {bool fin = false}) {
      final monte = _tranche(tInitiale, 1.1);
      final deroule = _tranche(tSuite, 1.2);
      return AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Opacity(
              opacity: monte.value,
              child: Transform.translate(
                offset: Offset(0, (1 - monte.value) * taille * 0.6),
                child: Text(initiale, style: style.copyWith(color: couleur)),
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: deroule.value,
                child: Opacity(
                  opacity: deroule.value,
                  child: Text(suite, style: style),
                ),
              ),
            ),
            SizedBox(width: fin ? 0 : taille * 0.24 * deroule.value),
          ],
        ),
      );
    }

    final logo = _tranche(0, 0.9);
    final of = _tranche(3.25, 1);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'United State of World',
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: logo,
                  // A l arrivee, un demi-tour de plus qui ralentit : le logo
                  // entre lance, puis garde son tour tranquille.
                  builder: (context, child) => Opacity(
                    opacity: logo.value,
                    child: Transform.rotate(
                      angle: -math.pi * logo.value,
                      child: Transform.scale(scale: 0.85 + 0.15 * logo.value, child: child),
                    ),
                  ),
                  child: const LogoQuiTourne(taille: 72, tour: Duration(milliseconds: 2400)),
                ),
                const SizedBox(height: 28),
                FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      mot('U', 'nited', Couleurs.ocean, 0.2, 1.9),
                      mot('S', 'tate', Couleurs.ocean, 0.65, 2.6),
                      AnimatedBuilder(
                        animation: of,
                        builder: (context, _) => ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: of.value,
                            child: Opacity(
                              opacity: of.value,
                              child: Padding(
                                padding: EdgeInsets.only(right: taille * 0.24),
                                child: Text(
                                  'of',
                                  style: style.copyWith(fontWeight: FontWeight.w300, color: Couleurs.discret),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      mot('W', 'orld', Couleurs.limonade, 1.1, 3.75, fin: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
