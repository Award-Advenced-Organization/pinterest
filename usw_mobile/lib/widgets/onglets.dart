import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ecrans/creer.dart';

import '../theme/jetons.dart';
import 'icone.dart';
import 'lentille.dart';
import 'verre.dart';

/// La coquille des quatre onglets : la page de l onglet, et par-dessus la
/// barre de verre qui flotte en bas (Accueil, Reels, Creer, Carte, Profil).
class Coquille extends StatelessWidget {
  const Coquille({super.key, required this.navigation});

  final StatefulNavigationShell navigation;

  static const _onglets = [('Accueil', 'accueil'), ('Reels', 'reels'), ('Carte', 'carte'), ('Profil', 'profil')];

  @override
  Widget build(BuildContext context) {
    final bas = MediaQuery.paddingOf(context).bottom;
    final largeur = MediaQuery.sizeOf(context).width;
    final marge = Mesures.margeDe(largeur);
    final courant = navigation.currentIndex;
    // Les reels sont sombres : la barre y prend un verre fume.
    final sombre = courant == 1;

    Widget onglet(int i) {
      final (nom, icone) = _onglets[i];
      final actif = i == courant;
      return Expanded(
        child: Appuyable(
          semantique: nom,
          // L icone gonfle sous le doigt et revient en rebondissant.
          verre: true,
          gonflement: 0.14,
          onTap: () => navigation.goBranch(i, initialLocation: i == courant),
          child: SizedBox(
            height: Mesures.hautOnglets,
            child: Center(
              child: AnimatedSwitcher(
                duration: Durees.interface,
                child: Icone(
                  actif ? '$icone-plein' : icone,
                  key: ValueKey(actif),
                  taille: 26,
                  // Au repos, l encre attenuee (jamais le gris bleute du texte discret) :
                  // la meme famille que l icone choisie, de jour comme de nuit.
                  couleur: sombre
                      ? Colors.white.withValues(alpha: actif ? 1 : 0.75)
                      : Couleurs.texte.withValues(alpha: actif ? 1 : (Couleurs.sombre ? 0.62 : 0.55)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: navigation,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(marge, 0, marge, bas + 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // L envoi en cours flotte juste au-dessus des onglets (E16).
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: const Padding(padding: EdgeInsets.only(bottom: 10), child: PastilleEnvoi()),
            ),
            Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                // Le verre liquide facon iOS : avec la lentille (depoli leger et
                // image courbee au bord), le voile peut etre bien plus clair.
                child: ValueListenableBuilder<bool>(
                  valueListenable: lentilleDisponible,
                  builder: (context, lentille, barre) => Lentille(rayon: Mesures.hautOnglets / 2, child: barre!),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Mesures.hautOnglets / 2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: sombre
                            ? [const Color(0x40000000), const Color(0x59000000)]
                            : lentilleDisponible.value
                            ? [Couleurs.surface.withValues(alpha: 0.5), Couleurs.surface.withValues(alpha: 0.42)]
                            : [Couleurs.surface.withValues(alpha: 0.9), Couleurs.surface.withValues(alpha: 0.86)],
                      ),
                    ),
                    child: Verre(
                      // La barre flotte sur les photos : son voile givre tient lieu de fond.
                      surFond: false,
                      // Pas d ombre portee : a travers le voile, elle ferait une bande grise.
                      ombre: false,
                      rayon: Mesures.hautOnglets / 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Semantics(
                          container: true,
                          label: 'Navigation principale',
                          // Hauteur fixe : sans elle, le Center du bouton Creer prendrait
                          // tout l ecran et la barre, invisible, capterait chaque toucher.
                          child: SizedBox(
                            height: Mesures.hautOnglets,
                            child: LayoutBuilder(
                              builder: (context, contraintes) {
                                // Cinq places egales ; Creer est au milieu (la 3e).
                                final place = contraintes.maxWidth / 5;
                                final rang = courant < 2 ? courant : courant + 1;
                                return Stack(
                                  children: [
                                    // La bulle de l onglet actif, comme celle de « Notes » dans le
                                    // Bloc-notes : un verre plus clair autour de l icone, qui glisse
                                    // d un onglet a l autre. Jamais sous Creer.
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 520),
                                      curve: Courbes.ressort,
                                      left: rang * place + 3,
                                      top: 6,
                                      width: place - 6,
                                      height: Mesures.hautOnglets - 12,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          // La nuit, une bulle nettement plus claire que la barre.
                                          color: sombre || Couleurs.sombre
                                              ? Colors.white.withValues(alpha: sombre ? 0.2 : 0.17)
                                              : Couleurs.texte.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular((Mesures.hautOnglets - 12) / 2),
                                        ),
                                        child: Verre(rayon: (Mesures.hautOnglets - 12) / 2, surFond: false, ombre: false, child: const SizedBox.expand()),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        onglet(0),
                                        onglet(1),
                                        Expanded(
                                          child: Center(
                                            child: Appuyable(
                                              semantique: 'Créer',
                                              verre: true,
                                              rayonVerre: 26,
                                              onTap: () => ouvrirCreer(context),
                                              child: const Verre(
                                                teinte: TeinteVerre.ocean,
                                                rayon: 26,
                                                child: SizedBox(
                                                  width: 52,
                                                  height: 52,
                                                  child: Center(child: Icone('plus', taille: 26, couleur: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onglet(2),
                                        onglet(3),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
