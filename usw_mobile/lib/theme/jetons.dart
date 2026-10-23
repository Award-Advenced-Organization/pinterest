// Les jetons de USW, repris de la maquette (maquette/styles/tokens.css) et de
// la charte du mouvement (MOUVEMENT.md). Un role par couleur : l ocean pour ce
// qui se touche et l etape en cours, la limonade pour ce qui est sur, fait,
// valide.
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

Color _hsl(double h, double s, double l, [double a = 1]) => HSLColor.fromAHSL(a, h, s / 100, l / 100).toColor();

/// Les couleurs de USW, en clair et en sombre. `sombre` suit le theme choisi
/// (celui du telephone par defaut) ; l application se redessine quand il change.
abstract final class Couleurs {
  static bool sombre = false;

  static Color _c(Color clair, Color nuit) => sombre ? nuit : clair;

  static final _fond = _hsl(229, 36, 92), _fondNuit = _hsl(229, 18, 7);
  static final _texte = _hsl(0, 0, 7), _texteNuit = _hsl(0, 0, 95);
  static final _discret = _hsl(215, 16, 47), _discretNuit = _hsl(225, 7, 64);
  static final _surfaceNuit = _hsl(229, 14, 15);
  static final _encreNuit = _hsl(229, 18, 8);
  static final _secondaire = _hsl(240, 10, 96), _secondaireNuit = _hsl(229, 12, 18);
  static final _bord = _hsl(240, 6, 90), _bordNuit = _hsl(229, 10, 24);
  static final _ocean = _hsl(229, 97, 55), _oceanNuit = _hsl(229, 97, 62);
  static final _erreur = _hsl(0, 84, 60), _erreurNuit = _hsl(0, 84, 64);
  static final _succes = _hsl(140, 55, 40), _succesNuit = _hsl(140, 50, 52);
  static final _voile = _hsl(229, 30, 30, 0.14), _voileNuit = _hsl(229, 20, 90, 0.12);
  static final _photoVide = _hsl(229, 25, 84), _photoVideNuit = _hsl(229, 14, 20);
  static final _ombre = _hsl(229, 50, 20, 0.36), _ombreNuit = _hsl(229, 50, 2, 0.6);
  static final _filet = _hsl(229, 30, 30, 0.09), _filetNuit = _hsl(229, 20, 85, 0.1);
  static final _trait = _hsl(229, 20, 40, 0.28), _traitNuit = _hsl(229, 15, 80, 0.3);

  static Color get fond => _c(_fond, _fondNuit);
  static Color get texte => _c(_texte, _texteNuit);
  static Color get discret => _c(_discret, _discretNuit);

  /// Le support plein des plaques, tuiles et feuilles : blanc le jour.
  static Color get surface => _c(const Color(0xFFFFFFFF), _surfaceNuit);

  /// Ce qui s ecrit sur un fond a l encre (pastille choisie, numero).
  static Color get surEncre => _c(const Color(0xFFFFFFFF), _encreNuit);
  static Color get carte => surface;
  static Color get secondaire => _c(_secondaire, _secondaireNuit);
  static Color get bord => _c(_bord, _bordNuit);
  static Color get ocean => _c(_ocean, _oceanNuit);
  static final limonade = _hsl(71, 88, 56);
  static final encreLimonade = _hsl(71, 60, 14);
  static Color get erreur => _c(_erreur, _erreurNuit);
  static Color get succes => _c(_succes, _succesNuit);
  static Color get voile => _c(_voile, _voileNuit);
  static Color get photoVide => _c(_photoVide, _photoVideNuit);
  static Color get ombre => _c(_ombre, _ombreNuit);

  /// Les separateurs des listes.
  static Color get filet => _c(_filet, _filetNuit);

  /// Les traits discrets : poignee, rond a cocher vide, interrupteur eteint.
  static Color get trait => _c(_trait, _traitNuit);
  static final ombreOcean = _hsl(229, 97, 45, 0.65);
  static final oceanClair = _hsl(229, 97, 60, 0.8);
  static final oceanFonce = _hsl(229, 97, 52, 0.84);

  static Color hsl(double h, double s, double l, [double a = 1]) => _hsl(h, s, l, a);
}

// Les courbes de MOUVEMENT.md, section 1.
abstract final class Courbes {
  /// Toute entree de texte, toute arrivee d ecran.
  static const signature = Cubic(0.35, 0, 0, 1);

  /// Survols, appuis, menus, boutons, onglets.
  static const interface = Cubic(0.4, 0, 0.1, 1);

  /// L appui sur le verre, une coche, un coeur.
  static const ressort = Cubic(0.34, 1.56, 0.64, 1);

  /// Les piles de photos qui tournent.
  static const souple = Cubic(0.16, 1, 0.3, 1);
  static const pile = Cubic(0.22, 1, 0.36, 1);
}

abstract final class Durees {
  static const appui = Duration(milliseconds: 120);
  static const relache = Duration(milliseconds: 500);
  static const interface = Duration(milliseconds: 300);
  static const entree = Duration(milliseconds: 900);
  static const ecran = Duration(milliseconds: 650);
}

abstract final class Mesures {
  static const marge = 16.0;
  static const margeTablette = 28.0;
  static const rayonBouton = 14.0;
  static const rayonCarte = 18.0;
  static const hautOnglets = 64.0;

  /// La marge de page : plus large sur une tablette.
  static double margeDe(double largeur) => largeur >= 600 ? margeTablette : marge;
}
