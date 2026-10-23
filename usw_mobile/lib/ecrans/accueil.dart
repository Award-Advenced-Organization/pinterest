// E03 Accueil : une mosaique de piles de photos par lieu, qui tournent ;
// toucher une pile ouvre le lieu (E33). Epure a la demande de l utilisateur :
// ni flux ni filtres en haut, les filtres sont dans la recherche (E31).
// Le lot 4 branchera GET /api/v1/flux/decouverte (pagination par curseur).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../donnees/demo.dart';
import '../theme/jetons.dart';
import '../widgets/icone.dart';
import '../widgets/mouvement.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(largeur);
    final colonnes = largeur >= 600 ? 3 : 2;
    // Bord a bord : les photos passent sous la barre d etat, comme la
    // mosaique de l entree. Seul l en-tete reserve sa place.
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // L en-tete se range quand on descend dans le flux et revient des
          // qu on remonte (0,45 s, courbe interface). Les filtres sont dans
          // la recherche : l accueil ne montre que les lieux.
          SliverFloatingHeader(
            snapMode: FloatingHeaderSnapMode.scroll,
            animationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 450),
              curve: Courbes.interface,
              reverseDuration: const Duration(milliseconds: 450),
              reverseCurve: Courbes.interface,
            ),
            // Pas de bloc plein : un simple degrade du fond vers le transparent,
            // sans flou. Quand l en-tete revient sur le flux, les photos
            // glissent dessous et s effacent en douceur sous le logo.
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Couleurs.fond.withValues(alpha: 0.94), Couleurs.fond.withValues(alpha: 0.78), Couleurs.fond.withValues(alpha: 0)],
                  stops: const [0, 0.55, 1],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(marge, haut + 6, marge, 22),
                child: Row(
                  children: [
                    const LogoUsw(taille: 30),
                    const SizedBox(width: 8),
                    const Text('USW', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.9)),
                    const Spacer(),
                    RondVerre(icone: 'loupe', semantique: 'Rechercher', surPhoto: true, onTap: () => context.push('/accueil/recherche')),
                    const SizedBox(width: 6),
                    RondVerre(icone: 'cloche', semantique: 'Notifications', point: true, surPhoto: true, onTap: () => context.push('/notifications')),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(marge, 0, marge, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverToBoxAdapter(
              child: _Mosaique(lieux: lieuxDemo, colonnes: colonnes),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mosaique extends StatelessWidget {
  const _Mosaique({required this.lieux, required this.colonnes});

  final List<Lieu> lieux;
  final int colonnes;

  @override
  Widget build(BuildContext context) {
    final hauteurs = List<double>.filled(colonnes, 0);
    final rangs = List.generate(colonnes, (_) => <(int, Lieu)>[]);
    for (var i = 0; i < lieux.length; i++) {
      var c = 0;
      for (var k = 1; k < colonnes; k++) {
        if (hauteurs[k] < hauteurs[c]) c = k;
      }
      rangs[c].add((i, lieux[i]));
      hauteurs[c] += 1 / lieux[i].ratio + 0.25;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < colonnes; c++) ...[
          if (c > 0) const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                for (final (i, lieu) in rangs[c])
                  Monte(
                    delai: Duration(milliseconds: 250 + 70 * i),
                    child: _PileLieu(lieu: lieu, rang: i),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PileLieu extends StatelessWidget {
  const _PileLieu({required this.lieu, required this.rang});

  final Lieu lieu;
  final int rang;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Appuyable(
      semantique: '${lieu.nom}, ${lieu.nombre} photos',
      onTap: () => context.push('/accueil/lieu/${lieu.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: lieu.ratio,
            child: Pile(
              photos: lieu.photos,
              decalage: Duration(milliseconds: 500 * rang),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lieu.nom, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icone('camera', taille: 14, couleur: Couleurs.discret),
                        const SizedBox(width: 3),
                        Text('${lieu.nombre} photos', style: TextStyle(fontSize: 12, color: Couleurs.discret)),
                      ],
                    ),
                  ],
                ),
              ),
              Icone('plus-points', taille: 20, couleur: Couleurs.discret),
            ],
          ),
        ],
      ),
    ),
  );
}
