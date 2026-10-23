// L affichage, choisi dans les reglages et garde d un lancement a l autre :
// le theme (celui du telephone par defaut, ou clair, ou sombre), la police
// (Wura Mi, ou celle du telephone) et les animations (toutes par defaut ;
// on peut les reduire).
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ModeTheme { systeme, clair, sombre }

class Affichage extends ChangeNotifier {
  Affichage._();
  static final instance = Affichage._();

  ModeTheme mode = ModeTheme.systeme;

  /// Par defaut, la police du telephone, meme changee dans ses themes (sur
  /// HiOS, la police systeme est un lien vers celle du theme choisi).
  bool policeDuTelephone = true;
  bool reduireAnimations = false;

  Future<void> charger() async {
    try {
      final p = await SharedPreferences.getInstance();
      mode = ModeTheme.values.asNameMap()[p.getString('theme')] ?? ModeTheme.systeme;
      policeDuTelephone = p.getBool('police_du_telephone') ?? true;
      reduireAnimations = p.getBool('reduire_animations') ?? false;
    } catch (_) {
      // Sans stockage (les tests) : les reglages par defaut.
    }
  }

  void choisirTheme(ModeTheme m) {
    mode = m;
    notifyListeners();
    _garder((p) => p.setString('theme', m.name));
  }

  void choisirPolice({required bool duTelephone}) {
    policeDuTelephone = duTelephone;
    notifyListeners();
    _garder((p) => p.setBool('police_du_telephone', duTelephone));
  }

  void choisirAnimations({required bool reduire}) {
    reduireAnimations = reduire;
    notifyListeners();
    _garder((p) => p.setBool('reduire_animations', reduire));
  }

  Future<void> _garder(Future<bool> Function(SharedPreferences) ecrire) async {
    try {
      await ecrire(await SharedPreferences.getInstance());
    } catch (_) {}
  }
}
