// La lentille du verre liquide, facon iOS : derriere le verre, l image est
// legerement depolie et se courbe pres du bord (shaders/verre_liquide.frag).
// Elle demande Impeller (ImageFilter.shader) ; sinon, et pendant que le
// programme se charge, le verre reste tel quel, sans lentille.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Vrai des que la lentille peut etre dessinee : le verre peut alors etre
/// plus transparent, le depoli garde le texte lisible.
final lentilleDisponible = ValueNotifier<bool>(false);

ui.FragmentProgram? _programme;

/// A appeler au demarrage : charge le programme une fois pour toute l app.
Future<void> chargerLentille() async {
  if (!ui.ImageFilter.isShaderFilterSupported) {
    debugPrint('LENTILLE non prise en charge (pas d Impeller) : verre sans distorsion');
    return;
  }
  try {
    _programme = await ui.FragmentProgram.fromAsset('shaders/verre_liquide.frag');
    lentilleDisponible.value = true;
    debugPrint('LENTILLE active');
  } catch (e) {
    debugPrint('LENTILLE indisponible : $e');
  }
}

class Lentille extends StatefulWidget {
  const Lentille({super.key, required this.rayon, required this.child, this.biseau = 16, this.force = 9, this.depoli = 1.4, this.flou = 0});

  final double rayon;
  final Widget child;

  /// La largeur du bord qui courbe l image, en points.
  final double biseau;

  /// Le deplacement de l image au ras du bord, en points.
  final double force;

  /// L ecart du depoli, en points : petit, pour qu il reste leger.
  final double depoli;

  /// Un flou de plus, avant la lentille (les feuilles : le texte de dessous
  /// ne doit pas se lire). Zero pour la barre et les boutons.
  final double flou;

  @override
  State<Lentille> createState() => _LentilleState();
}

class _LentilleState extends State<Lentille> {
  Rect? _place;

  // La place du verre a l ecran : le programme la compare a chaque point du fond.
  void _mesurer(Duration _) {
    if (!mounted) return;
    final boite = context.findRenderObject();
    if (boite is! RenderBox || !boite.hasSize) return;
    final place = boite.localToGlobal(Offset.zero) & boite.size;
    if (place != _place) setState(() => _place = place);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(_mesurer);
    final programme = _programme;
    final place = _place;
    final rayon = BorderRadius.circular(widget.rayon);
    if (programme == null || place == null) {
      // Sans lentille : le flou seul, s il est demande.
      if (widget.flou == 0) return widget.child;
      return ClipRRect(
        borderRadius: rayon,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: widget.flou, sigmaY: widget.flou),
          child: widget.child,
        ),
      );
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // Les deux premiers nombres (la taille du fond) sont donnes par le moteur.
    final shader = programme.fragmentShader()
      ..setFloat(2, place.left * dpr)
      ..setFloat(3, place.top * dpr)
      ..setFloat(4, place.width * dpr)
      ..setFloat(5, place.height * dpr)
      ..setFloat(6, widget.rayon * dpr)
      ..setFloat(7, widget.biseau * dpr)
      ..setFloat(8, widget.force * dpr)
      ..setFloat(9, widget.depoli * dpr);
    final lentille = ui.ImageFilter.shader(shader);
    return ClipRRect(
      borderRadius: rayon,
      child: BackdropFilter(
        // Le flou d abord, puis la lentille courbe l image floutee au bord.
        filter: widget.flou == 0
            ? lentille
            : ui.ImageFilter.compose(
                outer: lentille,
                inner: ui.ImageFilter.blur(sigmaX: widget.flou, sigmaY: widget.flou),
              ),
        child: widget.child,
      ),
    );
  }
}
