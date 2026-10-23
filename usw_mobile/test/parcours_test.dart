import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usw/app.dart';
import 'package:usw/donnees/demo.dart';
import 'package:usw/donnees/session.dart';
import 'package:usw/widgets/verre.dart';

/// Avance de `ms` millisecondes, image par image, sans attendre les
/// animations qui tournent en continu (piles, mosaique).
Future<void> avancer(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> lancer(WidgetTester tester, [String depart = '/']) async {
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  Session.instance.deconnecter();
  await tester.pumpWidget(AppUsw(depart: depart));
}

void main() {
  testWidgets("L'ouverture mène à la bienvenue, puis à l'entrée", (tester) async {
    await lancer(tester);
    await avancer(tester, 6000);
    expect(find.text('Suivant'), findsOneWidget);
    await tester.tap(find.text('Passer'));
    await avancer(tester, 1500);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('Un e-mail connu demande le mot de passe, sans montrer le compte', (tester) async {
    await lancer(tester, '/entree');
    await avancer(tester, 1500);
    await tester.enterText(find.byType(TextField), emailDemo);
    await tester.tap(find.text('Continuer'));
    await avancer(tester, 1500);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text(emailDemo), findsOneWidget);
    // Un mot de passe trop court est refuse, avec le nombre d essais restants.
    await tester.enterText(find.byType(TextField), 'court');
    await tester.tap(find.text('Se connecter'));
    await avancer(tester, 500);
    expect(find.textContaining('Encore 4 essais'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'motdepasse2026');
    await tester.tap(find.text('Se connecter'));
    await avancer(tester, 1500);
    expect(find.text('Plage de Grand-Popo'), findsOneWidget);
  });

  testWidgets('Un e-mail inconnu crée le compte, puis complète le profil', (tester) async {
    await lancer(tester, '/entree');
    await avancer(tester, 1500);
    await tester.enterText(find.byType(TextField), 'nouveau.membre@gmail.com');
    await tester.tap(find.text('Continuer'));
    await avancer(tester, 1500);
    expect(find.text('8 caractères au moins'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'lagune2026');
    await avancer(tester, 500);
    await tester.tap(find.text('Continuer'));
    await avancer(tester, 1500);
    await tester.enterText(find.byType(TextField), '481937');
    await avancer(tester, 1500);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    expect(find.text('Ce nom est libre'), findsOneWidget);
  });

  testWidgets("L'accueil montre les lieux, et son en-tête se range au défilement", (tester) async {
    await lancer(tester, '/accueil');
    await avancer(tester, 2000);
    expect(find.text('Plage de Grand-Popo'), findsOneWidget);
    expect(find.text('USW'), findsOneWidget);
    // Descendre range l en-tete ; remonter le fait revenir.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await avancer(tester, 800);
    expect(find.bySemanticsLabel('Rechercher').hitTestable(), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
    await avancer(tester, 800);
    expect(find.bySemanticsLabel('Rechercher').hitTestable(), findsOneWidget);
  });

  testWidgets('Une pile ouvre son lieu, avec « Y aller »', (tester) async {
    await lancer(tester, '/accueil');
    await avancer(tester, 2000);
    await tester.tap(find.text('Plage de Grand-Popo'));
    await avancer(tester, 1500);
    expect(find.text('Y aller'), findsOneWidget);
    expect(find.text('@senan.voyage'), findsWidgets);
    expect(find.bySemanticsLabel('Capture vérifiée'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Retour'));
    await avancer(tester, 1500);
    expect(find.text('Y aller'), findsNothing);
  });

  testWidgets('Une photo du lieu montre sa fiche de capture, et on peut l aimer', (tester) async {
    await lancer(tester, '/accueil/lieu/grand-popo/photo/0');
    await avancer(tester, 2000);
    expect(find.text('Les cocotiers de Grand-Popo'), findsOneWidget);
    expect(find.text('2,1 k'), findsOneWidget);
    // Ne plus aimer : 2 140 -> 2 139, toujours « 2,1 k », et le coeur se vide.
    await tester.tap(find.text('2,1 k'));
    await avancer(tester, 500);
    expect(find.text('2,1 k'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Appuyable && w.semantique == "J'aime"), findsOneWidget);
    await tester.ensureVisible(find.text('Informations de capture'));
    expect(find.text('iPhone 14 Pro'), findsOneWidget);
  });

  testWidgets('Toucher la photo l ouvre en plein écran, avec le téléchargement', (tester) async {
    await lancer(tester, '/accueil/lieu/grand-popo/photo/0');
    await avancer(tester, 2000);
    expect(find.text('Capture vérifiée'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Voir la photo en plein écran'));
    await avancer(tester, 1000);
    expect(find.text('Original'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Fermer'));
    await avancer(tester, 800);
    expect(find.text('Original'), findsNothing);
  });
}
