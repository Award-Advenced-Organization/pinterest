// Les feuilles (choisir un pays, commenter, partager, les options d une
// photo), a la maniere d iOS 26 : un panneau de verre liquide qui flotte en
// bas, a distance des bords. Le fond est depoli assez fort pour que le texte
// de dessous ne se lise pas, et le bord courbe l image comme une lentille.
import 'package:flutter/material.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import 'icone.dart';
import 'lentille.dart';
import 'verre.dart';

Future<T?> montrerFeuille<T>(BuildContext context, {required String titre, required WidgetBuilder contenu}) =>
    Navigator.of(context, rootNavigator: true).push<T>(_RouteFeuille<T>(titre: titre, contenu: contenu));

/// L ouverture facon iOS : la feuille nait en bas comme une pastille etroite,
/// s etire vers le haut et s elargit avec un ressort qui depasse un peu, puis
/// se pose. La fermeture la retracte vers le bas, plus vite.
class _RouteFeuille<T> extends PopupRoute<T> {
  _RouteFeuille({required this.titre, required this.contenu});

  final String titre;
  final WidgetBuilder contenu;

  @override
  Color? get barrierColor => Couleurs.hsl(229, 30, 10, 0.18);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Fermer';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 620);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 320);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => _Feuille(
    titre: titre,
    child: Builder(builder: contenu),
  );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return FadeTransition(opacity: animation, child: child);
    final forme = CurvedAnimation(parent: animation, curve: Courbes.ressort, reverseCurve: Curves.easeInCubic);
    final apparition = CurvedAnimation(parent: animation, curve: const Interval(0, 0.3), reverseCurve: const Interval(0.4, 1));
    return FadeTransition(
      opacity: apparition,
      child: AnimatedBuilder(
        animation: forme,
        builder: (context, enfant) {
          final v = forme.value;
          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.translationValues(0, (1 - v) * 90, 0)..scaleByDouble(0.62 + 0.38 * v, 0.35 + 0.65 * v, 1, 1),
            child: enfant,
          );
        },
        child: child,
      ),
    );
  }
}

class _Feuille extends StatefulWidget {
  const _Feuille({required this.titre, required this.child});

  final String titre;
  final Widget child;

  @override
  State<_Feuille> createState() => _FeuilleState();
}

class _FeuilleState extends State<_Feuille> {
  static const _rayon = 32.0;

  // Tiree vers le bas : elle suit le doigt, et se ferme si on la lache assez bas.
  double _tiree = 0;

  void _lacher(DragEndDetails d) {
    if (_tiree > 110 || (d.primaryVelocity ?? 0) > 700) {
      Navigator.of(context).pop();
    } else {
      setState(() => _tiree = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taille = MediaQuery.sizeOf(context);
    final bas = MediaQuery.paddingOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragUpdate: (d) => setState(() => _tiree = (_tiree + d.delta.dy).clamp(0.0, double.infinity)),
        onVerticalDragEnd: _lacher,
        child: AnimatedContainer(
          duration: _tiree == 0 ? const Duration(milliseconds: 380) : Duration.zero,
          curve: Courbes.ressort,
          transform: Matrix4.translationValues(0, _tiree, 0),
          padding: EdgeInsets.fromLTRB(8, 0, 8, bas + 8),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520, maxHeight: taille.height * 0.72),
              child: Lentille(
                rayon: _rayon,
                flou: 22,
                biseau: 22,
                force: 14,
                // Assez de blanc pour que rien ne se lise a travers. Une Material :
                // les lignes a toucher (ListTile) y dessinent leur appui.
                child: Material(
                  color: Couleurs.surface.withValues(alpha: 0.62),
                  child: Verre(
                    rayon: _rayon,
                    surFond: false,
                    ombre: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // La poignee : on peut tirer la feuille vers le bas.
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 12),
                            width: 38,
                            height: 5,
                            decoration: BoxDecoration(color: Couleurs.trait, borderRadius: BorderRadius.circular(3)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: Semantics(header: true, child: Text(widget.titre, style: Textes.sousTitre)),
                        ),
                        Flexible(child: widget.child),
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
  }
}

/// Une ligne d options dans une feuille : une icone a l encre, un texte ; en
/// rouge pour ce qui retire ou signale (bloquer, signaler, supprimer).
class LigneFeuille extends StatelessWidget {
  const LigneFeuille({super.key, required this.icone, required this.texte, required this.onTap, this.danger = false});

  final String icone;
  final String texte;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final couleur = danger ? Couleurs.erreur : Couleurs.texte;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icone(icone, taille: 23, couleur: couleur),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texte,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: couleur),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le dialogue de confirmation (E37) : une plaque de verre au centre, qui
/// nait petite et se gonfle avec un ressort, comme une alerte iOS. Vrai si
/// l action est confirmee.
Future<bool> confirmer(
  BuildContext context, {
  required String titre,
  required String texte,
  required String action,
  required String icone,
  bool danger = true,
}) async {
  final oui = await showGeneralDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Annuler',
    barrierColor: Couleurs.hsl(229, 30, 10, 0.22),
    transitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (context, _, _) => _Dialogue(titre: titre, texte: texte, action: action, icone: icone, danger: danger),
    transitionBuilder: (context, animation, _, enfant) {
      final forme = CurvedAnimation(parent: animation, curve: Courbes.ressort, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.35)),
        child: ScaleTransition(scale: Tween(begin: 0.82, end: 1.0).animate(forme), child: enfant),
      );
    },
  );
  return oui ?? false;
}

class _Dialogue extends StatelessWidget {
  const _Dialogue({required this.titre, required this.texte, required this.action, required this.icone, required this.danger});

  final String titre;
  final String texte;
  final String action;
  final String icone;
  final bool danger;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: titre,
          child: Lentille(
            rayon: 28,
            flou: 22,
            biseau: 20,
            force: 12,
            child: Material(
              color: Couleurs.surface.withValues(alpha: 0.66),
              child: Verre(
                rayon: 28,
                surFond: false,
                ombre: false,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: danger ? Couleurs.erreur.withValues(alpha: 0.12) : Couleurs.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icone(icone, taille: 24, couleur: danger ? Couleurs.erreur : Couleurs.texte),
                    ),
                    const SizedBox(height: 12),
                    Text(titre, textAlign: TextAlign.center, style: Textes.sousTitre),
                    const SizedBox(height: 6),
                    Text(texte, textAlign: TextAlign.center, style: Textes.discret.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: BoutonVerre(texte: 'Annuler', onTap: () => Navigator.pop(context, false)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BoutonVerre(texte: action, teinte: danger ? TeinteVerre.rouge : TeinteVerre.ocean, onTap: () => Navigator.pop(context, true)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
