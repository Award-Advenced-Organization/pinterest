import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import 'verre.dart';

// Le message apres une action : une banniere de verre en haut (banniere.dart).
export 'banniere.dart' show bulle;

/// Une page de formulaire : le bouton retour en haut, le contenu centre et
/// borne en largeur (tablette), qui defile au-dessus du clavier.
class PageFormulaire extends StatelessWidget {
  const PageFormulaire({super.key, required this.enfants, this.haut, this.pied, this.retour = true, this.centre = true, this.titre});

  final List<Widget> enfants;

  /// A droite du bouton retour (etape, Passer).
  final Widget? haut;
  final Widget? pied;
  final bool retour;

  /// Les pages d authentification centrent leur contenu.
  final bool centre;

  /// Un titre court au centre de la ligne du haut (« Nouvelle publication »).
  final String? titre;

  @override
  Widget build(BuildContext context) {
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, contraintes) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(marge, 8, marge, 24),
            // La hauteur minimale va au plus pres de la colonne : un Center
            // entre les deux l annulerait, et les Spacer n auraient plus de place.
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 480, minHeight: contraintes.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (retour) RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/entree')),
                          if (titre != null)
                            Expanded(
                              child: Text(
                                titre!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            )
                          else
                            const Spacer(),
                          ?haut,
                          if (titre != null && haut == null && retour) const SizedBox(width: 44),
                        ],
                      ),
                      if (centre) const Spacer(),
                      ...enfants,
                      // Le pied reste en bas de l ecran, contenu centre ou non.
                      if (centre || pied != null) const Spacer(),
                      if (pied != null) ...[const SizedBox(height: 28), pied!],
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
}

/// Un titre de page, immobile. Le titre qui monte mot a mot (MotsQuiMontent)
/// est reserve aux pages qui se levent (la bienvenue sous le rideau) et au
/// haut d un lieu : trop frequent, il perdrait son sens.
class Titre extends StatelessWidget {
  const Titre(this.texte, {super.key, required this.style, this.centre = false});

  final String texte;
  final TextStyle style;
  final bool centre;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(texte, style: style, textAlign: centre ? TextAlign.center : TextAlign.start),
  );
}

/// Un texte de page, discret, avec des passages en gras.
class TextePage extends StatelessWidget {
  const TextePage(this.morceaux, {super.key, this.centre = false});

  /// (texte, gras)
  final List<(String, bool)> morceaux;
  final bool centre;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        for (final (t, gras) in morceaux)
          TextSpan(
            text: t,
            style: gras ? TextStyle(color: Couleurs.texte, fontWeight: FontWeight.w600) : null,
          ),
      ],
    ),
    style: Textes.discret,
    textAlign: centre ? TextAlign.center : TextAlign.start,
  );
}

/// Une question suivie d un lien, en pied de page. Elle passe a la ligne si
/// le texte est agrandi.
class PiedLien extends StatelessWidget {
  const PiedLien({super.key, required this.question, required this.lien, required this.onTap});

  final String question;
  final String lien;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(question, style: Textes.petit.copyWith(fontSize: 14.5)),
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(lien, style: Textes.lien),
        ),
      ),
    ],
  );
}

/// Le separateur « ou » entre deux facons de continuer.
class SeparateurOu extends StatelessWidget {
  const SeparateurOu({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: Couleurs.voile, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('ou', style: Textes.petit),
      ),
      Expanded(child: Divider(color: Couleurs.voile, thickness: 1)),
    ],
  );
}

/// Les mentions legales sous les boutons d inscription.
class MentionsLegales extends StatelessWidget {
  const MentionsLegales({super.key});

  @override
  Widget build(BuildContext context) {
    final lien = TextStyle(color: Couleurs.ocean, fontWeight: FontWeight.w600);
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'En continuant, vous acceptez les '),
          TextSpan(text: "conditions générales d'utilisation", style: lien),
          const TextSpan(text: ' de USW et reconnaissez avoir lu la '),
          TextSpan(text: 'politique de confidentialité', style: lien),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: Textes.petit.copyWith(fontSize: 13.5),
    );
  }
}
