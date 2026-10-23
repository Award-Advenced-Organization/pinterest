// E01 Bienvenue : trois ecrans qui avancent seuls (6 s). Des lieux en vraies
// photos ; chaque photo dit d ou elle vient ; Y aller. Creer un compte, se
// connecter, ou explorer sans compte.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/champ.dart';
import '../widgets/icone.dart';
import '../widgets/mouvement.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

class EcranBienvenue extends StatefulWidget {
  const EcranBienvenue({super.key});

  @override
  State<EcranBienvenue> createState() => _EcranBienvenueState();
}

class _EcranBienvenueState extends State<EcranBienvenue> with SingleTickerProviderStateMixin {
  static const _pages = [
    ('Des lieux, en vraies photos', "Chaque photo et chaque reel de USW a été pris sur place, par quelqu'un qui y était."),
    ("Chaque photo dit d'où elle vient", "Le téléphone, la date et le lieu de la prise sont lus dans le fichier, ou indiqués par l'auteur."),
    ("Envie d'y aller ?", "Touchez « Y aller » : Maps ouvre l'itinéraire jusqu'au lieu de la photo."),
  ];

  final _pager = PageController();
  late final AnimationController _avance = AnimationController(vsync: this, duration: const Duration(seconds: 6));
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _avance.addStatusListener((s) {
      if (s == AnimationStatus.completed && _page < _pages.length - 1) _aller(_page + 1);
    });
    _avance.forward();
  }

  @override
  void dispose() {
    _avance.dispose();
    _pager.dispose();
    super.dispose();
  }

  void _aller(int page) {
    _pager.animateToPage(page, duration: Durees.ecran, curve: Courbes.signature);
  }

  void _surPage(int page) {
    setState(() => _page = page);
    _avance.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final derniere = _page == _pages.length - 1;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.fromLTRB(marge, 8, marge, 20),
              child: Column(
                children: [
                  Progression(etape: _page, avance: derniere ? null : _avance),
                  SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedOpacity(
                        opacity: derniere ? 0 : 1,
                        duration: Durees.interface,
                        child: IgnorePointer(
                          ignoring: derniere,
                          child: Lien('Passer', discret: true, onTap: () => context.go('/entree')),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pager,
                      onPageChanged: _surPage,
                      itemCount: _pages.length,
                      itemBuilder: (context, i) => _Page(index: i, titre: _pages[i].$1, texte: _pages[i].$2),
                    ),
                  ),
                  const SizedBox(height: 26),
                  BoutonVerre(
                    texte: derniere ? 'Commencer' : 'Suivant',
                    plein: true,
                    iconeApres: 'fleche-droite',
                    onTap: () => derniere ? context.go('/entree') : _aller(_page + 1),
                  ),
                  AnimatedSize(
                    duration: Durees.interface,
                    curve: Courbes.interface,
                    child: derniere
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Lien('Explorer sans compte', discret: true, onTap: () => context.go('/accueil')),
                          )
                        : const SizedBox(width: double.infinity),
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

class _Page extends StatelessWidget {
  const _Page({required this.index, required this.titre, required this.texte});

  final int index;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Center(child: _visuel(context))),
      MotsQuiMontent(titre, style: Textes.titre),
      const SizedBox(height: 10),
      Monte(
        delai: const Duration(milliseconds: 350),
        child: Text(texte, style: Textes.discret),
      ),
    ],
  );

  Widget _visuel(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    return switch (index) {
      0 => SizedBox(
        width: (largeur * 0.64).clamp(0, 300),
        child: const AspectRatio(
          aspectRatio: 4 / 5,
          child: Pile(photos: ['p76', 'p110', 'p15', 'p108'], rayon: 26),
        ),
      ),
      1 => _DemoPhoto(
        photo: 'p124',
        largeur: (largeur * 0.72).clamp(0, 320),
        haut: const BadgeCapture(verifie: true),
        bas: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Puce(icone: 'telephone', texte: 'Tecno Camon 50 Pro', rang: 0),
            _Puce(icone: 'calendrier', texte: '12 août 2026, 17 h 40', rang: 1),
            _Puce(icone: 'lieu', texte: 'Lac Ahémé, Possotomé', rang: 2),
          ],
        ),
      ),
      _ => _DemoPhoto(
        photo: 'p77',
        largeur: (largeur * 0.72).clamp(0, 320),
        centre: const Monte(delai: Duration(milliseconds: 300), distance: 30, child: Icone('epingle', taille: 54)),
        bas: const Center(child: _BoutonYAller(texte: 'Y aller · 38 km')),
      ),
    };
  }
}

class _DemoPhoto extends StatelessWidget {
  const _DemoPhoto({required this.photo, required this.largeur, this.haut, this.bas, this.centre});

  final String photo;
  final double largeur;
  final Widget? haut;
  final Widget? bas;
  final Widget? centre;

  @override
  Widget build(BuildContext context) => Container(
    width: largeur,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      boxShadow: [BoxShadow(color: Couleurs.ombre, offset: const Offset(0, 20), blurRadius: 44, spreadRadius: -24)],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Photo(photo),
            if (haut != null) Positioned(top: 12, left: 12, child: haut!),
            if (centre != null) Center(child: centre),
            if (bas != null) Positioned(left: 12, right: 12, bottom: 12, child: bas!),
          ],
        ),
      ),
    ),
  );
}

class _Puce extends StatelessWidget {
  const _Puce({required this.icone, required this.texte, required this.rang});

  final String icone;
  final String texte;
  final int rang;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Monte(
      delai: Duration(milliseconds: 400 + 120 * rang),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(17)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icone(icone, taille: 17),
            const SizedBox(width: 7),
            Text(
              texte,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Couleurs.texte),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BoutonYAller extends StatelessWidget {
  const _BoutonYAller({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) => Verre(
    teinte: TeinteVerre.ocean,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icone('y-aller', taille: 19, couleur: Colors.white),
          const SizedBox(width: 9),
          Text(texte, style: Textes.bouton.copyWith(color: Colors.white)),
        ],
      ),
    ),
  );
}
