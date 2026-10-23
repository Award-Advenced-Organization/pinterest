// E18 Mon profil, E19 Collection, E20 Createur : la tete du profil (avatar,
// nom, pseudo, bio, ville), puis ses publications en mosaique plate facon
// Pinterest. Mon profil a aussi ses reels et ses enregistrements (les
// collections). Le lot 5 branchera GET /api/v1/membres/{pseudo} et
// /collections.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../donnees/demo.dart';
import '../donnees/session.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/avatar.dart';
import '../widgets/feuille.dart';
import '../widgets/feuilles.dart';
import '../widgets/icone.dart';
import '../widgets/mosaique.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';

String _nombre(int n) => n < 1000 ? '$n' : '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')}';

/// La tete d un profil.
class _Tete extends StatelessWidget {
  const _Tete({required this.nom, required this.pseudo, required this.bio, required this.ville, this.abonnes, this.abonnements});

  final String nom;
  final String pseudo;
  final String bio;
  final String ville;
  final int? abonnes;
  final int? abonnements;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Avatar(nom: nom, taille: 104),
      const SizedBox(height: 14),
      Semantics(
        header: true,
        child: Text(
          nom,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: Couleurs.texte),
        ),
      ),
      const SizedBox(height: 2),
      Text('@$pseudo', style: TextStyle(fontSize: 14.5, color: Couleurs.discret)),
      if (bio.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: Couleurs.texte),
        ),
      ],
      const SizedBox(height: 8),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icone('lieu', taille: 16),
          const SizedBox(width: 4),
          Text(
            ville,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Couleurs.discret),
          ),
        ],
      ),
      if (abonnes != null) ...[
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _nombre(abonnes!),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' abonnés'),
              if (abonnements != null) ...[
                const TextSpan(text: '  ·  '),
                TextSpan(
                  text: _nombre(abonnements!),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' abonnements'),
              ],
            ],
          ),
          style: TextStyle(fontSize: 14, color: Couleurs.texte),
        ),
      ],
    ],
  );
}

/// Les onglets d un profil : le texte actif, souligne d un trait qui glisse.
class _Onglets extends StatelessWidget {
  const _Onglets({required this.noms, required this.actif, required this.onChange});

  final List<String> noms;
  final int actif;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < noms.length; i++) ...[
        if (i > 0) const SizedBox(width: 24),
        GestureDetector(
          onTap: () => onChange(i),
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            selected: i == actif,
            button: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: Durees.interface,
                    style: TextStyle(
                      fontFamily: famillePolice,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: i == actif ? Couleurs.texte : Couleurs.discret,
                    ),
                    child: Text(noms[i]),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Courbes.ressort,
                    height: 3,
                    width: i == actif ? 34 : 0,
                    decoration: BoxDecoration(color: Couleurs.texte, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

/// Le haut d une page de profil : des boutons de verre, a plat sur le fond.
class _Haut extends StatelessWidget {
  const _Haut({required this.gauche, required this.droite});

  final Widget gauche;
  final List<Widget> droite;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      gauche,
      const Spacer(),
      for (var i = 0; i < droite.length; i++) ...[if (i > 0) const SizedBox(width: 6), droite[i]],
    ],
  );
}

void _publication(BuildContext context, RefPublication r) => context.push('/accueil/lieu/${r.$1}/photo/${r.$2}');

/// E18 : mon profil.
class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});

  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  int _onglet = 0;

  @override
  Widget build(BuildContext context) {
    final s = Session.instance;
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    final nom = s.nomAffiche.isEmpty ? 'Akouavi K.' : s.nomAffiche;
    final pseudo = s.nomUtilisateur.isEmpty ? 'akouavi.k' : s.nomUtilisateur;
    final refs = switch (_onglet) {
      0 => mesPublications,
      1 => mesPublications.where((r) => publicationDe(r).reel).toList(),
      _ => const <RefPublication>[],
    };
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, haut + 8, 0, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: marge),
            child: _Haut(
              gauche: RondVerre(icone: 'partager', semantique: 'Partager le profil', onTap: () => bulle(context, 'Le lien de votre profil est copié.')),
              droite: [
                RondVerre(icone: 'telecharger', semantique: 'Mes envois', onTap: () => context.push('/creer/envois')),
                RondVerre(icone: 'reglages', semantique: 'Réglages', onTap: () => context.push('/profil/reglages')),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(marge, 6, marge, 18),
            child: _Tete(
              nom: nom,
              pseudo: pseudo,
              bio: 'Photos du golfe de Guinée, de Ouidah à Grand-Popo.',
              ville: '${s.ville}, ${s.pays}',
              abonnes: 1284,
              abonnements: 312,
            ),
          ),
          _Onglets(noms: const ['Publications', 'Reels', 'Enregistrés'], actif: _onglet, onChange: (i) => setState(() => _onglet = i)),
          const SizedBox(height: 12),
          if (_onglet == 2)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: marge),
              child: const _Collections(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: MosaiquePublications(
                publications: [for (final r in refs) publicationDe(r)],
                titre: (i) => lieuDe(refs[i].$1).nom,
                onTap: (i) => _publication(context, refs[i]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Les collections : une grande photo et deux petites, comme les tableaux de Pinterest.
class _Collections extends StatelessWidget {
  const _Collections();

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 16,
    crossAxisSpacing: 10,
    childAspectRatio: 0.92,
    children: [
      for (var i = 0; i < collectionsDemo.length; i++)
        Appuyable(
          semantique: collectionsDemo[i].nom,
          onTap: () => context.push('/profil/collection/$i'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: CouvertureCollection(collectionsDemo[i])),
              const SizedBox(height: 8),
              Text(collectionsDemo[i].nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  if (collectionsDemo[i].secrete) ...[Icone('cadenas', taille: 14, couleur: Couleurs.discret), const SizedBox(width: 3)],
                  Text('${collectionsDemo[i].nombre} publications', style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}

/// E19 : une collection.
class EcranCollection extends StatelessWidget {
  const EcranCollection({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final c = collectionsDemo[index.clamp(0, collectionsDemo.length - 1)];
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, haut + 8, 0, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: marge),
            child: _Haut(
              gauche: RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              droite: [
                RondVerre(icone: 'partager', semantique: 'Partager la collection', onTap: () => bulle(context, 'Le lien de la collection est copié.')),
                RondVerre(
                  icone: 'plus-points',
                  semantique: "Plus d'options",
                  onTap: () => montrerFeuille<void>(
                    context,
                    titre: c.nom,
                    contenu: (f) => Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LigneFeuille(icone: 'crayon', texte: 'Renommer', onTap: () => Navigator.pop(f)),
                          LigneFeuille(
                            icone: c.secrete ? 'oeil' : 'cadenas',
                            texte: c.secrete ? 'Rendre publique' : 'Rendre secrète',
                            onTap: () => Navigator.pop(f),
                          ),
                          LigneFeuille(icone: 'poubelle', texte: 'Supprimer la collection', danger: true, onTap: () => Navigator.pop(f)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              c.nom,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: Couleurs.texte),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (c.secrete) ...[Icone('cadenas', taille: 15, couleur: Couleurs.discret), const SizedBox(width: 4)],
              Text('${c.secrete ? 'Secrète · ' : ''}${c.nombre} publications', style: TextStyle(fontSize: 14, color: Couleurs.discret)),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: MosaiquePublications(publications: [for (final r in c.refs) publicationDe(r)], onTap: (i) => _publication(context, c.refs[i])),
          ),
        ],
      ),
    );
  }
}

/// E20 : le profil d un createur.
class EcranCreateur extends StatefulWidget {
  const EcranCreateur({super.key, required this.pseudo});

  final String pseudo;

  @override
  State<EcranCreateur> createState() => _EcranCreateurState();
}

class _EcranCreateurState extends State<EcranCreateur> {
  bool _abonne = false;
  int _onglet = 0;

  void _options(Createur c) => montrerFeuille<void>(
    context,
    titre: c.nom,
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LigneFeuille(icone: 'partager', texte: 'Partager le profil', onTap: () => Navigator.pop(f)),
          LigneFeuille(
            icone: 'lien',
            texte: 'Copier le lien',
            onTap: () {
              Navigator.pop(f);
              bulle(context, 'Le lien du profil est copié.');
            },
          ),
          LigneFeuille(
            icone: 'bloque',
            texte: 'Bloquer ${c.nom}',
            danger: true,
            onTap: () {
              Navigator.pop(f);
              bulle(context, '${c.nom} est bloqué : vous ne verrez plus ses publications.');
            },
          ),
          LigneFeuille(
            icone: 'drapeau',
            texte: 'Signaler le profil',
            danger: true,
            onTap: () {
              Navigator.pop(f);
              feuilleSignaler(context, quoi: 'profil');
            },
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = createurDe(widget.pseudo);
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    final refs = _onglet == 0 ? c.refs : c.refs.where((r) => publicationDe(r).reel).toList();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, haut + 8, 0, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: marge),
            child: _Haut(
              gauche: RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              droite: [
                RondVerre(icone: 'partager', semantique: 'Partager le profil', onTap: () => bulle(context, 'Le lien du profil est copié.')),
                RondVerre(icone: 'plus-points', semantique: "Plus d'options", onTap: () => _options(c)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(marge, 6, marge, 14),
            child: _Tete(nom: c.nom, pseudo: c.pseudo, bio: c.bio, ville: c.ville, abonnes: c.abonnes + (_abonne ? 1 : 0)),
          ),
          Center(
            child: BoutonVerre(texte: _abonne ? 'Abonné' : "S'abonner", plein: !_abonne, large: false, onTap: () => setState(() => _abonne = !_abonne)),
          ),
          const SizedBox(height: 18),
          _Onglets(noms: const ['Publications', 'Reels'], actif: _onglet, onChange: (i) => setState(() => _onglet = i)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: MosaiquePublications(
              publications: [for (final r in refs) publicationDe(r)],
              titre: (i) => lieuDe(refs[i].$1).nom,
              onTap: (i) => _publication(context, refs[i]),
            ),
          ),
        ],
      ),
    );
  }
}
