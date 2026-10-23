import 'package:flutter/foundation.dart';

import 'demo.dart';

/// La session du membre. Pour l instant en memoire, avec le compte de
/// demonstration ; le lot 1 la branchera sur l API (jeton Sanctum garde dans
/// un stockage securise).
class Session extends ChangeNotifier {
  Session._();
  static final instance = Session._();

  String email = '';
  String nomAffiche = '';
  String nomUtilisateur = '';
  String pays = 'Bénin';
  String ville = 'Cotonou';
  bool position = true;
  final Set<String> interets = {};
  bool connecte = false;

  /// Le parcours de Pinterest : l e-mail d abord, puis mot de passe ou creation.
  bool compteExiste(String adresse) => adresse.trim().toLowerCase() == emailDemo;

  void entrer(String adresse) {
    email = adresse.trim();
    final local = email.split('@').first;
    nomUtilisateur = local.replaceAll(RegExp(r'[^a-z0-9._]'), '');
    nomAffiche = nomAffiche.isEmpty ? _nomDepuis(local) : nomAffiche;
    notifyListeners();
  }

  void connecter() {
    connecte = true;
    notifyListeners();
  }

  void deconnecter() {
    connecte = false;
    email = '';
    nomAffiche = '';
    interets.clear();
    notifyListeners();
  }

  String get initiales {
    final mots = nomAffiche.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return 'U';
    return mots.take(2).map((m) => m[0].toUpperCase()).join();
  }

  static String _nomDepuis(String local) {
    final mots = local.split(RegExp(r'[._-]+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '';
    final premier = mots.first[0].toUpperCase() + mots.first.substring(1);
    return mots.length > 1 ? '$premier ${mots[1][0].toUpperCase()}.' : premier;
  }
}
