import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'outils/mesure.dart';
import 'donnees/affichage.dart';
import 'widgets/lentille.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // L application dessine sous les barres du systeme, sur son fond lavande.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  lancerMesure();
  // Le verre liquide se charge pendant l ouverture ; la barre l attend.
  chargerLentille();
  await Affichage.instance.charger();
  runApp(const AppUsw());
}
