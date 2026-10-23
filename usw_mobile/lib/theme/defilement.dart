// Le defilement de USW, doux facon Lenis. Sur un ecran tactile, le doigt
// garde la page sous lui (rien ne doit trainer) ; la douceur est dans
// l elan : apres un lancer, la page glisse longtemps et ralentit en
// douceur, au lieu de s arreter sec comme le defilement d Android. En haut et
// en bas, elle rebondit legerement au lieu de s etirer.
import 'package:flutter/material.dart';

class DefilementUsw extends MaterialScrollBehavior {
  const DefilementUsw();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const PhysiqueDouce(parent: AlwaysScrollableScrollPhysics());

  // Pas d etirement ni de lueur au bord : le rebond suffit.
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

/// Le rebond d iOS : un lancer glisse longtemps et garde sa vitesse quand
/// on relance (l elan s ajoute), et les petits gestes glissent aussi.
class PhysiqueDouce extends BouncingScrollPhysics {
  const PhysiqueDouce({super.parent}) : super(decelerationRate: ScrollDecelerationRate.normal);

  @override
  PhysiqueDouce applyTo(ScrollPhysics? ancestor) => PhysiqueDouce(parent: buildParent(ancestor));

  // Un lancer part des 40 px/s : les petits gestes glissent aussi.
  @override
  double get minFlingVelocity => 40;
}
