// E17 Notifications : ce qui s est passe autour de vos photos, groupe par
// moment. Une notification pas encore lue a un fond de verre, sans point ni
// couleur. Chacune mene la ou elle parle : la photo (et ses commentaires),
// le profil, les envois, le motif d un retrait. Le lot 6 branchera
// GET /api/v1/notifications et les pousses (FCM).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import '../widgets/avatar.dart';
import '../widgets/icone.dart';
import '../widgets/page.dart';
import '../widgets/photo.dart';
import '../widgets/verre.dart';

enum _Genre { personne, verifiee, envoi, retiree }

class _Notif {
  const _Notif({
    required this.genre,
    required this.morceaux,
    required this.quand,
    this.nom,
    this.photo,
    this.nouvelle = false,
    this.abonnement = false,
    this.route,
  });

  final _Genre genre;

  /// (texte, gras)
  final List<(String, bool)> morceaux;
  final String quand;
  final String? nom;
  final String? photo;
  final bool nouvelle;
  final bool abonnement;

  /// La ou mene la notification.
  final String? route;
}

const _aujourdhui = [
  _Notif(
    genre: _Genre.personne,
    nom: 'Mawuli S.',
    morceaux: [('Mawuli S.', true), (' a aimé votre photo.', false)],
    quand: '2 min',
    photo: 'p108',
    nouvelle: true,
    route: '/accueil/lieu/grand-popo/photo/0',
  ),
  _Notif(
    genre: _Genre.personne,
    nom: 'Kofi D.',
    morceaux: [('Kofi D.', true), (' a commenté : « Quelle lumière, à quelle heure ? »', false)],
    quand: '1 h',
    photo: 'p77',
    nouvelle: true,
    route: '/accueil/lieu/ouidah/photo/0?commentaires=1',
  ),
  _Notif(
    genre: _Genre.verifiee,
    morceaux: [('Votre photo ', false), ('Ponton de Ouidah', true), (' est en ligne, avec le badge Capture vérifiée.', false)],
    quand: '3 h',
    photo: 'p77',
    route: '/accueil/lieu/ouidah/photo/0',
  ),
  _Notif(genre: _Genre.envoi, morceaux: [('Votre envoi de ', false), ('3 photos', true), (' est terminé.', false)], quand: '5 h', route: '/creer/envois'),
];

const _semaine = [
  _Notif(genre: _Genre.personne, nom: 'Aïcha K.', morceaux: [('Aïcha K.', true), (" s'est abonnée à vous.", false)], quand: '2 j', abonnement: true, route: '/accueil/createur/aicha.k'),
  _Notif(
    genre: _Genre.personne,
    nom: 'Hounkpè T.',
    morceaux: [('@hounkpe', true), (' vous a mentionnée : « @akouavi.k regarde ce coucher de soleil »', false)],
    quand: '3 j',
    photo: 'p71',
    route: '/accueil/lieu/aheme/photo/3?commentaires=1',
  ),
  _Notif(
    genre: _Genre.retiree,
    morceaux: [('Votre reel ', false), ('Cascade de Kota', true), (' a été retiré : il contient des images générées par IA.', false)],
    quand: '4 j',
    route: '/notifications/motif',
  ),
  _Notif(
    genre: _Genre.personne,
    nom: 'Sènan Voyage',
    morceaux: [('Sènan Voyage', true), (' a publié 4 photos à ', false), ('Porto-Novo', true), ('.', false)],
    quand: '6 j',
    photo: 'p57',
    route: '/accueil/lieu/porto-novo',
  ),
];

class EcranNotifications extends StatelessWidget {
  const EcranNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.paddingOf(context).top;
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(marge, haut + 8, marge, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/accueil')),
              const Spacer(),
              RondVerre(
                icone: 'reglages',
                semantique: 'Réglages des notifications',
                onTap: () => context.push('/notifications/reglages'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Titre('Notifications', style: Textes.titre),
          const SizedBox(height: 18),
          const _Groupe("Aujourd'hui"),
          for (final n in _aujourdhui) _Ligne(n),
          const SizedBox(height: 14),
          const _Groupe('Cette semaine'),
          for (final n in _semaine) _Ligne(n),
        ],
      ),
    );
  }
}

class _Groupe extends StatelessWidget {
  const _Groupe(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      texte,
      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Couleurs.texte),
    ),
  );
}

class _Ligne extends StatefulWidget {
  const _Ligne(this.n);

  final _Notif n;

  @override
  State<_Ligne> createState() => _LigneState();
}

class _LigneState extends State<_Ligne> {
  bool _abonne = false;
  late bool _nouvelle = widget.n.nouvelle;

  @override
  Widget build(BuildContext context) {
    final n = widget.n;
    final Widget gauche = switch (n.genre) {
      _Genre.personne => Avatar(nom: n.nom!, taille: 44),
      _Genre.verifiee => _Rond(
        fond: Couleurs.limonade,
        child: Icone('verifie', taille: 22, couleur: Couleurs.encreLimonade),
      ),
      _Genre.envoi => _Rond(
        fond: Couleurs.surface.withValues(alpha: 0.75),
        child: Icone('telecharger', taille: 22, couleur: Couleurs.texte),
      ),
      _Genre.retiree => _Rond(
        fond: Couleurs.erreur.withValues(alpha: 0.12),
        child: Icone('drapeau', taille: 22, couleur: Couleurs.erreur),
      ),
    };
    final Widget? droite = n.abonnement
        ? BoutonVerre(texte: _abonne ? 'Abonné' : "S'abonner", plein: !_abonne, large: false, onTap: () => setState(() => _abonne = !_abonne))
        : n.genre == _Genre.retiree
        ? Text(
            'Voir le motif',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Couleurs.texte, decoration: TextDecoration.underline),
          )
        : n.photo != null
        ? SizedBox(width: 46, height: 58, child: PhotoArrondie(n.photo!, rayon: 10))
        : null;
    final contenu = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          gauche,
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  for (final (t, gras) in n.morceaux)
                    TextSpan(
                      text: t,
                      style: gras ? const TextStyle(fontWeight: FontWeight.w700) : null,
                    ),
                  TextSpan(
                    // Insecable : « 3 h » ne se coupe pas en fin de ligne.
                    text: '  ${n.quand.replaceAll(' ', ' ')}',
                    style: TextStyle(fontSize: 13, color: Couleurs.discret),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14.5, height: 1.4, color: Couleurs.texte),
            ),
          ),
          if (droite != null) ...[const SizedBox(width: 10), droite],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Appuyable(
        semantique: n.morceaux.map((m) => m.$1).join(),
        onTap: n.route == null
            ? null
            : () {
                // Ouverte, elle est lue : son fond s efface au retour.
                setState(() => _nouvelle = false);
                context.push(n.route!);
              },
        // Pas encore lue : un fond de verre, sans point ni couleur.
        child: _nouvelle
            ? DecoratedBox(
                decoration: BoxDecoration(color: Couleurs.surface.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(18)),
                child: contenu,
              )
            : contenu,
      ),
    );
  }
}

class _Rond extends StatelessWidget {
  const _Rond({required this.fond, required this.child});

  final Color fond;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
    child: child,
  );
}

/// E37 Le motif d un retrait, ouvert depuis sa notification : ce qui a ete
/// vu, ce que ca change, et le recours. Tout tient sans defiler.
class EcranMotif extends StatefulWidget {
  const EcranMotif({super.key});

  @override
  State<EcranMotif> createState() => _EcranMotifState();
}

class _EcranMotifState extends State<EcranMotif> {
  bool _demande = false;

  @override
  Widget build(BuildContext context) {
    final marge = Mesures.margeDe(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(marge, 8, marge, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RondVerre(icone: 'retour', semantique: 'Retour', onTap: () => context.canPop() ? context.pop() : context.go('/notifications')),
                  const Expanded(
                    child: Text(
                      'Reel retiré',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const SizedBox(width: 64, height: 84, child: PhotoArrondie('p15', rayon: 14)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cascade de Kota', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Votre reel de 0:31 · retiré il y a 4 jours', style: TextStyle(fontSize: 13.5, color: Couleurs.discret)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Plaque(
                rayon: 20,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icone('etincelle', taille: 20, couleur: Couleurs.texte),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text("Signes d'image générée", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          '72 %',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Couleurs.erreur),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(value: 0.72, minHeight: 6, color: Couleurs.erreur, backgroundColor: Couleurs.filet),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "L'eau de la chute se répète d'une image à l'autre et le ciel n'a pas de bruit de capteur.",
                      style: Textes.petit.copyWith(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Plaque(
                rayon: 20,
                padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  children: [
                    _Consequence('oeil-barre', "Le reel n'est plus visible, ni par lien ni sur la carte."),
                    SizedBox(height: 10),
                    _Consequence('coche', 'Vos autres publications et votre compte ne sont pas touchés.'),
                    SizedBox(height: 10),
                    _Consequence('bouclier', "Si c'est une vraie vidéo, une personne de l'équipe la revoit sous 48 h."),
                  ],
                ),
              ),
              const Spacer(),
              BoutonVerre(
                texte: _demande ? 'Demande envoyée' : 'Demander une vérification',
                plein: !_demande,
                icone: _demande ? 'coche' : null,
                onTap: _demande
                    ? null
                    : () {
                        setState(() => _demande = true);
                        bulle(context, "Demande envoyée. L'équipe vous répond sous 48 h.", icone: 'bouclier');
                      },
              ),
              const SizedBox(height: 10),
              BoutonVerre(texte: 'Lire les règles', onTap: () => context.push('/document/regles')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Consequence extends StatelessWidget {
  const _Consequence(this.icone, this.texte);

  final String icone;
  final String texte;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icone(icone, taille: 19, couleur: Couleurs.texte),
      const SizedBox(width: 10),
      Expanded(
        child: Text(texte, style: TextStyle(fontSize: 14, height: 1.35, color: Couleurs.texte)),
      ),
    ],
  );
}
