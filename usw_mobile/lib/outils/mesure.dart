// La mesure de fluidite, sur le vrai telephone. Allumee seulement par
//   flutter run --profile --dart-define=MESURE=true
// elle ecrit toutes les 5 s dans le journal (adb logcat -s flutter) le temps
// de construction et de dessin des images, et le nombre d images en retard.
// Eteinte (par defaut), elle ne coute rien : le compilateur la retire.
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

const mesureActive = bool.fromEnvironment('MESURE');

void lancerMesure() {
  if (!mesureActive) return;
  final images = <FrameTiming>[];
  var debut = DateTime.now();
  SchedulerBinding.instance.addTimingsCallback((lot) {
    images.addAll(lot);
    final maintenant = DateTime.now();
    if (maintenant.difference(debut) < const Duration(seconds: 5) || images.isEmpty) return;
    // Le budget d une image : 1 / frequence de l ecran (90 ou 120 Hz sur
    // les telephones recents, 60 sur les anciens).
    final hz = PlatformDispatcher.instance.views.first.display.refreshRate;
    final budget = 1000 / hz;
    double ms(Duration d) => d.inMicroseconds / 1000;
    final construction = images.map((f) => ms(f.buildDuration)).toList();
    final dessin = images.map((f) => ms(f.rasterDuration)).toList();
    final retard = images.where((f) => ms(f.buildDuration) > budget || ms(f.rasterDuration) > budget).length;
    double moyenne(List<double> l) => l.reduce((a, b) => a + b) / l.length;
    debugPrint(
      'MESURE ${images.length} images a ${hz.round()} Hz '
      '| construction ${moyenne(construction).toStringAsFixed(1)} ms (pire ${construction.reduce(math.max).toStringAsFixed(1)}) '
      '| dessin ${moyenne(dessin).toStringAsFixed(1)} ms (pire ${dessin.reduce(math.max).toStringAsFixed(1)}) '
      '| en retard $retard (${(100 * retard / images.length).toStringAsFixed(0)} %)',
    );
    images.clear();
    debut = maintenant;
  });
}
