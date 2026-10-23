// E02 Entree, facon Pinterest : une mosaique de photos qui glisse, l e-mail
// puis « Continuer », ou « Continuer avec Google ». E-mail connu : le mot de
// passe. Inconnu : creer le mot de passe, puis le code recu par e-mail.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../donnees/demo.dart';
import '../../donnees/session.dart';
import '../../theme/jetons.dart';
import '../../theme/theme.dart';
import '../../widgets/champ.dart';
import '../../widgets/icone.dart';
import '../../widgets/mouvement.dart';
import '../../widgets/page.dart';
import '../../widgets/photo.dart';
import '../../widgets/verre.dart';

final _formeEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

class EcranEntree extends StatefulWidget {
  const EcranEntree({super.key});

  @override
  State<EcranEntree> createState() => _EcranEntreeState();
}

class _EcranEntreeState extends State<EcranEntree> {
  final _email = TextEditingController();
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continuer() {
    final adresse = _email.text.trim();
    if (!_formeEmail.hasMatch(adresse)) {
      setState(() => _erreur = adresse.isEmpty ? 'Indiquez votre adresse e-mail.' : 'Cette adresse e-mail ne semble pas complète.');
      return;
    }
    final session = Session.instance;
    final existe = session.compteExiste(adresse);
    session.entrer(adresse);
    context.push(existe ? '/entree/mot-de-passe' : '/entree/creer');
  }

  void _google() {
    // Le lot 1 branchera google_sign_in et la verification du jeton par l API.
    Session.instance
      ..nomAffiche = 'Akouavi K.'
      ..entrer('akouavi.kossou@gmail.com');
    context.go('/completer/1');
  }

  @override
  Widget build(BuildContext context) {
    final taille = MediaQuery.sizeOf(context);
    final marge = Mesures.margeDe(taille.width);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox(height: taille.height * 0.5, child: const _Mosaique()),
          // Le formulaire se pose en bas et tient dans l ecran : rien a faire
          // defiler. Il ne defile que si le clavier lui prend la place.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, contraintes) => SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.fromLTRB(marge, 0, marge, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: contraintes.maxHeight - 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: Monte(child: LogoUsw(taille: 56))),
                          const SizedBox(height: 14),
                          Titre('Bienvenue sur USW', style: Textes.titre, centre: true),
                          const SizedBox(height: 22),
                          Monte(
                            delai: const Duration(milliseconds: 400),
                            child: ChampVerre(
                              icone: 'enveloppe',
                              indice: 'Entrez votre adresse e-mail',
                              controleur: _email,
                              clavier: TextInputType.emailAddress,
                              action: TextInputAction.go,
                              remplissage: const [AutofillHints.email],
                              erreur: _erreur,
                              onChanged: (_) {
                                if (_erreur != null) setState(() => _erreur = null);
                              },
                              onSubmitted: (_) => _continuer(),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Monte(
                            delai: const Duration(milliseconds: 460),
                            child: BoutonVerre(texte: 'Continuer', plein: true, onTap: _continuer),
                          ),
                          const SizedBox(height: 18),
                          const Monte(delai: Duration(milliseconds: 520), child: SeparateurOu()),
                          const SizedBox(height: 18),
                          Monte(
                            delai: const Duration(milliseconds: 580),
                            child: BoutonVerre(texte: 'Continuer avec Google', widgetIcone: const Icone('google', taille: 20), onTap: _google),
                          ),
                          const SizedBox(height: 22),
                          const Monte(delai: Duration(milliseconds: 640), child: MentionsLegales()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cinq colonnes de photos qui glissent lentement, une sur deux a rebours,
/// et se fondent dans le fond.
class _Mosaique extends StatefulWidget {
  const _Mosaique();

  @override
  State<_Mosaique> createState() => _MosaiqueState();
}

class _MosaiqueState extends State<_Mosaique> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 60));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (animationsReduites(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    // Trois colonnes sur un telephone, cinq sur une tablette.
    final nombre = largeur >= 600 ? 5 : 3;
    const ecart = 8.0;
    final colonne = (largeur - ecart * (nombre + 1)) / nombre;
    final hauteurPhoto = colonne * 1.33;
    final cycle = (hauteurPhoto + ecart) * 5;
    // Chaque colonne est dessinee une fois (RepaintBoundary) puis seulement
    // deplacee : rien n est reconstruit ni redessine a chaque image. Le fondu
    // vers le bas est un voile du fond pose dessus, pas un masque (calque).
    return ClipRect(
      child: Stack(
        children: [
          for (var c = 0; c < nombre; c++)
            Positioned(
              left: ecart + c * (colonne + ecart),
              width: colonne,
              top: 0,
              child: AnimatedBuilder(
                animation: _c,
                // Les colonnes paires descendent, les impaires montent, chacune a son rythme.
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, -cycle + ((c.isEven ? 1 : -1) * _c.value * cycle * (1 + 0.15 * c)) % cycle - (c.isOdd ? hauteurPhoto * 0.5 : 0)),
                  child: child,
                ),
                child: RepaintBoundary(
                  child: Column(
                    children: [
                      for (final id in [...colonnesEntree[c], ...colonnesEntree[c], ...colonnesEntree[c]])
                        Padding(
                          padding: const EdgeInsets.only(bottom: ecart),
                          child: SizedBox(height: hauteurPhoto, child: PhotoArrondie(id, rayon: 16)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Couleurs.fond.withValues(alpha: 0), Couleurs.fond.withValues(alpha: 0), Couleurs.fond],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
