// Les apercus des ecrans, en vraie police et vraies photos, a la taille du
// telephone de test (Tecno Camon 50 Pro : 1080 x 2364 a 440 ppp, soit
// 393 x 860, barre d etat et barre de gestes comprises). Ils servent au controle visuel, pas aux tests :
//   APERCU=1 flutter test test/apercus_test.dart --update-goldens
// ecrit les images dans test/apercus/.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usw/app.dart';
import 'package:usw/donnees/affichage.dart';
import 'package:usw/donnees/session.dart';
import 'package:usw/widgets/verre.dart';

final _actif = Platform.environment.containsKey('APERCU');

// APERCU_ECHELLE=1.3 : les memes ecrans en grand texte (le reglage du
// telephone de test), ranges a part, pour voir ce qui deborde.
final _echelle = double.tryParse(Platform.environment['APERCU_ECHELLE'] ?? '') ?? 1.0;
final _dossier = _echelle == 1.0 ? 'apercus' : 'apercus-${(_echelle * 100).round()}';

Future<void> _charger(WidgetTester tester) async {
  // Les images et les icones se decodent hors du temps simule des tests.
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    final police = FontLoader('WuraMi');
    for (final f in ['WuraMi-Light', 'WuraMi', 'WuraMi-SemiBold', 'WuraMi-Bold']) {
      police.addFont(rootBundle.load('assets/polices/$f.ttf'));
    }
    await police.load();
    // La police du telephone n existe pas dans les tests : Wura Mi.
    Affichage.instance.policeDuTelephone = false;
  });

  setUp(() {
    if (_echelle != 1.0) TestWidgetsFlutterBinding.instance.platformDispatcher.textScaleFactorTestValue = _echelle;
  });

  const ecrans = {
    'bienvenue': '/bienvenue',
    'oubli': '/entree/oubli',
    'nouveau-mdp': '/entree/nouveau',
    'entree': '/entree',
    'mot-de-passe': '/entree/mot-de-passe',
    'creer-mdp': '/entree/creer',
    'code': '/entree/code',
    'completer-1': '/completer/1',
    'completer-2': '/completer/2',
    'completer-3': '/completer/3',
    'accueil': '/accueil',
    'lieu': '/accueil/lieu/grand-popo',
    'photo': '/accueil/lieu/grand-popo/photo/0',
    'recherche': '/accueil/recherche',
    'notifications': '/notifications',
    'notif-reglages': '/notifications/reglages',
    'motif': '/notifications/motif',
    'reels': '/reels',
    'carte': '/carte',
    'autoriser': '/creer/autoriser',
    'camera-reel': '/creer/reel',
    'montage': '/creer/montage',
    'completer-infos': '/creer/completer',
    'details': '/creer/details',
    'choisir-lieu': '/creer/lieu',
    'envois': '/creer/envois',
    'profil': '/profil',
    'createur': '/accueil/createur/senan.voyage',
    'collection': '/profil/collection/0',
    'reglages': '/profil/reglages',
    'modifier': '/profil/modifier',
    'acces': '/profil/acces',
    'bloques': '/profil/bloques',
    'aide': '/document/aide',
    'regles': '/document/regles',
    'cgu': '/document/cgu',
    'confidentialite': '/document/confidentialite',
    'hors-ligne': '/etat/hors-ligne',
    'introuvable': '/etat/introuvable',
    'refusee': '/etat/refusee',
    'moderation': '/moderation',
    'decision': '/moderation/decision',
  };

  for (final MapEntry(key: nom, value: route) in ecrans.entries) {
    testWidgets('aperçu $nom', skip: !_actif, (tester) async {
      tester.view.physicalSize = const Size(1080, 2364);
      tester.view.devicePixelRatio = 2.75;
      tester.view.padding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
      tester.view.viewPadding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
      addTearDown(tester.view.reset);
      Session.instance
        ..nomAffiche = 'Akouavi K.'
        ..entrer('akouavi.k@gmail.com');
      await tester.pumpWidget(AppUsw(depart: route));
      // Laisser finir les entrees (mots qui montent, blocs qui montent).
      for (var t = 0; t < 2500; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _charger(tester);
      // Rien ne doit defiler pour etre lu, sauf les flux.
      for (final e in find.byType(Scrollable).evaluate()) {
        final p = (e as StatefulElement).state as ScrollableState;
        if (p.position.axis == Axis.vertical && p.position.maxScrollExtent > 0) {
          debugPrint('DEFILE $nom : ${p.position.maxScrollExtent.toStringAsFixed(0)} px');
        }
      }
      await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/$nom.png'));
    });
  }

  testWidgets('aperçu visionneuse', skip: !_actif, (tester) async {
    tester.view.physicalSize = const Size(1080, 2364);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
    tester.view.viewPadding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AppUsw(depart: '/accueil/lieu/grand-popo/photo/2'));
    for (var t = 0; t < 1500; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.bySemanticsLabel('Voir la photo en plein écran'));
    for (var t = 0; t < 1200; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/visionneuse.png'));
  });

  Future<void> preparer(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(1080, 2364);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
    tester.view.viewPadding = const FakeViewPadding(top: 32 * 2.75, bottom: 20 * 2.75);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppUsw(depart: route));
    for (var t = 0; t < 1500; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('aperçu banniere', skip: !_actif, (tester) async {
    await preparer(tester, '/accueil/lieu/grand-popo');
    await tester.tap(find.bySemanticsLabel('Enregistrer le lieu'));
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/banniere.png'));
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('aperçu accueil-defile', skip: !_actif, (tester) async {
    await preparer(tester, '/accueil');
    // Descendre (l en-tete se range), puis remonter un peu : il revient sur le flux.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/accueil-defile.png'));
  });

  testWidgets('aperçu feuille', skip: !_actif, (tester) async {
    await preparer(tester, '/completer/2');
    await tester.tap(find.bySemanticsLabel(RegExp('^Pays')));
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/feuille.png'));
  });

  for (final (nom, route, cible) in [
    ('commentaires', '/accueil/lieu/grand-popo/photo/0', 'Commentaires'),
    ('partager', '/accueil/lieu/grand-popo/photo/0', 'Partager'),
    ('telecharger', '/accueil/lieu/grand-popo/photo/0', "Télécharger l'original"),
    ('enregistrer', '/reels', 'Enregistrer'),
    ('reagir', '/reels', "J'aime"),
    ('creer', '/accueil', 'Créer'),
  ]) {
    testWidgets('aperçu feuille-$nom', skip: !_actif, (tester) async {
      await preparer(tester, route);
      await tester.tap(find.byWidgetPredicate((w) => w is Appuyable && w.semantique == cible).first);
      for (var t = 0; t < 900; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _charger(tester);
      await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/feuille-$nom.png'));
    });
  }

  testWidgets('aperçu feuille-signaler', skip: !_actif, (tester) async {
    await preparer(tester, '/accueil/lieu/grand-popo/photo/0');
    await tester.tap(find.byWidgetPredicate((w) => w is Appuyable && w.semantique == "Plus d'options").first);
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('Signaler la photo'));
    for (var t = 0; t < 1200; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('Pas pris à cet endroit'));
    for (var t = 0; t < 600; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/feuille-signaler.png'));
  });

  testWidgets('aperçu dialogue', skip: !_actif, (tester) async {
    await preparer(tester, '/profil/reglages');
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 300, scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Se déconnecter'));
    for (var t = 0; t < 900; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _charger(tester);
    await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/dialogue.png'));
  });

  // La nuit : tous les ecrans en theme sombre.
  for (final MapEntry(key: nom, value: route) in ecrans.entries) {
    testWidgets('aperçu sombre-$nom', skip: !_actif, (tester) async {
      Affichage.instance.mode = ModeTheme.sombre;
      addTearDown(() => Affichage.instance.mode = ModeTheme.systeme);
      await preparer(tester, route);
      await _charger(tester);
      await expectLater(find.byType(AppUsw), matchesGoldenFile('$_dossier/sombre-$nom.png'));
    });
  }
}
