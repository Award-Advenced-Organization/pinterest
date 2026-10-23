// Le verre liquide de la maquette (maquette/styles/verre.css), en Flutter.
// De l eau plus que du verre : presque rien dans la masse, tout se joue sur
// les bords. Une masse a peine blanche, une arete claire en haut et plus
// douce en bas, une ombre portee douce. Pas de flou : sur le fond uni de USW
// il ne se verrait pas, et il couterait cher au telephone.
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import 'icone.dart';

/// clair : le verre ; ocean : l action principale ; retenu : choisi ;
/// rouge : ce qui retire ou signale ; limonade : ce qui valide (moderation).
enum TeinteVerre { clair, ocean, retenu, rouge, limonade }

class Verre extends StatelessWidget {
  const Verre({
    super.key,
    required this.child,
    this.rayon = Mesures.rayonBouton,
    this.teinte = TeinteVerre.clair,
    this.padding,
    this.ombre = true,
    this.surFond = true,
  });

  final Widget child;
  final double rayon;
  final TeinteVerre teinte;
  final EdgeInsetsGeometry? padding;
  final bool ombre;

  /// Pose sur le fond uni de la page. Flutter peint l ombre portee sous toute
  /// la surface (la CSS, seulement autour) : a travers une masse transparente
  /// on la verrait, en tache grise. On glisse donc le fond de la page dessous.
  /// Faux sur une photo ou une video : la masse doit rester transparente.
  final bool surFond;

  @override
  Widget build(BuildContext context) {
    final forme = BorderRadius.circular(rayon);
    final ocean = teinte == TeinteVerre.ocean;
    final masse = switch (teinte) {
      TeinteVerre.ocean => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Couleurs.oceanClair, Couleurs.oceanFonce]),
      TeinteVerre.rouge => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Couleurs.hsl(0, 84, 64), Couleurs.erreur]),
      TeinteVerre.limonade => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Couleurs.hsl(71, 88, 62), Couleurs.limonade]),
      TeinteVerre.retenu => LinearGradient(colors: [Couleurs.ocean.withValues(alpha: 0.1), Couleurs.ocean.withValues(alpha: 0.1)]),
      TeinteVerre.clair => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.4, 1],
        // La nuit, un verre plus discret : sinon il blanchit le fond sombre.
        colors: Couleurs.sombre
            ? [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.08)]
            : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.22)],
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: forme,
        color: surFond ? Couleurs.fond : null,
        boxShadow: ombre
            ? [
                BoxShadow(color: Couleurs.hsl(229, 40, 30, ocean ? 0.35 : 0.14), blurRadius: 0, spreadRadius: 0.5),
                BoxShadow(
                  color: ocean ? Couleurs.ombreOcean : Couleurs.ombre,
                  offset: Offset(0, ocean ? 14 : 10),
                  blurRadius: ocean ? 30 : 24,
                  spreadRadius: -14,
                ),
              ]
            : null,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: forme, gradient: masse),
        child: CustomPaint(
          foregroundPainter: _Arete(forme, retenu: teinte == TeinteVerre.retenu, ocean: ocean || teinte == TeinteVerre.rouge || teinte == TeinteVerre.limonade),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// L arete speculaire : un filet de lumiere vif en haut, doux en bas.
class _Arete extends CustomPainter {
  _Arete(this.forme, {required this.retenu, required this.ocean});

  final BorderRadius forme;
  final bool retenu;
  final bool ocean;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = forme.toRRect(rect.deflate(0.6));
    final trait = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = retenu ? 1.5 : 1.2;
    if (retenu) {
      trait.color = Couleurs.ocean;
    } else {
      final k = Couleurs.sombre && !ocean ? 0.4 : 1.0;
      trait.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: (ocean ? 0.6 : 0.95) * k),
          Colors.white.withValues(alpha: (ocean ? 0.1 : 0.25) * k),
          Colors.white.withValues(alpha: (ocean ? 0.25 : 0.6) * k),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(rect);
    }
    canvas.drawRRect(rrect, trait);
  }

  @override
  bool shouldRepaint(_Arete ancien) => ancien.forme != forme || ancien.retenu != retenu || ancien.ocean != ocean;
}

/// L appui. Une carte ou une photo se tasse un peu. Un objet de verre
/// (`verre`), comme sur iOS 26 : il gonfle sous le doigt, une lumiere s allume
/// la ou on touche, puis au relache il revient comme une goutte de gel, avec
/// un rebond (un vrai ressort : il garde l elan du geste).
class Appuyable extends StatefulWidget {
  const Appuyable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semantique,
    this.actif = true,
    this.verre = false,
    this.rayonVerre,
    this.gonflement = 0.12,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semantique;
  final bool actif;

  /// Un objet de verre : il gonfle et s eclaire au lieu de se tasser.
  final bool verre;

  /// La forme de la lumiere (le rayon du verre). Nul : pas de lumiere.
  final double? rayonVerre;

  /// De combien il gonfle (0,12 : un bouton rond ; moins pour un large bouton).
  final double gonflement;

  @override
  State<Appuyable> createState() => _AppuyableState();
}

class _AppuyableState extends State<Appuyable> with SingleTickerProviderStateMixin {
  // 0 au repos, 1 appuye ; le ressort du relache le fait passer un peu sous 0.
  late final AnimationController _c = AnimationController.unbounded(vsync: this);
  Offset? _point;
  bool _appuye = false;

  static final _ressortAppui = SpringDescription.withDampingRatio(mass: 1, stiffness: 700, ratio: 0.85);
  static final _ressortRelache = SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: 0.42);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _appuyer(Offset point) {
    if (!widget.actif) return;
    _appuye = true;
    setState(() => _point = point);
    _c.animateWith(SpringSimulation(_ressortAppui, _c.value, 1, _c.velocity));
  }

  Future<void> _relacher() async {
    if (!_appuye) return;
    _appuye = false;
    // Un toucher bref : le geste va jusqu au bout avant de revenir.
    if (_c.value < 0.7) await _c.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);
    if (!mounted || _appuye) return;
    _c.animateWith(SpringSimulation(_ressortRelache, _c.value, 0, _c.velocity));
  }

  @override
  Widget build(BuildContext context) {
    final actif = widget.actif && (widget.onTap != null || widget.onLongPress != null);
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      button: true,
      enabled: actif,
      label: widget.semantique,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: actif && !reduit ? (d) => _appuyer(d.localPosition) : null,
        onTapUp: actif ? (_) => _relacher() : null,
        onTapCancel: _relacher,
        onTap: actif ? widget.onTap : null,
        onLongPress: actif ? widget.onLongPress : null,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final v = _c.value;
            final echelle = widget.verre ? 1 + widget.gonflement * v : 1 - 0.035 * v;
            final rayon = widget.rayonVerre;
            return Transform.scale(
              scale: echelle,
              child: !widget.verre || rayon == null || _point == null || v <= 0.01
                  ? child
                  : Stack(
                      children: [
                        child!,
                        // La lumiere du toucher, dans la forme du verre.
                        Positioned.fill(
                          child: IgnorePointer(child: CustomPaint(painter: _Lumiere(_point!, rayon, (v.clamp(0.0, 1.0)) * 0.32))),
                        ),
                      ],
                    ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class _Lumiere extends CustomPainter {
  _Lumiere(this.point, this.rayon, this.force);

  final Offset point;
  final double rayon;
  final double force;

  @override
  void paint(Canvas canvas, Size size) {
    final forme = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(rayon));
    canvas.clipRRect(forme);
    final portee = size.longestSide * 0.9;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: force),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: point, radius: portee)),
    );
  }

  @override
  bool shouldRepaint(_Lumiere ancien) => ancien.point != point || ancien.force != force || ancien.rayon != rayon;
}

/// Le bouton : un rectangle arrondi, pas une pilule, fait de verre liquide.
class BoutonVerre extends StatelessWidget {
  const BoutonVerre({
    super.key,
    required this.texte,
    this.onTap,
    this.plein = false,
    this.icone,
    this.iconeApres,
    this.large = true,
    this.widgetIcone,
    this.teinte,
  });

  final String texte;
  final VoidCallback? onTap;
  final bool plein;

  /// Rouge (signaler, refuser) ou limonade (publier, en moderation) ; sinon
  /// l ocean si plein, le verre clair sinon.
  final TeinteVerre? teinte;
  final String? icone;
  final String? iconeApres;
  final bool large;
  final Widget? widgetIcone;

  @override
  Widget build(BuildContext context) {
    final masse = teinte ?? (plein ? TeinteVerre.ocean : TeinteVerre.clair);
    final couleur = switch (masse) {
      TeinteVerre.ocean || TeinteVerre.rouge => Colors.white,
      TeinteVerre.limonade => Couleurs.encreLimonade,
      _ => Couleurs.texte,
    };
    final contenu = DefaultTextStyle.merge(
      style: Textes.bouton.copyWith(color: couleur),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widgetIcone != null) ...[widgetIcone!, const SizedBox(width: 9)],
          if (icone != null) ...[Icone(icone!, taille: 19, couleur: couleur), const SizedBox(width: 9)],
          Flexible(child: Text(texte, overflow: TextOverflow.ellipsis)),
          if (iconeApres != null) ...[const SizedBox(width: 9), Icone(iconeApres!, taille: 19, couleur: couleur)],
        ],
      ),
    );
    return AnimatedOpacity(
      opacity: onTap == null ? 0.38 : 1,
      duration: Durees.interface,
      child: Appuyable(
        onTap: onTap,
        semantique: texte,
        verre: true,
        rayonVerre: Mesures.rayonBouton,
        gonflement: large ? 0.03 : 0.06,
        child: Verre(
          teinte: masse,
          child: SizedBox(
            height: 50,
            width: large ? double.infinity : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(child: contenu),
            ),
          ),
        ),
      ),
    );
  }
}

/// Le bouton rond : retour, recherche, notifications.
class RondVerre extends StatelessWidget {
  const RondVerre({
    super.key,
    required this.icone,
    required this.semantique,
    this.onTap,
    this.point = false,
    this.taille = 44,
    this.surPhoto = false,
    this.encre,
  });

  final String icone;
  final String semantique;
  final VoidCallback? onTap;
  final bool point;
  final double taille;

  /// Pose sur une photo : le meme verre liquide, mais sans le fond de la
  /// page ni ombre portee dessous (elle ferait une tache grise a travers).
  final bool surPhoto;

  /// La couleur de l icone : l encre, ou blanc sur un fond sombre.
  final Color? encre;

  @override
  Widget build(BuildContext context) => Appuyable(
    onTap: onTap,
    semantique: semantique,
    verre: true,
    rayonVerre: taille / 2,
    child: _fond(
      SizedBox(
        width: taille,
        height: taille,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icone(icone, taille: 22, couleur: encre ?? Couleurs.texte),
            if (point)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Couleurs.erreur,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _fond(Widget enfant) => Verre(rayon: taille / 2, surFond: !surPhoto, ombre: !surPhoto, child: enfant);
}

/// La pastille de filtre : un verre fin.
class Pastille extends StatelessWidget {
  const Pastille({super.key, required this.texte, this.icone, this.iconeApres, this.retenue = false, this.onTap});

  final String texte;
  final String? icone;
  final String? iconeApres;
  final bool retenue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = retenue ? Couleurs.surEncre : Couleurs.texte;
    return Appuyable(
      onTap: onTap ?? () {},
      semantique: texte,
      verre: true,
      rayonVerre: retenue ? null : 18,
      gonflement: 0.07,
      child: retenue
          ? Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Couleurs.texte, borderRadius: BorderRadius.circular(18)),
              child: _contenu(couleur),
            )
          : Verre(
              rayon: 18,
              child: Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 14), child: _contenu(couleur)),
            ),
    );
  }

  Widget _contenu(Color couleur) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icone != null) ...[Icone(icone!, taille: 18, couleur: couleur), const SizedBox(width: 7)],
      Text(
        texte,
        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: couleur),
      ),
      if (iconeApres != null) ...[const SizedBox(width: 6), Icone(iconeApres!, taille: 16, couleur: couleur)],
    ],
  );
}

/// Le badge d une capture : verifiee (limonade) ou declaree. Sur une carte
/// de mosaique, l icone seule suffit (`seul`) : elle dit deja « verifiee ».
class BadgeCapture extends StatelessWidget {
  const BadgeCapture({super.key, required this.verifie, this.court = false, this.seul = false});

  final bool verifie;

  /// « Vérifiée », plus petit (la fiche de capture).
  final bool court;

  /// L icone seule, dans sa pastille ronde (les cartes).
  final bool seul;

  @override
  Widget build(BuildContext context) {
    final encre = verifie ? Couleurs.encreLimonade : Couleurs.discret;
    final fond = verifie ? Couleurs.limonade : Couleurs.surface.withValues(alpha: 0.7);
    if (seul) {
      return Semantics(
        label: verifie ? 'Capture vérifiée' : 'Informations déclarées',
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
          child: Icone(verifie ? 'verifie' : 'alerte', taille: 17, couleur: encre),
        ),
      );
    }
    return Container(
      height: court ? 24 : 26,
      padding: EdgeInsets.fromLTRB(court ? 6 : 7, 0, court ? 9 : 10, 0),
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(13)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icone(verifie ? 'verifie' : 'alerte', taille: court ? 15 : 16, couleur: encre),
          SizedBox(width: court ? 4 : 5),
          Text(
            verifie ? (court ? 'Vérifiée' : 'Capture vérifiée') : (court ? 'Déclarée' : 'Informations déclarées'),
            style: TextStyle(fontSize: court ? 11.5 : 12.5, fontWeight: FontWeight.w600, color: encre),
          ),
        ],
      ),
    );
  }
}

/// La plaque : le support des informations et des listes (fiche de capture,
/// groupes de reglages, motifs), a plat comme les cartes des Parametres du
/// telephone ou de Bloc-notes. Un fond plein un ton au-dessus de la page,
/// des coins ronds, ni bord, ni ombre, ni relief. Le verre reste aux boutons
/// et a ce qui flotte.
class Plaque extends StatelessWidget {
  const Plaque({super.key, required this.child, this.rayon = 22, this.padding});

  final Widget child;
  final double rayon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(rayon)),
    child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
  );
}
