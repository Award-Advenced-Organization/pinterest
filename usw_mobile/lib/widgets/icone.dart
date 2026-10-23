import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/jetons.dart';

/// Une icone du pack USW (assets/icones) : a l encre, trait appuye comme les
/// symboles d iOS. Sa couleur suit le texte autour, comme `currentColor`.
class Icone extends StatelessWidget {
  const Icone(this.nom, {super.key, this.taille = 24, this.couleur});

  final String nom;
  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final teinte = couleur ?? DefaultTextStyle.of(context).style.color ?? Couleurs.texte;
    return SvgPicture.asset(
      'assets/icones/$nom.svg',
      width: taille,
      height: taille,
      theme: SvgTheme(currentColor: teinte),
    );
  }
}

/// Le logo officiel de USW. `sombre` : la version pour fond sombre.
class LogoUsw extends StatelessWidget {
  const LogoUsw({super.key, this.taille = 48, this.sombre});

  final double taille;
  final bool? sombre;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    (sombre ?? Couleurs.sombre) ? 'assets/logo/usw-sombre.svg' : 'assets/logo/usw.svg',
    width: taille,
    height: taille,
    semanticsLabel: 'USW',
  );
}

/// Le logo qui tourne, comme un yin et yang : les trois gouttes se suivent,
/// la tete ronde devant (sens inverse des aiguilles). C est l attente de USW :
/// l ouverture et tous les chargements, a la place d un cercle de progression.
class LogoQuiTourne extends StatefulWidget {
  const LogoQuiTourne({super.key, this.taille = 40, this.sombre, this.tour = const Duration(milliseconds: 1800)});

  final double taille;

  /// Nul : suit le theme (la goutte noire devient blanche la nuit).
  final bool? sombre;

  /// La duree d un tour complet.
  final Duration tour;

  @override
  State<LogoQuiTourne> createState() => _LogoQuiTourneState();
}

class _LogoQuiTourneState extends State<LogoQuiTourne> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.tour);
  late final Animation<double> _tours = Tween<double>(begin: 0, end: -1).animate(_c);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mouvements reduits : le logo reste immobile.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Chargement',
    child: ExcludeSemantics(
      child: RotationTransition(
        turns: _tours,
        child: LogoUsw(taille: widget.taille, sombre: widget.sombre),
      ),
    ),
  );
}
