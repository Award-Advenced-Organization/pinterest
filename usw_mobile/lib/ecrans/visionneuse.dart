// La photo en plein ecran, dans le format ou elle a ete prise (portrait
// 9:16, paysage, carre...) : rien n est recadre. On zoome a deux doigts,
// on la ferme d un glisser vers le bas, et l original se telecharge d ici.
// Elle passe au-dessus de la barre d onglets (navigateur racine).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';

void ouvrirVisionneuse(BuildContext context, String photo) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: Durees.ecran,
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, _) => EcranVisionneuse(photo: photo, animation: animation),
    ),
  );
}

class EcranVisionneuse extends StatefulWidget {
  const EcranVisionneuse({super.key, required this.photo, required this.animation});

  final String photo;
  final Animation<double> animation;

  @override
  State<EcranVisionneuse> createState() => _EcranVisionneuseState();
}

class _EcranVisionneuseState extends State<EcranVisionneuse> {
  final _zoom = TransformationController();
  late final Animation<double> _entree = CurvedAnimation(parent: widget.animation, curve: Courbes.signature, reverseCurve: Courbes.interface);
  double _glisse = 0;
  bool _zoome = false;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final zoome = _zoom.value.getMaxScaleOnAxis() > 1.01;
      if (zoome != _zoome) setState(() => _zoome = zoome);
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _fermer() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final hauteur = MediaQuery.sizeOf(context).height;
    // En glissant vers le bas, le fond s eclaircit et la photo suit le doigt.
    final reste = (1 - _glisse.abs() / (hauteur * 0.5)).clamp(0.0, 1.0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: barreSombre,
      child: AnimatedBuilder(
        animation: _entree,
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black.withValues(alpha: _entree.value * reste)),
            child!,
          ],
        ),
        // La photo arrive en grandissant un peu (transform et opacite seulement).
        child: FadeTransition(
          opacity: _entree,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(_entree),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onVerticalDragUpdate: _zoome ? null : (d) => setState(() => _glisse += d.delta.dy),
                    onVerticalDragEnd: _zoome
                        ? null
                        : (d) {
                            if (_glisse.abs() > 120 || d.velocity.pixelsPerSecond.dy.abs() > 900) {
                              _fermer();
                            } else {
                              setState(() => _glisse = 0);
                            }
                          },
                    child: Transform.translate(
                      offset: Offset(0, _glisse),
                      child: InteractiveViewer(
                        transformationController: _zoom,
                        minScale: 1,
                        maxScale: 5,
                        panEnabled: _zoome,
                        child: Center(
                          child: Image.asset(
                            'assets/photos/${widget.photo}.webp',
                            fit: BoxFit.contain,
                            semanticLabel: 'Photo en plein écran',
                            errorBuilder: (context, _, _) => ColoredBox(color: Couleurs.photoVide, child: const SizedBox.expand()),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: haut + 8,
                    left: 12,
                    right: 12,
                    child: Opacity(
                      opacity: reste,
                      child: Row(
                        children: [
                          RondVerre(icone: 'fermer', semantique: 'Fermer', surPhoto: true, encre: Colors.white, onTap: _fermer),
                          const Spacer(),
                          Appuyable(
                            semantique: "Télécharger l'original",
                            onTap: () => bulle(context, "L'original sera téléchargé en entier.", icone: 'telecharger'),
                            child: Verre(
                              rayon: 22,
                              surFond: false,
                              ombre: false,
                              child: SizedBox(
                                height: 44,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icone('telecharger', taille: 20, couleur: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Original', style: Textes.bouton.copyWith(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
