// Le message apres une action (E37 « bulles »), a la maniere d iOS et des
// notifications de SafeVault : une banniere de verre depoli descend du haut
// de l ecran avec l icone de USW, dit ce qui vient de se passer, puis se
// retire seule (5,2 s), d un toucher ou d un glisser vers le haut. Trois au
// plus, l une sous l autre.
import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/jetons.dart';
import 'icone.dart';
import 'verre.dart';

void bulle(BuildContext context, String texte, {String titre = 'USW', String? icone}) {
  final overlay = Navigator.maybeOf(context, rootNavigator: true)?.overlay;
  if (overlay == null) return;
  _Bannieres.instance.montrer(overlay, titre, texte);
}

class _Annonce {
  _Annonce(this.titre, this.texte);

  final String titre;
  final String texte;
  final cle = UniqueKey();
}

class _Bannieres {
  _Bannieres._();
  static final instance = _Bannieres._();

  final _liste = <_Annonce>[];
  OverlayEntry? _entree;

  void montrer(OverlayState overlay, String titre, String texte) {
    if (_liste.length >= 3) _liste.removeAt(0);
    _liste.add(_Annonce(titre, texte));
    if (_entree == null) {
      _entree = OverlayEntry(
        builder: (_) => _Pile(annonces: _liste, onFin: _retirer),
      );
      overlay.insert(_entree!);
    } else {
      _entree!.markNeedsBuild();
    }
  }

  void _retirer(_Annonce annonce) {
    _liste.remove(annonce);
    if (_liste.isEmpty) {
      _entree?.remove();
      _entree = null;
    } else {
      _entree?.markNeedsBuild();
    }
  }
}

class _Pile extends StatelessWidget {
  const _Pile({required this.annonces, required this.onFin});

  final List<_Annonce> annonces;
  final void Function(_Annonce) onFin;

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final largeur = MediaQuery.sizeOf(context).width;
    return Positioned(
      top: haut + 8,
      left: 0,
      right: 0,
      // Au-dessus de toute l application, hors des ecrans : elle prend ici
      // le style de texte de USW (police, pas de soulignement d alerte).
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: (largeur - 24).clamp(0.0, 420.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final a in annonces)
                  Padding(
                    key: a.cle,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Banniere(annonce: a, onFin: () => onFin(a)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banniere extends StatefulWidget {
  const _Banniere({required this.annonce, required this.onFin});

  final _Annonce annonce;
  final VoidCallback onFin;

  @override
  State<_Banniere> createState() => _BanniereState();
}

class _BanniereState extends State<_Banniere> with SingleTickerProviderStateMixin {
  // Entree au ressort (0,6 s), sortie a la courbe d interface (0,35 s).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    reverseDuration: const Duration(milliseconds: 350),
  )..forward();
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Courbes.ressort, reverseCurve: Courbes.interface.flipped);
  Timer? _minuterie;

  @override
  void initState() {
    super.initState();
    _minuterie = Timer(const Duration(milliseconds: 5200), _sortir);
  }

  void _sortir() {
    _minuterie?.cancel();
    if (!mounted || _c.status == AnimationStatus.reverse) return;
    _c.reverse().whenComplete(() {
      if (mounted) widget.onFin();
    });
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contenu = Semantics(
      liveRegion: true,
      label: '${widget.annonce.titre} : ${widget.annonce.texte}',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: _sortir,
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < 0) _sortir();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            // Elle passe au-dessus du contenu : ici le verre est depoli, pour
            // que le message reste lisible quoi qu il y ait dessous. Le flou ne
            // couvre que la banniere, et seulement le temps qu elle est la.
            child: BackdropFilter(
              filter: ImageFilter.compose(outer: ImageFilter.blur(sigmaX: 18, sigmaY: 18), inner: const ColorFilter.matrix(_saturation)),
              child: Verre(
                rayon: 24,
                surFond: false,
                ombre: false,
                child: ColoredBox(
                  color: Couleurs.surface.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                    child: Row(
                      children: [
                        // L icone de l application, comme sur une notification d iOS.
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Couleurs.hsl(229, 45, 93)]),
                            boxShadow: [
                              BoxShadow(color: Couleurs.hsl(229, 30, 40, 0.16), spreadRadius: 0.5),
                              BoxShadow(color: Couleurs.hsl(229, 40, 25, 0.35), offset: const Offset(0, 5), blurRadius: 12, spreadRadius: -6),
                            ],
                          ),
                          child: const LogoUsw(taille: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.annonce.titre,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Couleurs.texte),
                                    ),
                                  ),
                                  Text('maintenant', style: TextStyle(fontSize: 12, color: Couleurs.discret)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(widget.annonce.texte, style: TextStyle(fontSize: 14, height: 1.35, color: Couleurs.texte.withValues(alpha: 0.72))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Elle descend du haut en grandissant un peu : transform et opacite.
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(0, -1.4 * (1 - _t.value)),
        child: Transform.scale(scale: 0.92 + 0.08 * _t.value, child: child),
      ),
      child: FadeTransition(opacity: _c, child: contenu),
    );
  }
}

/// Saturation x 1,8 (le saturate(1.8) de SafeVault).
const _saturation = <double>[
  1.6038, -0.5724, -0.0314, 0, 0, //
  -0.1962, 1.2276, -0.0314, 0, 0, //
  -0.1962, -0.5724, 1.7686, 0, 0, //
  0, 0, 0, 1, 0, //
];
