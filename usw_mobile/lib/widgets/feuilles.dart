// Les feuilles d une photo ou d un reel (E07 commentaires, E08 telecharger,
// E09 enregistrer, E10 partager, E06 reactions, E22 signaler), communes a la page Photo et
// aux reels. Toutes en verre liquide (feuille.dart). Les lots 4 et 5
// brancheront les commentaires, les collections et les telechargements.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../donnees/demo.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import 'avatar.dart';
import 'champ.dart';
import 'feuille.dart';
import 'icone.dart';
import 'page.dart';
import 'photo.dart';
import 'verre.dart';

TextStyle get _sousTitre => TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte);

// ------------------------------------------------------------ E07 commentaires

Future<void> feuilleCommentaires(BuildContext context, {required int nombre, required String auteur}) => montrerFeuille<void>(
  context,
  titre: '$nombre commentaires',
  contenu: (_) => _Commentaires(auteur: auteur),
);

class _Avis {
  const _Avis(this.nom, this.texte, this.quand, this.aime, {this.auteur = false, this.epingle = false});
  final String nom;
  final String texte;
  final String quand;
  final int aime;
  final bool auteur;
  final bool epingle;
}

class _Commentaires extends StatefulWidget {
  const _Commentaires({required this.auteur});

  final String auteur;

  @override
  State<_Commentaires> createState() => _CommentairesState();
}

class _CommentairesState extends State<_Commentaires> {
  final _saisie = TextEditingController();
  late final _avis = <_Avis>[
    _Avis(widget.auteur, 'Le sentier part derrière le campement, 20 min de marche. Prenez des sandales qui tiennent.', '1 j', 412, auteur: true, epingle: true),
    const _Avis('Akouavi K.', 'Le passage à 0:12 😍 On y va en janvier avec @mawuli.s.', '6 h', 38),
    const _Avis('Edem A.', "C'est accessible en saison des pluies ?", '3 h', 4),
    const _Avis('Fifamè H.', "J'y étais en mars, l'eau était encore là. Magnifique.", '2 h', 12),
  ];
  final _aimes = <int>{};

  @override
  void dispose() {
    _saisie.dispose();
    super.dispose();
  }

  void _envoyer() {
    final t = _saisie.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _avis.insert(1, _Avis('Vous', t, 'maintenant', 0));
      _saisie.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
          itemCount: _avis.length,
          itemBuilder: (context, i) {
            final a = _avis[i];
            final aime = _aimes.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(nom: a.nom, taille: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.epingle)
                          Text(
                            "Épinglé par l'auteur",
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Couleurs.discret),
                          ),
                        Row(
                          children: [
                            Text(a.nom, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            if (a.auteur) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: Couleurs.texte.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Auteur', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        TexteMentions(a.texte),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(a.quand, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () => _saisie.text = '@${a.nom.toLowerCase().replaceAll(' ', '.').replaceAll('..', '.')} ',
                              child: Text(
                                'Répondre',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Couleurs.discret),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => aime ? _aimes.remove(i) : _aimes.add(i)),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Column(
                        children: [
                          Icone(aime ? 'coeur-plein' : 'coeur', taille: 18, couleur: aime ? Couleurs.erreur : Couleurs.discret),
                          Text('${a.aime + (aime ? 1 : 0)}', style: TextStyle(fontSize: 11.5, color: Couleurs.discret)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(14, 4, 14, 12 + MediaQuery.viewInsetsOf(context).bottom),
        child: ChampVerre(
          icone: 'commentaire',
          indice: 'Ajouter un commentaire, @mentionner…',
          controleur: _saisie,
          action: TextInputAction.send,
          onSubmitted: (_) => _envoyer(),
          suffixe: GestureDetector(
            onTap: _envoyer,
            child: Semantics(
              button: true,
              label: 'Envoyer',
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icone('envoyer', taille: 22, couleur: Couleurs.texte),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// Un texte ou les @mentions et les moments (0:12) ressortent.
class TexteMentions extends StatelessWidget {
  const TexteMentions(this.texte, {super.key, this.couleur});

  final String texte;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final morceaux = <TextSpan>[];
    texte.splitMapJoin(
      RegExp(r'@[\w.]+|\b\d:\d\d\b'),
      onMatch: (m) {
        morceaux.add(
          TextSpan(
            text: m[0],
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
        return '';
      },
      onNonMatch: (t) {
        morceaux.add(TextSpan(text: t));
        return '';
      },
    );
    return Text.rich(
      TextSpan(children: morceaux),
      style: TextStyle(fontSize: 14.5, height: 1.4, color: couleur ?? Couleurs.texte),
    );
  }
}

// ------------------------------------------------------------ E10 partager

Future<void> feuillePartager(
  BuildContext context, {
  required String titre,
  required String sousTitre,
  required String photo,
  required String lien,
  VoidCallback? telecharger,
  VoidCallback? enregistrer,
  VoidCallback? signaler,
}) => montrerFeuille<void>(
  context,
  titre: 'Partager',
  contenu: (f) =>
      _Partager(titre: titre, sousTitre: sousTitre, photo: photo, lien: lien, telecharger: telecharger, enregistrer: enregistrer, signaler: signaler),
);

/// Les membres a qui l on envoie le plus souvent, puis les autres (recherche).
const _membresRecents = ['Mawuli S.', 'Fifamè H.', 'Edem A.', 'Séna A.', 'Koffi P.'];
const _autresMembres = ['Aminata D.', 'Yao B.', 'Senan Voyage', 'Lagune 229', 'Rachida T.', 'Gildas H.', 'Nadège K.'];

class _Partager extends StatefulWidget {
  const _Partager({required this.titre, required this.sousTitre, required this.photo, required this.lien, this.telecharger, this.enregistrer, this.signaler});

  final String titre;
  final String sousTitre;
  final String photo;
  final String lien;
  final VoidCallback? telecharger;
  final VoidCallback? enregistrer;
  final VoidCallback? signaler;

  @override
  State<_Partager> createState() => _PartagerState();
}

class _PartagerState extends State<_Partager> {
  final _choisis = <String>[];
  final _recherche = TextEditingController();
  final _message = TextEditingController();
  bool _cherche = false;

  @override
  void dispose() {
    _recherche.dispose();
    _message.dispose();
    super.dispose();
  }

  void _fermer(String message) {
    Navigator.pop(context);
    bulle(context, message);
  }

  void _basculer(String n) {
    HapticFeedback.selectionClick();
    setState(() => _choisis.contains(n) ? _choisis.remove(n) : _choisis.add(n));
  }

  void _envoyer() {
    final a = _choisis.length == 1 ? _choisis.first : '${_choisis.length} membres';
    _fermer('Envoyé à $a.');
  }

  Widget _appli(String icone, String nom, VoidCallback onTap, {bool rouge = false}) => SizedBox(
    width: 72,
    child: Appuyable(
      semantique: nom,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: rouge ? Couleurs.erreur.withValues(alpha: 0.1) : Couleurs.surface.withValues(alpha: 0.8), shape: BoxShape.circle),
            child: Icone(icone, taille: 24, couleur: rouge ? Couleurs.erreur : (icone == 'whatsapp' ? null : Couleurs.texte)),
          ),
          const SizedBox(height: 6),
          Text(
            nom,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 12, height: 1.2, color: rouge ? Couleurs.erreur : Couleurs.texte),
          ),
        ],
      ),
    ),
  );

  // Un membre : son avatar, coche au ressort quand il est choisi.
  Widget _membre(String n) {
    final choisi = _choisis.contains(n);
    return SizedBox(
      width: 70,
      child: Semantics(
        selected: choisi,
        child: Appuyable(
          semantique: 'Envoyer à $n',
          onTap: () => _basculer(n),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Avatar(nom: n, taille: 54),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: AnimatedScale(
                      scale: choisi ? 1 : 0,
                      duration: const Duration(milliseconds: 380),
                      curve: Courbes.ressort,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Couleurs.texte,
                          shape: BoxShape.circle,
                          border: Border.all(color: Couleurs.surface, width: 2),
                        ),
                        child: Icone('coche', taille: 12, couleur: Couleurs.surEncre),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                n.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: choisi ? FontWeight.w700 : FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saisie = _recherche.text.trim().toLowerCase();
    final membres = _cherche
        ? [
            for (final n in [..._membresRecents, ..._autresMembres])
              if (saisie.isEmpty || n.toLowerCase().contains(saisie)) n,
          ]
        : _membresRecents;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            children: [
              Row(
                children: [
                  SizedBox(width: 52, height: 68, child: PhotoArrondie(widget.photo, rayon: 10)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titre, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                        Text(widget.sousTitre, style: TextStyle(fontSize: 13, color: Couleurs.discret)),
                        Text(
                          widget.lien,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Couleurs.texte),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Envoyer à un membre', style: _sousTitre),
              const SizedBox(height: 10),
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Courbes.interface,
                alignment: Alignment.topCenter,
                child: _cherche
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChampVerre(
                          icone: 'loupe',
                          indice: 'Rechercher un membre',
                          controleur: _recherche,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              SizedBox(
                height: 82,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (!_cherche)
                      SizedBox(
                        width: 70,
                        child: Appuyable(
                          semantique: 'Rechercher un membre',
                          onTap: () => setState(() => _cherche = true),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.8), shape: BoxShape.circle),
                                child: Icone('loupe', taille: 22, couleur: Couleurs.texte),
                              ),
                              const SizedBox(height: 6),
                              const Text('Rechercher', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    for (final n in membres) _membre(n),
                    if (membres.isEmpty) Center(child: Text('Aucun membre « ${_recherche.text.trim()} ».', style: Textes.petit)),
                  ],
                ),
              ),
              if (_choisis.isEmpty) ...[
                const SizedBox(height: 14),
                Text('Partager avec', style: _sousTitre),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _appli('whatsapp', 'WhatsApp', () => _fermer('WhatsApp va s’ouvrir avec le lien.')),
                      _appli('lien', 'Copier le lien', () {
                        Clipboard.setData(ClipboardData(text: 'https://${widget.lien}'));
                        _fermer('Le lien est copié.');
                      }),
                      _appli('envoyer', 'Message', () => setState(() => _cherche = true)),
                      _appli('enveloppe', 'E-mail', () => _fermer('Votre messagerie va s’ouvrir.')),
                      _appli('plus-points', 'Autres', () => _fermer('Le partage du téléphone va s’ouvrir.')),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Couleurs.filet),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.telecharger != null)
                        _appli('telecharger', 'Télécharger', () {
                          Navigator.pop(context);
                          widget.telecharger!();
                        }),
                      if (widget.enregistrer != null)
                        _appli('enregistrer', 'Enregistrer', () {
                          Navigator.pop(context);
                          widget.enregistrer!();
                        }),
                      _appli('oeil-barre', 'Pas intéressé', () => _fermer('Vous en verrez moins comme ça.')),
                      if (widget.signaler != null)
                        _appli('drapeau', 'Signaler', rouge: true, () {
                          Navigator.pop(context);
                          widget.signaler!();
                        }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Des qu un membre est choisi : un mot, puis Envoyer, toujours en bas.
        AnimatedSize(
          duration: const Duration(milliseconds: 360),
          curve: Courbes.interface,
          alignment: Alignment.topCenter,
          child: _choisis.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChampVerre(icone: 'commentaire', indice: 'Ajouter un message (facultatif)', controleur: _message),
                      const SizedBox(height: 10),
                      BoutonVerre(
                        texte: _choisis.length == 1 ? 'Envoyer à ${_choisis.first.split(' ').first}' : 'Envoyer à ${_choisis.length} membres',
                        icone: 'envoyer',
                        plein: true,
                        onTap: _envoyer,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ E09 enregistrer

Future<void> feuilleEnregistrer(BuildContext context) => montrerFeuille<void>(context, titre: 'Enregistrer dans', contenu: (f) => const _Enregistrer());

class _Enregistrer extends StatefulWidget {
  const _Enregistrer();

  @override
  State<_Enregistrer> createState() => _EnregistrerState();
}

class _EnregistrerState extends State<_Enregistrer> {
  int? _choisie;

  // « Créer une collection » : la feuille devient un petit formulaire.
  bool _nouvelle = false;
  bool _secrete = false;
  final _nom = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  void _creer() {
    final nom = _nom.text.trim();
    collectionsDemo.add(Collection(nom: nom, refs: const [], nombre: 1, secrete: _secrete));
    Navigator.pop(context);
    bulle(context, 'Collection « $nom » créée, la publication y est enregistrée.');
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Durees.interface,
    child: _nouvelle ? _formulaire() : _liste(),
  );

  Widget _formulaire() => Padding(
    key: const ValueKey('nouvelle'),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChampVerre(
          icone: 'collection',
          indice: 'Nom de la collection',
          controleur: _nom,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        MergeSemantics(
          child: Row(
            children: [
              Icone('cadenas', taille: 20, couleur: Couleurs.texte),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Secrète', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: Couleurs.texte)),
                    Text('Vous seul la voyez.', style: TextStyle(fontSize: 13, color: Couleurs.discret)),
                  ],
                ),
              ),
              Switch(value: _secrete, activeTrackColor: Couleurs.ocean, onChanged: (v) => setState(() => _secrete = v)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BoutonVerre(texte: 'Créer et enregistrer', plein: true, onTap: _nom.text.trim().isEmpty ? null : _creer),
      ],
    ),
  );

  Widget _liste() => ListView(
    key: const ValueKey('liste'),
    shrinkWrap: true,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
    children: [
      for (var i = 0; i < collectionsDemo.length; i++)
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => _choisie = i);
            Future<void>.delayed(const Duration(milliseconds: 380), () {
              if (!mounted) return;
              Navigator.pop(context);
              bulle(context, 'Enregistré dans « ${collectionsDemo[i].nom} ».');
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(width: 64, height: 64, child: CouvertureCollection(collectionsDemo[i], rayon: 12, ecart: 1.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collectionsDemo[i].nom, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          if (collectionsDemo[i].secrete) ...[Icone('cadenas', taille: 13, couleur: Couleurs.discret), const SizedBox(width: 3)],
                          Text(
                            '${collectionsDemo[i].nombre + (_choisie == i ? 1 : 0)} publications${collectionsDemo[i].secrete ? ' · secrète' : ''}',
                            style: TextStyle(fontSize: 12.5, color: Couleurs.discret),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: _choisie == i ? 1 : 0,
                  duration: const Duration(milliseconds: 360),
                  curve: Courbes.ressort,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Couleurs.texte, shape: BoxShape.circle),
                    child: Icone('coche', taille: 16, couleur: Couleurs.surEncre),
                  ),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 6),
      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _nouvelle = true),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)),
                child: Icone('plus', taille: 26, couleur: Couleurs.texte),
              ),
              const SizedBox(width: 12),
              const Text('Créer une collection', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ],
  );
}

// ------------------------------------------------------------ E08 telecharger

Future<void> feuilleTelecharger(
  BuildContext context, {
  required String photo,
  required String titre,
  required String appareil,
  required bool reel,
  int dureeSecondes = 0,
}) => montrerFeuille<void>(
  context,
  titre: reel ? 'Télécharger le reel' : 'Télécharger la photo',
  contenu: (_) => _Telecharger(photo: photo, titre: titre, appareil: appareil, reel: reel, duree: dureeSecondes),
);

class _Telecharger extends StatefulWidget {
  const _Telecharger({required this.photo, required this.titre, required this.appareil, required this.reel, required this.duree});

  final String photo;
  final String titre;
  final String appareil;
  final bool reel;
  final int duree;

  @override
  State<_Telecharger> createState() => _TelechargerState();
}

class _TelechargerState extends State<_Telecharger> {
  bool _original = true;
  bool _attendreWifi = true;

  @override
  Widget build(BuildContext context) {
    final poidsOriginal = widget.reel ? 38 : 9;
    final poidsReduit = widget.reel ? 7 : 1;
    final poids = _original ? poidsOriginal : poidsReduit;
    Widget choix(bool original, String titre, String texte) => InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _original = original),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Durees.interface,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _original == original ? Couleurs.texte : Couleurs.discret, width: _original == original ? 7 : 1.6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(texte, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        Row(
          children: [
            SizedBox(width: 48, height: widget.reel ? 80 : 60, child: PhotoArrondie(widget.photo, rayon: 10)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.titre, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                  Text(
                    widget.reel
                        ? 'Vidéo MP4 · 1 080 × 1 920 · ${widget.duree ~/ 60}:${(widget.duree % 60).toString().padLeft(2, '0')}'
                        : 'Photo JPEG · taille d’origine',
                    style: TextStyle(fontSize: 13, color: Couleurs.discret),
                  ),
                  Text('${widget.appareil}${widget.reel ? ' · son d’origine compris' : ''}', style: TextStyle(fontSize: 13, color: Couleurs.discret)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Plaque(
          rayon: 18,
          child: Column(
            children: [
              choix(true, 'Original · $poidsOriginal Mo', 'Tel que pris, avec ses informations de capture'),
              Divider(height: 1, indent: 46, color: Couleurs.filet),
              choix(false, 'Taille écran · $poidsReduit Mo', '${widget.reel ? '720 p' : '1 080 px'}, léger, sans les informations du fichier'),
            ],
          ),
        ),
        if (_original && poids > 20) ...[
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icone('alerte', taille: 20, couleur: Couleurs.texte),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Vous êtes en 3G. ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: 'Environ 9 min pour l’original. ${_attendreWifi ? 'Il partira tout seul dès que vous serez en Wi-Fi.' : ''}'),
                    ],
                  ),
                  style: TextStyle(fontSize: 13.5, height: 1.4, color: Couleurs.texte),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(
                child: Text('Attendre le Wi-Fi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Switch(value: _attendreWifi, onChanged: (v) => setState(() => _attendreWifi = v)),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Pour un usage personnel.${widget.reel ? ' La musique de la bibliothèque n’est pas incluse.' : ''}',
          style: TextStyle(fontSize: 12.5, color: Couleurs.discret),
        ),
        const SizedBox(height: 14),
        BoutonVerre(
          texte: _original && poids > 20 && _attendreWifi ? 'Télécharger en Wi-Fi · $poids Mo' : 'Télécharger · $poids Mo',
          icone: 'telecharger',
          plein: true,
          onTap: () {
            Navigator.pop(context);
            bulle(context, _original && poids > 20 && _attendreWifi ? 'Le téléchargement partira en Wi-Fi.' : 'Téléchargement lancé.');
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ E06 reactions

const reactionsUsw = ['❤️', '🤩', '🧳', '🙏'];

Future<void> feuilleReactions(BuildContext context, {required String total}) =>
    montrerFeuille<void>(context, titre: '$total réactions', contenu: (_) => const _Reactions());

class _Reactions extends StatefulWidget {
  const _Reactions();

  @override
  State<_Reactions> createState() => _ReactionsState();
}

class _ReactionsState extends State<_Reactions> {
  static const _membres = [
    ('Mawuli S.', 'mawuli.s · vous suit', '🧳', false),
    ('Fifamè H.', 'fifame.h', '🤩', true),
    ('Edem A.', 'edem.a', '❤️', false),
    ('Séna Adjovi', 'sena.adjovi', '🙏', false),
    ('Koffi B.', 'koffi.photo', '❤️', true),
  ];
  String? _filtre;
  late final _suivis = {for (final m in _membres) m.$1: m.$4};

  @override
  Widget build(BuildContext context) {
    final liste = _membres.where((m) => _filtre == null || m.$3 == _filtre).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final (e, n) in [(null, 'Toutes 12,4 k'), ('❤️', '❤️ 8,9 k'), ('🤩', '🤩 2,1 k'), ('🧳', '🧳 1,2 k'), ('🙏', '🙏 214')]) ...[
                Pastille(texte: n, retenue: _filtre == e, onTap: () => setState(() => _filtre = e)),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              for (final (nom, pseudo, emoji, _) in liste)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Avatar(nom: nom, taille: 46),
                          Positioned(right: -4, bottom: -4, child: Text(emoji, style: const TextStyle(fontSize: 18))),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            Text(pseudo, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                          ],
                        ),
                      ),
                      BoutonVerre(
                        texte: _suivis[nom]! ? 'Abonné' : "S'abonner",
                        plein: !_suivis[nom]!,
                        large: false,
                        onTap: () => setState(() => _suivis[nom] = !_suivis[nom]!),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Le texte d une feuille de confirmation simple.
Widget texteFeuille(String texte) => Padding(
  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
  child: Text(texte, style: Textes.discret),
);

// ------------------------------------------------------------ E22 signaler

/// Un motif a cocher : un intitule, parfois une precision dessous.
typedef Motif = (String, String?);

const motifsSignalement = <Motif>[
  ('Image générée ou retouchée par IA', null),
  ('Pas pris à cet endroit', 'Le lieu indiqué est faux'),
  ("Ce n'est pas son auteur", "Le contenu appartient à quelqu'un d'autre"),
  ('Contenu choquant ou violent', null),
  ('Harcèlement ou propos haineux', null),
  ('Spam ou arnaque', null),
];

/// `quoi` : photo, reel ou profil.
Future<void> feuilleSignaler(BuildContext context, {required String quoi}) => montrerFeuille<void>(
  context,
  titre: switch (quoi) {
    'reel' => 'Signaler ce reel',
    'profil' => 'Signaler ce profil',
    _ => 'Signaler cette photo',
  },
  contenu: (f) => const _Signaler(),
);

class _Signaler extends StatefulWidget {
  const _Signaler();

  @override
  State<_Signaler> createState() => _SignalerState();
}

class _SignalerState extends State<_Signaler> {
  int? _motif;
  final _precision = TextEditingController();

  @override
  void dispose() {
    _precision.dispose();
    super.dispose();
  }

  // Le bouton reste en bas de la feuille ; les motifs defilent au besoin.
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Votre signalement reste anonyme. L'équipe le vérifie sous 24 h et vous tient au courant.", style: Textes.petit),
              const SizedBox(height: 12),
              ListeMotifs(motifs: motifsSignalement, choisi: _motif, onChoisi: (i) => setState(() => _motif = i)),
              const SizedBox(height: 12),
              ChampVerre(icone: 'crayon', indice: 'Ajoutez une précision (facultatif)', controleur: _precision),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/document/regles');
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2), minimumSize: const Size(0, 36)),
                  child: Text.rich(
                    TextSpan(
                      text: 'Voir les ',
                      style: TextStyle(fontSize: 13.5, color: Couleurs.discret),
                      children: [
                        TextSpan(
                          text: 'règles communautaires',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Couleurs.texte, decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: BoutonVerre(
          texte: 'Envoyer le signalement',
          teinte: TeinteVerre.rouge,
          onTap: _motif == null
              ? null
              : () {
                  Navigator.pop(context);
                  bulle(context, "Merci. L'équipe vérifie sous 24 h.", icone: 'drapeau');
                },
        ),
      ),
    ],
  );
}

/// Les motifs a cocher (signaler, refuser en moderation) : une plaque de
/// verre, un rond qui se remplit d encre avec un ressort.
class ListeMotifs extends StatelessWidget {
  const ListeMotifs({super.key, required this.motifs, required this.choisi, required this.onChoisi});

  final List<Motif> motifs;
  final int? choisi;
  final ValueChanged<int> onChoisi;

  @override
  Widget build(BuildContext context) => Plaque(
    rayon: 20,
    child: Column(
      children: [
        for (var i = 0; i < motifs.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, indent: 48, color: Couleurs.filet),
          Semantics(
            selected: choisi == i,
            inMutuallyExclusiveGroup: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onChoisi(i),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Courbes.interface,
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: choisi == i ? Couleurs.texte : Couleurs.trait, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedScale(
                        scale: choisi == i ? 1 : 0,
                        duration: const Duration(milliseconds: 360),
                        curve: Courbes.ressort,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(color: Couleurs.texte, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(motifs[i].$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          if (motifs[i].$2 != null) Text(motifs[i].$2!, style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// La couverture d une collection : sa premiere photo en grand, deux autres a
/// cote. Une collection neuve, encore vide, montre son icone.
class CouvertureCollection extends StatelessWidget {
  const CouvertureCollection(this.collection, {super.key, this.rayon = 16, this.ecart = 2});

  final Collection collection;
  final double rayon;
  final double ecart;

  @override
  Widget build(BuildContext context) {
    final refs = collection.refs;
    if (refs.isEmpty) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Couleurs.photoVide, borderRadius: BorderRadius.circular(rayon)),
        child: Icone('collection', taille: 26, couleur: Couleurs.discret),
      );
    }
    Widget photo(int n) => Photo(publicationDe(refs[n % refs.length]).photo);
    return ClipRRect(
      borderRadius: BorderRadius.circular(rayon),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: photo(0)),
          SizedBox(width: ecart),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: photo(1)),
                SizedBox(height: ecart),
                Expanded(child: photo(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
