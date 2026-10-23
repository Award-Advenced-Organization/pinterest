import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../donnees/affichage.dart';

import 'jetons.dart';

abstract final class Textes {
  static TextStyle get titre => TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.9, height: 1.08, color: Couleurs.texte);
  static TextStyle get sousTitre => TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.15, color: Couleurs.texte);
  static TextStyle get corps => TextStyle(fontSize: 15, height: 1.4, color: Couleurs.texte);
  static TextStyle get discret => TextStyle(fontSize: 15.5, height: 1.45, color: Couleurs.discret);
  static TextStyle get petit => TextStyle(fontSize: 13, height: 1.45, color: Couleurs.discret);
  static TextStyle get libelle => TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Couleurs.texte);
  static TextStyle get bouton => const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, height: 1);
  static TextStyle get lien => TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Couleurs.ocean);
}

/// La famille a donner aux styles qui ne l heritent pas du theme : Wura Mi,
/// ou rien (la police du telephone, choisie dans les reglages).
String? get famillePolice => Affichage.instance.policeDuTelephone ? null : 'WuraMi';

ThemeData themeUsw() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: famillePolice,
    scaffoldBackgroundColor: Couleurs.fond,
    brightness: Couleurs.sombre ? Brightness.dark : Brightness.light,
    colorScheme: (Couleurs.sombre ? ColorScheme.dark : ColorScheme.light)(
      primary: Couleurs.ocean,
      secondary: Couleurs.limonade,
      surface: Couleurs.fond,
      error: Couleurs.erreur,
      onSurface: Couleurs.texte,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: Couleurs.texte, displayColor: Couleurs.texte, fontFamily: famillePolice),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Couleurs.ocean,
      selectionColor: Couleurs.ocean.withValues(alpha: 0.2),
      selectionHandleColor: Couleurs.ocean,
    ),
    appBarTheme: AppBarTheme(systemOverlayStyle: barreDuTheme),
    // L interrupteur : ocean allume, verre clair eteint, sans bordure noire.
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected) ? Couleurs.ocean : Couleurs.trait),
    ),
    // Partout le glissement d iOS : une page arrive par la droite, et au
    // retour elle repart a droite pendant que la precedente revient de la
    // gauche, la ou elle en etait. On peut aussi revenir en glissant le doigt
    // depuis le bord gauche : la page suit le doigt.
    // Animations reduites (reglages) : un simple fondu.
    pageTransitionsTheme: Affichage.instance.reduireAnimations
        ? const PageTransitionsTheme(builders: {TargetPlatform.android: _Fondu(), TargetPlatform.iOS: _Fondu()})
        : const PageTransitionsTheme(
            builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
          ),
  );
}

/// Les icones de la barre d etat, a l encre, sur le fond clair de USW.
const barreClaire = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Color(0x00000000),
  systemNavigationBarIconBrightness: Brightness.dark,
);

class _Fondu extends PageTransitionsBuilder {
  const _Fondu();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(opacity: animation, child: child);
}

/// La barre d etat du theme : a l encre le jour, en blanc la nuit.
SystemUiOverlayStyle get barreDuTheme => Couleurs.sombre ? barreSombre : barreClaire;

/// Les memes, en blanc, sur les reels, les photos plein ecran, et la nuit.
const barreSombre = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0x00000000),
  systemNavigationBarIconBrightness: Brightness.light,
);
