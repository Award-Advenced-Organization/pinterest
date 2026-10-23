// E36 Completer le profil, a la premiere connexion (e-mail ou Google), en
// trois etapes : photo et noms ; pays, ville et position ; types de lieux aimes.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../donnees/demo.dart';
import '../../donnees/session.dart';
import '../../theme/jetons.dart';
import '../../theme/theme.dart';
import '../../widgets/champ.dart';
import '../../widgets/feuille.dart';
import '../../widgets/icone.dart';
import '../../widgets/mouvement.dart';
import '../../widgets/page.dart';
import '../../widgets/photo.dart';
import '../../widgets/verre.dart';

const _pays = {
  'Bénin': ['Cotonou', 'Porto-Novo', 'Abomey-Calavi', 'Parakou', 'Ouidah', 'Bohicon', 'Natitingou', 'Djougou', 'Grand-Popo', 'Lokossa'],
  'Togo': ['Lomé', 'Kara', 'Kpalimé', 'Sokodé'],
  'Nigeria': ['Lagos', 'Abuja', 'Ibadan', 'Kano'],
  'Ghana': ['Accra', 'Kumasi', 'Cape Coast'],
  'Burkina Faso': ['Ouagadougou', 'Bobo-Dioulasso'],
  'Niger': ['Niamey', 'Zinder'],
  "Côte d'Ivoire": ['Abidjan', 'Yamoussoukro', 'Bouaké'],
  'Sénégal': ['Dakar', 'Saint-Louis', 'Ziguinchor'],
  'France': ['Paris', 'Lyon', 'Marseille'],
};

class EcranCompleter extends StatelessWidget {
  const EcranCompleter({super.key, required this.etape});

  final int etape;

  @override
  Widget build(BuildContext context) => switch (etape) {
    1 => const _Etape1(),
    2 => const _Etape2(),
    _ => const _Etape3(),
  };
}

/// L en-tete commun : les trois traits, retour, « Etape n sur 3 ».
class _Entete extends StatelessWidget {
  const _Entete({required this.etape, this.passer});

  final int etape;
  final VoidCallback? passer;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Progression(etape: etape - 1),
      const SizedBox(height: 14),
      Row(
        children: [
          RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/entree')),
          const SizedBox(width: 12),
          Text('Étape $etape sur 3', style: Textes.petit.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (passer != null) Lien('Passer', discret: true, onTap: passer),
        ],
      ),
    ],
  );
}

class _Cadre extends StatelessWidget {
  const _Cadre({required this.enfants, this.bas});

  final List<Widget> enfants;
  final Widget? bas;

  @override
  Widget build(BuildContext context) {
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: ListView(padding: EdgeInsets.fromLTRB(marge, 8, marge, 16), children: enfants),
                ),
                if (bas != null) Padding(padding: EdgeInsets.fromLTRB(marge, 0, marge, 16), child: bas),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Etape1 extends StatefulWidget {
  const _Etape1();

  @override
  State<_Etape1> createState() => _Etape1State();
}

class _Etape1State extends State<_Etape1> {
  final s = Session.instance;
  late final _nom = TextEditingController(text: s.nomAffiche);
  late final _utilisateur = TextEditingController(text: s.nomUtilisateur);
  final _bio = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    _utilisateur.dispose();
    _bio.dispose();
    super.dispose();
  }

  bool get _utilisateurValide => RegExp(r'^[a-z0-9._]{3,30}$').hasMatch(_utilisateur.text);

  @override
  Widget build(BuildContext context) => _Cadre(
    enfants: [
      const _Entete(etape: 1),
      const SizedBox(height: 18),
      Titre('Votre profil', style: Textes.titre),
      const SizedBox(height: 8),
      Monte(
        delai: const Duration(milliseconds: 300),
        child: Text('Ce que les autres verront à côté de vos photos.', style: Textes.discret),
      ),
      const SizedBox(height: 22),
      Center(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Couleurs.ocean, shape: BoxShape.circle),
                  child: Text(
                    s.initiales,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Couleurs.ombre, blurRadius: 10, offset: const Offset(0, 4), spreadRadius: -4)],
                    ),
                    child: Icone('camera', taille: 18, couleur: Couleurs.texte),
                  ),
                ),
              ],
            ),
            Lien('Ajouter une photo', onTap: () => bulle(context, 'La galerie arrivera avec la création (lot 3).', icone: 'image')),
          ],
        ),
      ),
      const SizedBox(height: 10),
      ChampVerre(
        libelle: 'Nom affiché',
        icone: 'profil',
        controleur: _nom,
        onChanged: (_) => setState(() {}),
        aide: const Text('Repris de votre adresse : vous pouvez le changer.'),
      ),
      const SizedBox(height: 16),
      ChampVerre(
        libelle: "Nom d'utilisateur",
        icone: 'arobase',
        controleur: _utilisateur,
        onChanged: (_) => setState(() {}),
        suffixe: _utilisateurValide ? Icone('coche', taille: 20, couleur: Couleurs.succes) : null,
        erreur: _utilisateur.text.isEmpty || _utilisateurValide ? null : 'De 3 à 30 caractères : lettres minuscules, chiffres, point ou tiret bas.',
        aide: _utilisateurValide
            ? Row(
                children: [
                  Icone('coche', taille: 15, couleur: Couleurs.succes),
                  const SizedBox(width: 5),
                  const Text('Ce nom est libre'),
                ],
              )
            : null,
      ),
      const SizedBox(height: 16),
      ChampVerre(libelle: 'Bio', facultatif: true, icone: 'crayon', indice: 'Ce que vous aimez photographier, en une phrase', controleur: _bio, lignes: 3),
    ],
    bas: BoutonVerre(
      texte: 'Continuer',
      plein: true,
      onTap: _nom.text.trim().isNotEmpty && _utilisateurValide
          ? () {
              s
                ..nomAffiche = _nom.text.trim()
                ..nomUtilisateur = _utilisateur.text;
              context.push('/completer/2');
            }
          : null,
    ),
  );
}

class _Etape2 extends StatefulWidget {
  const _Etape2();

  @override
  State<_Etape2> createState() => _Etape2State();
}

class _Etape2State extends State<_Etape2> {
  final s = Session.instance;

  Future<void> _choisir(String titre, List<String> choix, String actuel, ValueChanged<String> poser) async {
    final retenu = await montrerFeuille<String>(
      context,
      titre: titre,
      contenu: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          for (final c in choix)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(c, style: TextStyle(fontSize: 16, fontWeight: c == actuel ? FontWeight.w700 : FontWeight.w400)),
              trailing: c == actuel ? Icone('coche', couleur: Couleurs.texte) : null,
              onTap: () => Navigator.pop(context, c),
            ),
        ],
      ),
    );
    if (retenu != null) setState(() => poser(retenu));
  }

  Widget _selecteur(String libelle, String icone, String valeur, VoidCallback onTap) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(libelle, style: Textes.libelle),
      const SizedBox(height: 8),
      Appuyable(
        onTap: onTap,
        semantique: '$libelle : $valeur',
        child: Verre(
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icone(icone, taille: 22, couleur: Couleurs.discret),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(valeur, style: TextStyle(fontSize: 16, color: Couleurs.texte)),
                  ),
                  Icone('chevron-bas', taille: 20, couleur: Couleurs.discret),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => _Cadre(
    enfants: [
      const _Entete(etape: 2),
      const SizedBox(height: 18),
      Titre("D'où êtes-vous ?", style: Textes.titre),
      const SizedBox(height: 8),
      Monte(
        delai: const Duration(milliseconds: 300),
        child: Text("Pour vous montrer d'abord les lieux près de chez vous.", style: Textes.discret),
      ),
      const SizedBox(height: 24),
      _selecteur(
        'Pays',
        'globe',
        s.pays,
        () => _choisir('Pays', _pays.keys.toList(), s.pays, (v) {
          s.pays = v;
          s.ville = _pays[v]!.first;
        }),
      ),
      const SizedBox(height: 16),
      _selecteur('Ville', 'lieu', s.ville, () => _choisir('Ville', _pays[s.pays]!, s.ville, (v) => s.ville = v)),
      const SizedBox(height: 18),
      Plaque(
        rayon: 18,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // A l encre, comme toutes les icones de l interface : pas de pastille bleue.
            Icone('cible', taille: 24, couleur: Couleurs.texte),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Utiliser ma position', style: Textes.libelle),
                  const SizedBox(height: 2),
                  Text('Pour vous montrer les lieux proches. Modifiable à tout moment dans les réglages.', style: Textes.petit),
                ],
              ),
            ),
            Switch(value: s.position, activeTrackColor: Couleurs.ocean, onChanged: (v) => setState(() => s.position = v)),
          ],
        ),
      ),
    ],
    bas: BoutonVerre(texte: 'Continuer', plein: true, onTap: () => context.push('/completer/3')),
  );
}

class _Etape3 extends StatefulWidget {
  const _Etape3();

  @override
  State<_Etape3> createState() => _Etape3State();
}

class _Etape3State extends State<_Etape3> {
  final s = Session.instance;

  void _terminer() {
    s.connecter();
    context.go('/accueil');
    bulle(context, 'Bienvenue sur USW, ${s.nomAffiche.split(' ').first} !');
  }

  @override
  Widget build(BuildContext context) {
    final n = s.interets.length;
    final colonnes = MediaQuery.sizeOf(context).width >= 600 ? 4 : 3;
    return _Cadre(
      enfants: [
        _Entete(etape: 3, passer: _terminer),
        const SizedBox(height: 18),
        Titre('Ce que vous aimez voir', style: Textes.titre),
        const SizedBox(height: 8),
        Monte(
          delai: const Duration(milliseconds: 300),
          child: Text('Choisissez au moins 3 types de lieux : votre fil commencera par eux.', style: Textes.discret),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: colonnes,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
          children: [
            for (var i = 0; i < typesDeLieux.length; i++)
              Monte(
                delai: Duration(milliseconds: 350 + 50 * i),
                child: _Interet(
                  nom: typesDeLieux[i].$1,
                  photo: typesDeLieux[i].$2,
                  choisi: s.interets.contains(typesDeLieux[i].$1),
                  onTap: () => setState(() {
                    final nom = typesDeLieux[i].$1;
                    if (!s.interets.remove(nom)) s.interets.add(nom);
                  }),
                ),
              ),
          ],
        ),
      ],
      bas: BoutonVerre(texte: n >= 3 ? 'Terminer · $n choisis' : 'Encore ${3 - n} à choisir', plein: true, onTap: n >= 3 ? _terminer : null),
    );
  }
}

class _Interet extends StatelessWidget {
  const _Interet({required this.nom, required this.photo, required this.choisi, required this.onTap});

  final String nom;
  final String photo;
  final bool choisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Appuyable(
    onTap: onTap,
    semantique: '$nom${choisi ? ', choisi' : ''}',
    child: AnimatedContainer(
      duration: Durees.interface,
      curve: Courbes.interface,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: choisi ? Couleurs.ocean : Colors.transparent, width: 2.5),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Photo(photo),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x99000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Text(
                nom,
                maxLines: 2,
                style: const TextStyle(fontSize: 13.5, height: 1.15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                scale: choisi ? 1 : 0,
                duration: Durees.relache,
                curve: Courbes.ressort,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Couleurs.ocean, shape: BoxShape.circle),
                  child: const Icone('coche', taille: 15, couleur: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
