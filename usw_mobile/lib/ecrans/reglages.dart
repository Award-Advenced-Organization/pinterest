// E21 Reglages et Modifier le profil. Les reglages sont des groupes de
// verre : compte, donnees mobiles (pense pour la 3G), autorisations, aide.
// Le lot 5 branchera PATCH /api/v1/moi et les preferences.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../donnees/affichage.dart';
import '../donnees/session.dart';
import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/avatar.dart';
import '../widgets/champ.dart';
import '../widgets/feuille.dart';
import '../widgets/feuilles.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/verre.dart';

/// Les preferences de donnees mobiles, gardees le temps de la session.
class _Preferences {
  static bool photosReduites = true;
  static bool reelsWifi = true;
  static bool envoisWifi = false;
  static bool camera = true;
  static bool notifications = true;
  static bool pause = false;

  /// Ce qui envoie une notification ; « retiree » ne se coupe pas.
  static final notifs = <String, bool>{
    'jaime': true,
    'commentaires': true,
    'mentions': true,
    'abonnes': true,
    'verifiee': true,
    'envoi': true,
    'suivis': false,
  };
}

/// Les comptes bloques de la demonstration.
final _bloques = <(String, String)>[('Kodjo Spam', 'kodjo.promo'), ('Faux Voyages', 'voyages.pas.chers')];

class EcranReglages extends StatefulWidget {
  const EcranReglages({super.key});

  @override
  State<EcranReglages> createState() => _EcranReglagesState();
}

class _EcranReglagesState extends State<EcranReglages> {
  // Une autorisation : on la donne ou la retire ici ; le systeme garde le
  // dernier mot (le lot 5 ouvrira ses reglages si elle y est bloquee).
  // Le theme : celui du telephone par defaut, ou toujours clair, ou sombre.
  Future<void> _theme() => montrerFeuille<void>(
    context,
    titre: 'Thème',
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: StatefulBuilder(
        builder: (context, maj) => ListeMotifs(
          motifs: const [('Comme le téléphone', 'Clair le jour, sombre si le téléphone l’est'), ('Clair', null), ('Sombre', null)],
          choisi: Affichage.instance.mode.index,
          onChoisi: (i) {
            Affichage.instance.choisirTheme(ModeTheme.values[i]);
            maj(() {});
            Future<void>.delayed(const Duration(milliseconds: 320), () {
              if (f.mounted) Navigator.pop(f);
            });
          },
        ),
      ),
    ),
  );

  Future<void> _autorisation(String nom, bool actuelle, ValueChanged<bool> changer) => montrerFeuille<void>(
    context,
    titre: nom,
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LigneFeuille(
            icone: 'coche',
            texte: actuelle ? 'Autorisée' : 'Autoriser',
            onTap: () {
              Navigator.pop(f);
              setState(() => changer(true));
            },
          ),
          LigneFeuille(
            icone: 'fermer',
            texte: actuelle ? 'Ne plus autoriser' : 'Ne pas autoriser',
            danger: actuelle,
            onTap: () {
              Navigator.pop(f);
              setState(() => changer(false));
            },
          ),
        ],
      ),
    ),
  );

  Future<void> _supprimer() => montrerFeuille<void>(
    context,
    titre: 'Supprimer votre compte ?',
    contenu: (f) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Vos photos, vos reels et vos collections seront effacés après 30 jours. Vous pouvez revenir avant pour tout garder.', style: Textes.discret),
          const SizedBox(height: 18),
          LigneFeuille(
            icone: 'poubelle',
            texte: 'Supprimer mon compte',
            danger: true,
            onTap: () {
              Navigator.pop(f);
              Session.instance.deconnecter();
              context.go('/entree');
              bulle(context, 'Votre compte sera supprimé dans 30 jours. Reconnectez-vous avant pour tout garder.', icone: 'poubelle');
            },
          ),
          LigneFeuille(icone: 'fermer', texte: 'Annuler', onTap: () => Navigator.pop(f)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = Session.instance;
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    final nom = s.nomAffiche.isEmpty ? 'Akouavi K.' : s.nomAffiche;
    final email = s.email.isEmpty ? 'akouavi.k@gmail.com' : s.email;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
          ),
          const SizedBox(height: 14),
          Titre('Réglages', style: Textes.titre),
          const SizedBox(height: 18),
          Appuyable(
            semantique: 'Modifier le profil',
            onTap: () => context.push('/profil/modifier'),
            child: Plaque(
              rayon: 22,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Avatar(nom: nom, taille: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5, color: Couleurs.discret),
                        ),
                      ],
                    ),
                  ),
                  Icone('chevron-droite', taille: 20, couleur: Couleurs.discret),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _Groupe(
            titre: 'Compte',
            lignes: [
              _Ligne(icone: 'crayon', texte: 'Modifier le profil', onTap: () => context.push('/profil/modifier')),
              _Ligne(icone: 'cadenas', texte: 'E-mail et mot de passe', onTap: () => context.push('/profil/acces')),
              _Ligne(
                icone: 'bloque',
                texte: 'Comptes bloqués',
                valeur: '${_bloques.length}',
                onTap: () async {
                  await context.push('/profil/bloques');
                  setState(() {});
                },
              ),
            ],
          ),
          _Groupe(
            titre: 'Données mobiles',
            lignes: [
              _Ligne(
                icone: 'image',
                texte: 'Photos en qualité réduite en 3G',
                interrupteur: _Preferences.photosReduites,
                onChanged: (v) => setState(() => _Preferences.photosReduites = v),
              ),
              _Ligne(
                icone: 'reels',
                texte: 'Lire les reels en Wi-Fi seulement',
                interrupteur: _Preferences.reelsWifi,
                onChanged: (v) => setState(() => _Preferences.reelsWifi = v),
              ),
              _Ligne(
                icone: 'telecharger',
                texte: 'Envois en Wi-Fi seulement',
                interrupteur: _Preferences.envoisWifi,
                onChanged: (v) => setState(() => _Preferences.envoisWifi = v),
              ),
            ],
          ),
          _Groupe(
            titre: 'Affichage',
            lignes: [
              _Ligne(
                icone: 'etincelle',
                texte: 'Thème',
                valeur: switch (Affichage.instance.mode) {
                  ModeTheme.systeme => 'Comme le téléphone',
                  ModeTheme.clair => 'Clair',
                  ModeTheme.sombre => 'Sombre',
                },
                onTap: _theme,
              ),
              _Ligne(
                icone: 'texte',
                texte: 'Police du téléphone',
                interrupteur: Affichage.instance.policeDuTelephone,
                onChanged: (v) => setState(() => Affichage.instance.choisirPolice(duTelephone: v)),
              ),
              _Ligne(
                icone: 'reels',
                texte: 'Réduire les animations',
                interrupteur: Affichage.instance.reduireAnimations,
                onChanged: (v) => setState(() => Affichage.instance.choisirAnimations(reduire: v)),
              ),
            ],
          ),
          _Groupe(
            titre: 'Autorisations',
            lignes: [
              _Ligne(
                icone: 'cible',
                texte: 'Position',
                valeur: s.position ? 'Autorisée' : 'Refusée',
                onTap: () => _autorisation('Position', s.position, (v) => s.position = v),
              ),
              _Ligne(
                icone: 'camera',
                texte: 'Caméra USW',
                valeur: _Preferences.camera ? 'Autorisée' : 'Refusée',
                onTap: () => _autorisation('Caméra USW', _Preferences.camera, (v) => _Preferences.camera = v),
              ),
              _Ligne(
                icone: 'cloche',
                texte: 'Notifications',
                valeur: _Preferences.notifications ? 'Activées' : 'Désactivées',
                onTap: () async {
                  await context.push('/notifications/reglages');
                  setState(() {});
                },
              ),
            ],
          ),
          _Groupe(
            titre: 'Aide et informations',
            lignes: [
              _Ligne(icone: 'aide', texte: 'Aide', onTap: () => context.push('/document/aide')),
              _Ligne(icone: 'bouclier', texte: 'Règles communautaires', onTap: () => context.push('/document/regles')),
              _Ligne(icone: 'document', texte: 'Conditions générales', onTap: () => context.push('/document/cgu')),
              _Ligne(icone: 'cadenas', texte: 'Confidentialité', onTap: () => context.push('/document/confidentialite')),
            ],
          ),
          // L equipe de moderation (E24) : visible des moderateurs seulement.
          _Groupe(
            titre: 'Équipe',
            lignes: [_Ligne(icone: 'bouclier', texte: 'Modération', valeur: '12', onTap: () => context.push('/moderation'))],
          ),
          _Groupe(
            lignes: [
              _Ligne(
                icone: 'sortie',
                texte: 'Se déconnecter',
                danger: true,
                onTap: () async {
                  final oui = await confirmer(
                    context,
                    titre: 'Se déconnecter ?',
                    texte: 'Vos envois en cours seront mis en pause et reprendront à la prochaine connexion.',
                    action: 'Se déconnecter',
                    icone: 'sortie',
                  );
                  if (!oui || !context.mounted) return;
                  Session.instance.deconnecter();
                  context.go('/entree');
                },
              ),
            ],
          ),
          Center(
            child: TextButton(
              onPressed: _supprimer,
              child: Text(
                'Supprimer mon compte',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Couleurs.erreur),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text('USW 1.0 · Groupe 4, IFRI', style: TextStyle(fontSize: 12.5, color: Couleurs.discret)),
          ),
        ],
      ),
    );
  }
}

class _Groupe extends StatelessWidget {
  const _Groupe({this.titre, required this.lignes});

  final String? titre;
  final List<_Ligne> lignes;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titre != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              titre!,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte),
            ),
          ),
        Plaque(
          rayon: 22,
          child: Column(
            children: [
              for (var i = 0; i < lignes.length; i++) ...[if (i > 0) Divider(height: 1, thickness: 1, indent: 52, color: Couleurs.filet), lignes[i]],
            ],
          ),
        ),
      ],
    ),
  );
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.icone, required this.texte, this.valeur, this.onTap, this.interrupteur, this.onChanged, this.danger = false});

  final String icone;
  final String texte;
  final String? valeur;
  final VoidCallback? onTap;
  final bool? interrupteur;
  final ValueChanged<bool>? onChanged;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final couleur = danger ? Couleurs.erreur : Couleurs.texte;
    final ligne = Padding(
      padding: EdgeInsets.fromLTRB(16, interrupteur != null ? 6 : 14, 12, interrupteur != null ? 6 : 14),
      child: Row(
        children: [
          Icone(icone, taille: 22, couleur: couleur),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              texte,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: couleur),
            ),
          ),
          if (valeur != null) ...[Text(valeur!, style: TextStyle(fontSize: 14.5, color: Couleurs.discret)), const SizedBox(width: 6)],
          if (interrupteur != null)
            Switch(value: interrupteur!, activeTrackColor: Couleurs.ocean, onChanged: onChanged)
          else if (!danger)
            Icone('chevron-droite', taille: 18, couleur: Couleurs.discret),
        ],
      ),
    );
    if (interrupteur != null) return MergeSemantics(child: ligne);
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: ligne);
  }
}

/// E21 : modifier le profil.
class EcranModifierProfil extends StatefulWidget {
  const EcranModifierProfil({super.key});

  @override
  State<EcranModifierProfil> createState() => _EcranModifierProfilState();
}

class _EcranModifierProfilState extends State<EcranModifierProfil> {
  final s = Session.instance;
  late final _nom = TextEditingController(text: s.nomAffiche.isEmpty ? 'Akouavi K.' : s.nomAffiche);
  late final _pseudo = TextEditingController(text: s.nomUtilisateur.isEmpty ? 'akouavi.k' : s.nomUtilisateur);
  final _bio = TextEditingController(text: 'Photos du golfe de Guinée, de Ouidah à Grand-Popo.');
  final _site = TextEditingController(text: 'akouavi.photo');

  @override
  void dispose() {
    for (final c in [_nom, _pseudo, _bio, _site]) {
      c.dispose();
    }
    super.dispose();
  }

  void _terminer() {
    s
      ..nomAffiche = _nom.text.trim()
      ..nomUtilisateur = _pseudo.text.trim();
    bulle(context, 'Votre profil est enregistré.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              Expanded(
                child: Text(
                  'Modifier le profil',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              BoutonVerre(texte: 'Terminé', plein: true, large: false, onTap: _terminer),
            ],
          ),
          const SizedBox(height: 10),
          Text('Ces informations sont visibles par tous, à côté de vos photos.', style: Textes.discret, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ValueListenableBuilder(
                  valueListenable: _nom,
                  builder: (context, v, _) => Avatar(nom: v.text.isEmpty ? 'U' : v.text, taille: 104),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: RondVerre(
                    icone: 'camera',
                    semantique: 'Changer la photo',
                    taille: 40,
                    onTap: () => bulle(context, 'Le choix de la photo arrive au prochain lot.'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ChampVerre(libelle: 'Nom affiché', icone: 'profil', controleur: _nom),
          const SizedBox(height: 16),
          ChampVerre(libelle: "Nom d'utilisateur", icone: 'arobase', controleur: _pseudo),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _bio,
            builder: (context, v, _) => ChampVerre(
              libelle: 'Bio',
              icone: 'crayon',
              controleur: _bio,
              lignes: 3,
              aide: Text('${v.text.length} sur 160 caractères'),
              erreur: v.text.length > 160 ? '160 caractères au plus.' : null,
            ),
          ),
          const SizedBox(height: 16),
          ChampVerre(libelle: 'Site web', icone: 'lien', controleur: _site, facultatif: true, clavier: TextInputType.url),
        ],
      ),
    );
  }
}

/// E21 : l e-mail et le mot de passe du compte.
class EcranAcces extends StatelessWidget {
  const EcranAcces({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Session.instance;
    final email = s.email.isEmpty ? 'akouavi.k@gmail.com' : s.email;
    return _PageReglage(
      titre: 'E-mail et mot de passe',
      enfants: [
        _Groupe(
          titre: 'E-mail',
          lignes: [
            _Ligne(
              icone: 'enveloppe',
              texte: email,
              valeur: 'Changer',
              onTap: () => bulle(context, 'Un code part sur la nouvelle adresse pour la confirmer.', icone: 'enveloppe'),
            ),
          ],
        ),
        _Groupe(
          titre: 'Mot de passe',
          lignes: [_Ligne(icone: 'cadenas', texte: 'Changer le mot de passe', onTap: () => context.push('/entree/code?pour=oubli'))],
        ),
        _Groupe(
          titre: 'Connexion',
          lignes: [
            _Ligne(icone: 'google', texte: 'Google', valeur: 'Liée', onTap: () => bulle(context, 'Votre compte Google sert à vous connecter en un geste.')),
          ],
        ),
        Text('Changer le mot de passe déconnecte vos autres appareils.', style: Textes.petit),
      ],
    );
  }
}

/// E21 : les comptes bloques. Ils ne voient plus vos publications et ne
/// peuvent plus vous ecrire ; ils ne sont pas prevenus.
class EcranBloques extends StatefulWidget {
  const EcranBloques({super.key});

  @override
  State<EcranBloques> createState() => _EcranBloquesState();
}

class _EcranBloquesState extends State<EcranBloques> {
  @override
  Widget build(BuildContext context) => _PageReglage(
    titre: 'Comptes bloqués',
    enfants: [
      Text('Ils ne voient plus vos publications et ne peuvent plus vous écrire. Ils ne sont pas prévenus.', style: Textes.discret),
      const SizedBox(height: 18),
      if (_bloques.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text('Aucun compte bloqué.', textAlign: TextAlign.center, style: Textes.discret),
        )
      else
        Plaque(
          child: Column(
            children: [
              for (var i = 0; i < _bloques.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, indent: 70, color: Couleurs.filet),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Row(
                    children: [
                      Avatar(nom: _bloques[i].$1, taille: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_bloques[i].$1, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                            Text('@${_bloques[i].$2}', style: TextStyle(fontSize: 13, color: Couleurs.discret)),
                          ],
                        ),
                      ),
                      BoutonVerre(
                        texte: 'Débloquer',
                        large: false,
                        onTap: () {
                          final (nom, _) = _bloques[i];
                          setState(() => _bloques.removeAt(i));
                          bulle(context, '$nom est débloqué.');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
    ],
  );
}

/// E17 : ce qui envoie une notification. Tout se regle d un interrupteur ;
/// une publication retiree previent toujours (on doit savoir pourquoi).
class EcranReglagesNotifications extends StatefulWidget {
  const EcranReglagesNotifications({super.key});

  @override
  State<EcranReglagesNotifications> createState() => _EcranReglagesNotificationsState();
}

class _EcranReglagesNotificationsState extends State<EcranReglagesNotifications> {
  _Ligne _choix(String cle, String icone, String texte) => _Ligne(
    icone: icone,
    texte: texte,
    interrupteur: _Preferences.notifs[cle],
    onChanged: (v) => setState(() => _Preferences.notifs[cle] = v),
  );

  @override
  Widget build(BuildContext context) {
    final actives = _Preferences.notifications && !_Preferences.pause;
    // Coupees ou en pause : le detail reste visible, en retrait.
    Widget detail(Widget enfant) => AnimatedOpacity(
      opacity: actives ? 1 : 0.4,
      duration: Durees.interface,
      child: IgnorePointer(ignoring: !actives, child: enfant),
    );
    return _PageReglage(
      titre: 'Notifications',
      enfants: [
        _Groupe(
          lignes: [
            _Ligne(
              icone: 'cloche',
              texte: 'Autoriser les notifications',
              interrupteur: _Preferences.notifications,
              onChanged: (v) => setState(() => _Preferences.notifications = v),
            ),
            _Ligne(
              icone: 'pause',
              texte: 'Tout mettre en pause 8 h',
              interrupteur: _Preferences.pause,
              onChanged: _Preferences.notifications ? (v) => setState(() => _Preferences.pause = v) : null,
            ),
          ],
        ),
        detail(
          _Groupe(
            titre: 'Votre activité',
            lignes: [
              _choix('jaime', 'coeur', "J'aime et réactions"),
              _choix('commentaires', 'commentaire', 'Commentaires et réponses'),
              _choix('mentions', 'arobase', 'Mentions'),
              _choix('abonnes', 'profil', 'Nouveaux abonnés'),
            ],
          ),
        ),
        detail(
          _Groupe(
            titre: 'Vos publications',
            lignes: [
              _choix('verifiee', 'verifie', 'Publication vérifiée'),
              _choix('envoi', 'telecharger', 'Envoi terminé'),
              const _Ligne(icone: 'drapeau', texte: 'Publication retirée', interrupteur: true),
            ],
          ),
        ),
        detail(
          _Groupe(
            titre: 'Les comptes suivis',
            lignes: [_choix('suivis', 'image', 'Nouvelles publications')],
          ),
        ),
        Text('Une publication retirée vous prévient toujours, avec le motif et le recours.', style: Textes.petit),
      ],
    );
  }
}

/// Une sous-page des reglages : le retour, le titre au centre, le contenu.
class _PageReglage extends StatelessWidget {
  const _PageReglage({required this.titre, required this.enfants});

  final String titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, Mesures.hautOnglets + 40 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.pop()),
              Expanded(
                child: Text(
                  titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 22),
          ...enfants,
        ],
      ),
    );
  }
}
