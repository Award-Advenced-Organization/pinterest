// E02, la suite de l entree : le mot de passe (compte existant), le creer
// (nouveau compte), le code recu par e-mail, le mot de passe oublie et le
// nouveau mot de passe. Aucune page ne montre le nom ni la photo du compte
// avant la connexion : ce serait dire a n importe qui qu une adresse est inscrite.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../donnees/session.dart';
import '../../theme/jetons.dart';
import '../../theme/theme.dart';
import '../../widgets/champ.dart';
import '../../widgets/icone.dart';
import '../../widgets/mouvement.dart';
import '../../widgets/page.dart';
import '../../widgets/verre.dart';

const _delaiForm = Duration(milliseconds: 400);

/// L adresse tapee, pour qu on sache quel compte on ouvre, sans rien en dire de plus.
class _EmailTape extends StatelessWidget {
  const _EmailTape();

  @override
  Widget build(BuildContext context) => Center(
    child: Monte(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icone('enveloppe', taille: 17, couleur: Couleurs.discret),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                Session.instance.email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Couleurs.texte),
              ),
            ),
            Lien('Changer', onTap: () => context.go('/entree')),
          ],
        ),
      ),
    ),
  );
}

class EcranMotDePasse extends StatefulWidget {
  const EcranMotDePasse({super.key});

  @override
  State<EcranMotDePasse> createState() => _EcranMotDePasseState();
}

class _EcranMotDePasseState extends State<EcranMotDePasse> {
  final _mdp = TextEditingController();
  String? _erreur;
  int _essais = 5;

  @override
  void dispose() {
    _mdp.dispose();
    super.dispose();
  }

  void _connecter() {
    // Demonstration : 8 caracteres au moins ouvrent le compte. L API (lot 1)
    // comptera les essais : 5, puis une pause de 15 minutes.
    if (_mdp.text.length < 8) {
      setState(() {
        _essais = (_essais - 1).clamp(0, 5);
        _erreur = _essais > 0
            ? 'Mot de passe incorrect. Encore $_essais essai${_essais > 1 ? 's' : ''}.'
            : 'Trop d\'essais. Réessayez dans 15 minutes ou changez de mot de passe.';
      });
      return;
    }
    Session.instance.connecter();
    context.go('/accueil');
  }

  @override
  Widget build(BuildContext context) => PageFormulaire(
    enfants: [
      const _EmailTape(),
      const SizedBox(height: 14),
      Titre('Entrez votre mot de passe', style: Textes.titre, centre: true),
      const SizedBox(height: 26),
      Monte(
        delai: _delaiForm,
        child: ChampVerre(
          icone: 'cadenas',
          indice: 'Entrez votre mot de passe',
          controleur: _mdp,
          secret: true,
          autofocus: true,
          action: TextInputAction.go,
          remplissage: const [AutofillHints.password],
          erreur: _erreur,
          onChanged: (_) {
            if (_erreur != null) setState(() => _erreur = null);
          },
          onSubmitted: (_) => _connecter(),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Lien('Mot de passe oublié ?', onTap: () => context.push('/entree/oubli')),
      ),
      const SizedBox(height: 10),
      Monte(
        delai: _delaiForm + const Duration(milliseconds: 120),
        child: BoutonVerre(texte: 'Se connecter', plein: true, onTap: _essais > 0 ? _connecter : null),
      ),
    ],
  );
}

/// Les regles d un mot de passe, communes a la creation et au changement.
List<(String, bool)> _regles(String mdp) => [
  ('8 caractères au moins', mdp.length >= 8),
  ('Un chiffre', mdp.contains(RegExp(r'\d'))),
  ('Une lettre', mdp.contains(RegExp(r'[A-Za-zÀ-ÿ]'))),
];

class EcranCreerMotDePasse extends StatefulWidget {
  const EcranCreerMotDePasse({super.key});

  @override
  State<EcranCreerMotDePasse> createState() => _EcranCreerMotDePasseState();
}

class _EcranCreerMotDePasseState extends State<EcranCreerMotDePasse> {
  final _mdp = TextEditingController();

  @override
  void dispose() {
    _mdp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regles = _regles(_mdp.text);
    final ok = regles.every((r) => r.$2);
    final force = regles.where((r) => r.$2).length + (_mdp.text.length >= 12 ? 1 : 0);
    return PageFormulaire(
      enfants: [
        Titre('Créez votre mot de passe', style: Textes.titre, centre: true),
        const SizedBox(height: 10),
        Monte(
          delai: const Duration(milliseconds: 300),
          child: TextePage([('Pour le compte ', false), (Session.instance.email, true), ('.', false)], centre: true),
        ),
        const SizedBox(height: 26),
        Monte(
          delai: _delaiForm,
          child: ChampVerre(
            icone: 'cadenas',
            indice: 'Créez votre mot de passe',
            controleur: _mdp,
            secret: true,
            autofocus: true,
            remplissage: const [AutofillHints.newPassword],
            onChanged: (_) => setState(() {}),
            aide: _mdp.text.isEmpty ? null : _Force(niveau: force),
          ),
        ),
        const SizedBox(height: 14),
        Criteres(criteres: regles),
        const SizedBox(height: 10),
        BoutonVerre(texte: 'Continuer', plein: true, onTap: ok ? () => context.push('/entree/code') : null),
      ],
      pied: const MentionsLegales(),
    );
  }
}

class _Force extends StatelessWidget {
  const _Force({required this.niveau});

  final int niveau;

  @override
  Widget build(BuildContext context) {
    const noms = ['Trop faible', 'Faible', 'Moyen', 'Solide', 'Très solide'];
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 16,
            height: 4,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: i < niveau ? Couleurs.ocean : Couleurs.voile),
          ),
        const SizedBox(width: 6),
        Text(noms[niveau.clamp(0, 4)]),
      ],
    );
  }
}

class EcranCode extends StatefulWidget {
  const EcranCode({super.key, this.pourOubli = false});

  /// Le code d un mot de passe oublie mene au nouveau mot de passe.
  final bool pourOubli;

  @override
  State<EcranCode> createState() => _EcranCodeState();
}

class _EcranCodeState extends State<EcranCode> {
  String _code = '';
  int _reste = 59;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _demarrer();
  }

  void _demarrer() {
    _minuteur?.cancel();
    _reste = 59;
    _minuteur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _reste--);
      if (_reste <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  void _verifier() {
    if (widget.pourOubli) {
      context.pushReplacement('/entree/nouveau');
    } else {
      Session.instance.connecter();
      context.go('/completer/1');
    }
  }

  @override
  Widget build(BuildContext context) => PageFormulaire(
    enfants: [
      Titre('Vérifiez votre e-mail', style: Textes.titre, centre: true),
      const SizedBox(height: 10),
      Monte(
        delai: const Duration(milliseconds: 300),
        child: TextePage([('Nous avons envoyé un code à 6 chiffres à ', false), (Session.instance.email, true), ('.', false)], centre: true),
      ),
      const SizedBox(height: 26),
      Monte(
        delai: _delaiForm,
        child: ChampCode(onChanged: (v) => setState(() => _code = v), onComplet: (_) => _verifier()),
      ),
      const SizedBox(height: 14),
      Center(
        child: _reste > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icone('horloge', taille: 15, couleur: Couleurs.discret),
                  const SizedBox(width: 6),
                  Text('Renvoyer le code dans 0:${_reste.toString().padLeft(2, '0')}', style: Textes.petit),
                ],
              )
            : Lien(
                'Renvoyer le code',
                onTap: () {
                  _demarrer();
                  bulle(context, 'Un nouveau code est parti.');
                },
              ),
      ),
      const SizedBox(height: 22),
      BoutonVerre(texte: 'Vérifier', plein: true, onTap: _code.length == 6 ? _verifier : null),
    ],
    pied: PiedLien(question: 'Mauvaise adresse ?', lien: 'La corriger', onTap: () => context.go('/entree')),
  );
}

class EcranOubli extends StatefulWidget {
  const EcranOubli({super.key});

  @override
  State<EcranOubli> createState() => _EcranOubliState();
}

class _EcranOubliState extends State<EcranOubli> {
  late final _email = TextEditingController(text: Session.instance.email);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _envoyer() {
    // Toujours la meme reponse, que l adresse soit inscrite ou non.
    Session.instance.entrer(_email.text);
    context.push('/entree/code?pour=oubli');
  }

  @override
  Widget build(BuildContext context) => PageFormulaire(
    enfants: [
      Titre('Mot de passe oublié', style: Textes.titre, centre: true),
      const SizedBox(height: 10),
      Monte(
        delai: const Duration(milliseconds: 300),
        child: const TextePage([("Indiquez l'e-mail du compte : nous y enverrons un code pour choisir un nouveau mot de passe.", false)], centre: true),
      ),
      const SizedBox(height: 26),
      Monte(
        delai: _delaiForm,
        child: ChampVerre(
          icone: 'enveloppe',
          indice: 'Entrez votre adresse e-mail',
          controleur: _email,
          clavier: TextInputType.emailAddress,
          action: TextInputAction.send,
          onSubmitted: (_) => _envoyer(),
        ),
      ),
      const SizedBox(height: 18),
      BoutonVerre(texte: 'Envoyer le code', plein: true, onTap: _envoyer),
    ],
    pied: PiedLien(question: 'Vous vous en souvenez ?', lien: 'Se connecter', onTap: () => context.pop()),
  );
}

class EcranNouveauMotDePasse extends StatefulWidget {
  const EcranNouveauMotDePasse({super.key});

  @override
  State<EcranNouveauMotDePasse> createState() => _EcranNouveauMotDePasseState();
}

class _EcranNouveauMotDePasseState extends State<EcranNouveauMotDePasse> {
  final _mdp = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _mdp.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regles = [..._regles(_mdp.text).take(2), ('Les deux mots de passe sont identiques', _mdp.text.isNotEmpty && _mdp.text == _confirmation.text)];
    final ok = regles.every((r) => r.$2);
    return PageFormulaire(
      enfants: [
        Titre('Nouveau mot de passe', style: Textes.titre, centre: true),
        const SizedBox(height: 10),
        Monte(delai: const Duration(milliseconds: 300), child: const TextePage([("Choisissez-en un que vous n'utilisez pas ailleurs.", false)], centre: true)),
        const SizedBox(height: 26),
        ChampVerre(
          icone: 'cadenas',
          indice: 'Nouveau mot de passe',
          controleur: _mdp,
          secret: true,
          autofocus: true,
          remplissage: const [AutofillHints.newPassword],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ChampVerre(indice: 'Confirmez le mot de passe', icone: 'cadenas', controleur: _confirmation, secret: true, onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        Criteres(criteres: regles),
        const SizedBox(height: 10),
        BoutonVerre(
          texte: 'Enregistrer',
          plein: true,
          onTap: ok
              ? () {
                  context.go('/entree/mot-de-passe');
                  bulle(context, 'Mot de passe changé. Connectez-vous avec le nouveau.');
                }
              : null,
        ),
      ],
    );
  }
}
