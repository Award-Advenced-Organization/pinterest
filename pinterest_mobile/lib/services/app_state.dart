import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_service.dart';

/// État partagé entre les onglets.
class AppState {
  AppState._();

  /// Profil de la personne connectée (avatar de la barre du bas, profil, commentaires…).
  static final user = ValueNotifier<UserProfile?>(null);

  /// Apparence choisie dans le profil : système, clair ou sombre.
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Incrémenté quand des Épingles ou des tableaux changent, pour que les autres écrans se rechargent.
  static final dataVersion = ValueNotifier<int>(0);

  static void dataChanged() => dataVersion.value++;

  /// Incrémenté quand on touche « Accueil » alors qu'on y est déjà : retour en haut du fil.
  static final homeReselected = ValueNotifier<int>(0);

  static Future<void> loadUser() async {
    final u = await ApiService().fetchUserProfile('me');
    if (u != null) setUser(u);
  }

  static void setUser(UserProfile u) {
    user.value = u;
    themeMode.value = switch (u.appearance) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
