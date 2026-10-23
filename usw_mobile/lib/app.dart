import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'donnees/affichage.dart';
import 'donnees/demo.dart';
import 'ecrans/accueil.dart';
import 'ecrans/carte.dart';
import 'ecrans/creer.dart';
import 'ecrans/documents.dart';
import 'ecrans/etats.dart';
import 'ecrans/bienvenue.dart';
import 'ecrans/compte/completer.dart';
import 'ecrans/compte/entree.dart';
import 'ecrans/compte/mot_de_passe.dart';
import 'ecrans/lieu.dart';
import 'ecrans/moderation.dart';
import 'ecrans/notifications.dart';
import 'ecrans/photo.dart';
import 'ecrans/profil.dart';
import 'ecrans/recherche.dart';
import 'ecrans/reels.dart';
import 'ecrans/reglages.dart';
import 'ecrans/ouverture.dart';
import 'theme/defilement.dart';
import 'theme/jetons.dart';
import 'theme/theme.dart';
import 'widgets/onglets.dart';

GoRouter creerRouteur({String depart = '/'}) => GoRouter(
  initialLocation: depart,
  routes: [
    GoRoute(path: '/', builder: (context, _) => const EcranOuverture()),
    GoRoute(path: '/bienvenue', builder: (context, _) => const EcranBienvenue()),
    GoRoute(
      path: '/entree',
      builder: (context, _) => const EcranEntree(),
      routes: [
        GoRoute(path: 'mot-de-passe', builder: (context, _) => const EcranMotDePasse()),
        GoRoute(path: 'creer', builder: (context, _) => const EcranCreerMotDePasse()),
        GoRoute(
          path: 'code',
          builder: (context, etat) => EcranCode(pourOubli: etat.uri.queryParameters['pour'] == 'oubli'),
        ),
        GoRoute(path: 'oubli', builder: (context, _) => const EcranOubli()),
        GoRoute(path: 'nouveau', builder: (context, _) => const EcranNouveauMotDePasse()),
      ],
    ),
    GoRoute(
      path: '/completer/:etape',
      builder: (context, etat) => EcranCompleter(etape: int.tryParse(etat.pathParameters['etape'] ?? '') ?? 1),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, _, navigation) => Coquille(navigation: navigation),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accueil',
              builder: (context, _) => const EcranAccueil(),
              routes: [
                // La recherche et ses filtres gardent la barre d onglets.
                GoRoute(path: 'recherche', builder: (context, _) => const EcranRecherche()),
                GoRoute(
                  path: 'createur/:pseudo',
                  builder: (context, etat) => EcranCreateur(pseudo: etat.pathParameters['pseudo'] ?? ''),
                ),
                // La page d un lieu garde la barre d onglets (Accueil actif).
                GoRoute(
                  path: 'lieu/:id',
                  builder: (context, etat) {
                    final lieu = lieuxDemo.where((l) => l.id == etat.pathParameters['id']).firstOrNull;
                    return lieu == null ? const EcranEtat(etat: 'introuvable') : EcranLieu(lieu: lieu);
                  },
                  routes: [
                    GoRoute(
                      path: 'photo/:n',
                      builder: (context, etat) {
                        final lieu = lieuxDemo.where((l) => l.id == etat.pathParameters['id']).firstOrNull;
                        final n = int.tryParse(etat.pathParameters['n'] ?? '') ?? 0;
                        return lieu == null
                            ? const EcranEtat(etat: 'introuvable')
                            : EcranPhoto(lieu: lieu, index: n, commentaires: etat.uri.queryParameters['commentaires'] == '1');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/reels', builder: (context, _) => const EcranReels())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/carte', builder: (context, _) => const EcranCarte())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profil',
              builder: (context, _) => const EcranProfil(),
              routes: [
                GoRoute(path: 'reglages', builder: (context, _) => const EcranReglages()),
                GoRoute(path: 'modifier', builder: (context, _) => const EcranModifierProfil()),
                GoRoute(path: 'acces', builder: (context, _) => const EcranAcces()),
                GoRoute(path: 'bloques', builder: (context, _) => const EcranBloques()),
                GoRoute(
                  path: 'collection/:n',
                  builder: (context, etat) => EcranCollection(index: int.tryParse(etat.pathParameters['n'] ?? '') ?? 0),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Creer : le « + » ouvre la feuille (ouvrirCreer), puis ces pages.
    GoRoute(path: '/creer/autoriser', builder: (context, _) => const EcranAutoriser()),
    GoRoute(path: '/creer/reel', builder: (context, _) => const EcranCameraReel()),
    GoRoute(path: '/creer/montage', builder: (context, _) => const EcranMontage()),
    GoRoute(path: '/creer/completer', builder: (context, _) => const EcranCompleterInfos()),
    GoRoute(
      path: '/creer/details',
      builder: (context, etat) => EcranDetails(reel: etat.uri.queryParameters['reel'] == '1', declaree: etat.uri.queryParameters['declare'] == '1'),
    ),
    GoRoute(path: '/creer/lieu', builder: (context, _) => const EcranChoisirLieu()),
    GoRoute(path: '/creer/envois', builder: (context, _) => const EcranEnvois()),
    GoRoute(
      path: '/notifications',
      builder: (context, _) => const EcranNotifications(),
      routes: [
        GoRoute(path: 'reglages', builder: (context, _) => const EcranReglagesNotifications()),
        GoRoute(path: 'motif', builder: (context, _) => const EcranMotif()),
      ],
    ),
    // Aide, regles, conditions, confidentialite.
    GoRoute(
      path: '/document/:id',
      builder: (context, etat) => EcranDocument(id: etat.pathParameters['id'] ?? ''),
    ),
    // Hors ligne, introuvable, publication refusee (?titre=).
    GoRoute(
      path: '/etat/:id',
      builder: (context, etat) => EcranEtat(etat: etat.pathParameters['id'] ?? '', titre: etat.uri.queryParameters['titre']),
    ),
    GoRoute(
      path: '/moderation',
      builder: (context, _) => const EcranModeration(),
      routes: [
        GoRoute(
          path: 'decision',
          builder: (context, etat) => EcranDecision(index: int.tryParse(etat.uri.queryParameters['n'] ?? '') ?? 0),
        ),
      ],
    ),
  ],
);

class AppUsw extends StatefulWidget {
  const AppUsw({super.key, this.depart = '/'});

  /// L ecran de depart : l ouverture, ou un autre pour les tests.
  final String depart;

  @override
  State<AppUsw> createState() => _AppUswState();
}

class _AppUswState extends State<AppUsw> with WidgetsBindingObserver {
  late final _routeur = creerRouteur(depart: widget.depart);
  final _affichage = Affichage.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _affichage.addListener(_changer);
    Couleurs.sombre = _nuit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _affichage.removeListener(_changer);
    _routeur.dispose();
    super.dispose();
  }

  bool _nuit() => switch (_affichage.mode) {
    ModeTheme.clair => false,
    ModeTheme.sombre => true,
    ModeTheme.systeme => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
  };

  // Le telephone passe en sombre (ou revient en clair) : on suit, s il le faut.
  @override
  void didChangePlatformBrightness() => _changer();

  // Les couleurs se lisent a la construction : quand le theme ou la police
  // change, tout l arbre se reconstruit, sans perdre la page ouverte.
  void _changer() {
    Couleurs.sombre = _nuit();
    setState(() {});
    void marquer(Element e) {
      e.markNeedsBuild();
      e.visitChildren(marquer);
    }

    (context as Element).visitChildren(marquer);
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: barreDuTheme,
    child: MaterialApp.router(
      title: 'USW',
      debugShowCheckedModeBanner: false,
      theme: themeUsw(),
      routerConfig: _routeur,
      scrollBehavior: const DefilementUsw(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Les animations : toutes par defaut ; reduites si on le choisit.
      builder: (context, enfant) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: _affichage.reduireAnimations),
        child: enfant!,
      ),
    ),
  );
}
