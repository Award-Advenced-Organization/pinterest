// Les envois en cours (E16, E26) : une publication part en deux temps (WebP
// 2 160 px, puis l original), par morceaux, et reprend la ou elle s etait
// arretee si le reseau tombe. Ici simule ; le lot 3 branchera l envoi par
// morceaux (tus) vers l API, puis Cloudflare R2.
import 'dart:async';

import 'package:flutter/foundation.dart';

enum EtatEnvoi { encours, pause, verification, publie, refuse }

class Envoi {
  Envoi({required this.titre, required this.photo, required this.poidsMo, this.etat = EtatEnvoi.encours, this.avance = 0, this.detail});

  final String titre;
  final String photo;
  final double poidsMo;
  EtatEnvoi etat;

  /// De 0 a 1.
  double avance;
  String? detail;
}

class Envois extends ChangeNotifier {
  Envois._();
  static final instance = Envois._();

  final liste = <Envoi>[
    Envoi(titre: 'Cascade de Kota, reel 0:28', photo: 'p15', poidsMo: 31, etat: EtatEnvoi.pause, avance: 0.22, detail: 'reprendra en Wi-Fi'),
    Envoi(titre: 'Ponton de Ouidah', photo: 'p77', poidsMo: 6, etat: EtatEnvoi.verification, avance: 1),
    Envoi(titre: 'Plage de Grand-Popo', photo: 'p108', poidsMo: 5, etat: EtatEnvoi.publie, avance: 1, detail: 'Publiée hier, Capture vérifiée'),
    Envoi(titre: 'Rues de Porto-Novo', photo: 'p57', poidsMo: 4, etat: EtatEnvoi.refuse, avance: 1, detail: 'Refusée : image générée par IA'),
  ];

  Timer? _minuterie;

  /// L envoi qui avance en ce moment (la pastille au-dessus des onglets).
  Envoi? get courant => liste.where((e) => e.etat == EtatEnvoi.encours).firstOrNull;

  void publier({required String titre, required String photo, required double poidsMo}) {
    liste.insert(0, Envoi(titre: titre, photo: photo, poidsMo: poidsMo));
    _avancer();
    notifyListeners();
  }

  void basculer(Envoi e) {
    e.etat = e.etat == EtatEnvoi.pause ? EtatEnvoi.encours : EtatEnvoi.pause;
    _avancer();
    notifyListeners();
  }

  void annuler(Envoi e) {
    liste.remove(e);
    notifyListeners();
  }

  // Le reseau de demonstration : 3G, environ 1 % toutes les 120 ms.
  void _avancer() {
    _minuterie ??= Timer.periodic(const Duration(milliseconds: 120), (_) {
      final e = courant;
      if (e == null) {
        _minuterie?.cancel();
        _minuterie = null;
        return;
      }
      e.avance = (e.avance + 0.01).clamp(0.0, 1.0);
      if (e.avance >= 1) {
        e.etat = EtatEnvoi.verification;
        Timer(const Duration(seconds: 3), () {
          e
            ..etat = EtatEnvoi.publie
            ..detail = 'Publiée à l’instant, Capture vérifiée';
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }

  @visibleForTesting
  void arreter() {
    _minuterie?.cancel();
    _minuterie = null;
  }
}
