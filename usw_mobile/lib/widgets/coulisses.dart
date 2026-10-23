// L entree « Coulisses » de la page d un lieu (MOUVEMENT.md, section 4) :
// une carte qui entre par le bas arrive de son cote (colonne de gauche par
// la gauche, de droite par la droite, 5 % de l ecran), se redresse de 3°,
// grandit de 80 a 100 % et son image dezoome (1,3 -> 1), en expo sortie.
// Le mouvement suit le doigt : il avance et recule avec le defilement.
//
// Performance : ni reconstruction ni mise en page pendant le defilement.
// Deux petits objets de rendu lisent leur place dans la fenetre au moment de
// peindre et posent une transformation, rien d autre.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'mouvement.dart';

/// La carte entiere : decalage, rotation et echelle.
class Coulisses extends SingleChildRenderObjectWidget {
  const Coulisses({super.key, required this.cote, super.child});

  /// -1 colonne de gauche, 0 milieu, 1 colonne de droite.
  final int cote;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenduCoulisses(cote, Scrollable.maybeOf(context)?.position, !animationsReduites(context), image: false);

  @override
  void updateRenderObject(BuildContext context, RenduCoulisses renderObject) => renderObject
    ..cote = cote
    ..position = Scrollable.maybeOf(context)?.position
    ..actif = !animationsReduites(context);
}

/// L image de la carte, qui dezoome dans son cadre arrondi.
class CoulissesImage extends SingleChildRenderObjectWidget {
  const CoulissesImage({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => RenduCoulisses(0, Scrollable.maybeOf(context)?.position, !animationsReduites(context), image: true);

  @override
  void updateRenderObject(BuildContext context, RenduCoulisses renderObject) => renderObject
    ..position = Scrollable.maybeOf(context)?.position
    ..actif = !animationsReduites(context);
}

/// Le rendu des deux : il lit sa place dans la fenetre au moment de peindre.
class RenduCoulisses extends RenderProxyBox {
  RenduCoulisses(this._cote, this._position, this._actif, {required this.image});

  final bool image;

  int _cote;
  set cote(int v) {
    if (v == _cote) return;
    _cote = v;
    markNeedsPaint();
  }

  bool _actif;
  set actif(bool v) {
    if (v == _actif) return;
    _actif = v;
    markNeedsPaint();
  }

  ScrollPosition? _position;
  set position(ScrollPosition? v) {
    if (v == _position) return;
    if (attached) _position?.removeListener(markNeedsPaint);
    _position = v;
    if (attached) _position?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _position?.removeListener(markNeedsPaint);
    super.detach();
  }

  RenderBox? get _fenetre {
    final fenetre = RenderAbstractViewport.maybeOf(this);
    return fenetre is RenderBox ? fenetre as RenderBox : null;
  }

  // Ce qui est deja entre (0 a 1), en expo sortie.
  double _entree() {
    final fenetre = _fenetre;
    if (fenetre == null || !hasSize || size.height == 0) return 1;
    final haut = getTransformTo(fenetre).getTranslation().y;
    final p = ((fenetre.size.height - haut) / size.height).clamp(0.0, 1.0);
    return p >= 1 ? 1 : 1 - math.pow(2, -10 * p).toDouble();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final e = _actif ? _entree() : 1.0;
    if (e >= 1) {
      layer = null;
      context.paintChild(child!, offset);
      return;
    }
    final centre = size.center(Offset.zero);
    final Matrix4 m;
    if (image) {
      final zoom = 1.3 - 0.3 * e;
      m = Matrix4.identity()
        ..translateByDouble(centre.dx, centre.dy, 0, 1)
        ..scaleByDouble(zoom, zoom, 1, 1)
        ..translateByDouble(-centre.dx, -centre.dy, 0, 1);
    } else {
      final reste = 1 - e;
      final largeurEcran = _fenetre?.size.width ?? size.width;
      final echelle = 0.8 + 0.2 * e;
      m = Matrix4.identity()
        ..translateByDouble(centre.dx + _cote * 0.05 * largeurEcran * reste, centre.dy, 0, 1)
        ..rotateZ(_cote * 3 * math.pi / 180 * reste)
        ..scaleByDouble(echelle, echelle, 1, 1)
        ..translateByDouble(-centre.dx, -centre.dy, 0, 1);
    }
    layer = context.pushTransform(needsCompositing, offset, m, super.paint, oldLayer: layer as TransformLayer?);
  }
}
