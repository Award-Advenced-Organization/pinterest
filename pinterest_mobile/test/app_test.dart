import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinterest_mobile/core/theme/gestalt_theme.dart';
import 'package:pinterest_mobile/core/widgets/pin_icon.dart';
import 'package:pinterest_mobile/core/widgets/ui.dart';
import 'package:pinterest_mobile/models/pin.dart';

/// Thème minimal (sans police téléchargée) pour tester les composants.
Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  final palette = brightness == Brightness.light ? PinPalette.light : PinPalette.dark;
  return MaterialApp(
    theme: ThemeData(brightness: brightness, extensions: [palette]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Pin.fromJson', () {
    test('lit un carrousel, la couleur dominante et les compteurs', () {
      final pin = Pin.fromJson({
        'id': 'pin_49',
        'title': 'Moulins de Santorin',
        'image_url': '/pins/49.jpg',
        'images': ['/pins/49.jpg', '/pins/45.jpg', '/pins/46.jpg'],
        'width': 474,
        'height': 632,
        'dominant_color': '#336699',
        'creator': {'id': 'c1', 'name': 'Léa Martin', 'username': 'lea.martin'},
        'is_saved': true,
        'board_id': 'board_1',
        'like_count': 12,
        'liked': true,
      });
      expect(pin.isCarousel, isTrue);
      expect(pin.isCollage, isFalse);
      expect(pin.aspectRatio, closeTo(474 / 632, 0.001));
      expect(pin.color, const Color(0xFF336699));
      expect(pin.isSaved, isTrue);
      expect(pin.boardId, 'board_1');
      expect(pin.likeCount, 12);
      expect(pin.creator.name, 'Léa Martin');
    });

    test('valeurs par défaut sûres si des champs manquent', () {
      final pin = Pin.fromJson({'id': 'x'});
      expect(pin.isCarousel, isFalse);
      expect(pin.aspectRatio, greaterThan(0));
      expect(pin.color, isA<Color>());
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('chaque icône se dessine sans erreur (${brightness.name})', (tester) async {
      await tester.pumpWidget(_wrap(
        Wrap(children: [for (final i in PinIcons.values) PinIcon(i, size: 24)]),
        brightness: brightness,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PinIcon), findsNWidgets(PinIcons.values.length));
    });
  }

  testWidgets('PinButton : désactivé sans action, appelle l’action sinon', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PinButton('Terminé', kind: PinButtonKind.red),
        PinButton('Enregistrer', kind: PinButtonKind.red, onPressed: () => taps++),
      ],
    )));
    await tester.tap(find.text('Terminé'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('PinTextTabs signale l’onglet touché', (tester) async {
    var index = 0;
    await tester.pumpWidget(_wrap(PinTextTabs(
      labels: const ['Créées', 'Enregistrées'],
      index: index,
      onChanged: (i) => index = i,
    )));
    await tester.tap(find.text('Enregistrées'));
    expect(index, 1);
  });
}
