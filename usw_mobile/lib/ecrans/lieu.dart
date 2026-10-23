// E33 Lieu : la pile deliee. Toucher une pile de l accueil ouvre son lieu :
// toutes ses photos et ses reels en mosaique, et « Y aller » qui ouvre
// l itineraire dans Maps. Les cartes entrent facon « Coulisses » en suivant
// le defilement. Epure comme l accueil : pas d onglets Tout / Photos / Reels,
// un reel se reconnait a sa duree. Le lot 2 branchera
// GET /api/v1/lieux/{id} et /publications (pagination par curseur).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../donnees/demo.dart';
import '../theme/jetons.dart';
import '../widgets/feuilles.dart';
import '../widgets/mosaique.dart';
import '../widgets/icone.dart';
import '../widgets/mouvement.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';

class EcranLieu extends StatelessWidget {
  const EcranLieu({super.key, required this.lieu});

  final Lieu lieu;

  Future<void> _yAller(BuildContext context) async {
    final itineraire = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${lieu.latitude},${lieu.longitude}');
    final ouvert = await launchUrl(itineraire, mode: LaunchMode.externalApplication);
    if (!ouvert && context.mounted) bulle(context, "Maps n'a pas pu s'ouvrir.", icone: 'alerte');
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(largeur);
    final publications = publicationsDe(lieu);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Comme a l accueil : l en-tete se range quand on descend et revient
          // des qu on remonte ; les photos passent sous la barre d etat.
          SliverFloatingHeader(
            snapMode: FloatingHeaderSnapMode.scroll,
            animationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 450),
              curve: Courbes.interface,
              reverseDuration: const Duration(milliseconds: 450),
              reverseCurve: Courbes.interface,
            ),
            child: ColoredBox(
              color: Couleurs.fond,
              child: Padding(
                padding: EdgeInsets.fromLTRB(marge, haut + 6, marge, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/accueil')),
                        const Spacer(),
                        RondVerre(
                          icone: 'enregistrer',
                          semantique: 'Enregistrer le lieu',
                          onTap: () => bulle(context, 'Lieu enregistré dans vos collections.'),
                        ),
                        const SizedBox(width: 6),
                        RondVerre(
                          icone: 'partager',
                          semantique: 'Partager',
                          onTap: () => feuillePartager(
                            context,
                            titre: lieu.nom,
                            sousTitre: '${lieu.region} · ${lieu.nombre} photos',
                            photo: lieu.photos.first,
                            lien: 'usw.app/l/${lieu.id}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MotsQuiMontent(
                      lieu.nom,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.84, height: 1.1, color: Couleurs.texte),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Monte(
                            delai: const Duration(milliseconds: 400),
                            child: Row(
                              children: [
                                Icone('lieu', taille: 17, couleur: Couleurs.discret),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${lieu.region} · ${lieu.nombre} photos',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Couleurs.discret),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Monte(
                          delai: const Duration(milliseconds: 500),
                          child: BoutonVerre(
                            texte: 'Y aller',
                            plein: true,
                            large: false,
                            widgetIcone: const Icone('y-aller', taille: 20),
                            onTap: () => _yAller(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            // Comme Pinterest : la mosaique va presque au bord, 5 px partout.
            padding: EdgeInsets.fromLTRB(5, 0, 5, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverToBoxAdapter(
              child: MosaiquePublications(publications: publications, coulisses: true, onTap: (i) => context.push('/accueil/lieu/${lieu.id}/photo/$i')),
            ),
          ),
        ],
      ),
    );
  }
}
