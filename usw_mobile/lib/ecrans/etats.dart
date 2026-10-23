// E37 Les etats : pas de connexion, contenu introuvable, publication refusee.
// Un ecran calme : une icone dans sa tuile, un titre, une phrase, une ou deux
// actions. Tout tient sans defiler.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';

class EcranEtat extends StatelessWidget {
  const EcranEtat({super.key, required this.etat, this.titre});

  /// hors-ligne, introuvable ou refusee.
  final String etat;

  /// Le nom de la publication refusee.
  final String? titre;

  @override
  Widget build(BuildContext context) {
    final VoidCallback retour = context.canPop() ? () => context.pop() : () => context.go('/accueil');
    final (icone, titreEtat, texte, danger) = switch (etat) {
      'hors-ligne' => (
        'hors-ligne',
        'Pas de connexion',
        'Les photos que vous avez déjà vues restent là. Tout ce que vous publiez partira dès que le réseau revient.',
        false,
      ),
      'refusee' => (
        'drapeau',
        'Publication refusée',
        '« ${titre ?? 'Rues de Porto-Novo'} » contient des signes d’image générée par IA. Si c’est une vraie photo, demandez une vérification par l’équipe : la réponse arrive sous 48 h.',
        true,
      ),
      _ => ('image-barre', 'Cette photo n’est plus là', 'Son auteur l’a retirée, ou le lien est incomplet.', false),
    };
    final actions = switch (etat) {
      'hors-ligne' => [
        BoutonVerre(texte: 'Voir les photos enregistrées', plein: true, onTap: () => context.go('/profil')),
        const SizedBox(height: 10),
        BoutonVerre(texte: 'Réessayer', onTap: retour),
      ],
      'refusee' => [
        BoutonVerre(
          texte: 'Demander une vérification',
          plein: true,
          onTap: () {
            bulle(context, 'Demande envoyée. Réponse sous 48 h.', icone: 'bouclier');
            retour();
          },
        ),
        const SizedBox(height: 10),
        BoutonVerre(texte: 'Lire les règles', onTap: () => context.push('/document/regles')),
      ],
      _ => [BoutonVerre(texte: 'Retour à l’accueil', plein: true, onTap: () => context.go('/accueil'))],
    };
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(marge, 8, marge, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RondVerre(icone: 'retour', semantique: 'Retour', onTap: retour),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: danger ? Couleurs.erreur.withValues(alpha: 0.12) : Couleurs.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icone(icone, taille: 36, couleur: danger ? Couleurs.erreur : Couleurs.texte),
                        ),
                        const SizedBox(height: 18),
                        Titre(titreEtat, style: Textes.titre.copyWith(fontSize: 26), centre: true),
                        const SizedBox(height: 10),
                        Text(texte, textAlign: TextAlign.center, style: Textes.discret),
                        const SizedBox(height: 26),
                        ...actions,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
