import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Couleurs de l'interface, relevées sur les captures de l'application Pinterest.
/// Chaque écran les lit via `context.pal` pour fonctionner en clair comme en sombre.
@immutable
class PinPalette extends ThemeExtension<PinPalette> {
  final Color bg;
  final Color sheet;
  final Color text;
  final Color textMuted;
  final Color secondaryButton; // gris chaud des boutons « Modifier le profil », « S'abonner »…
  final Color secondaryButtonPressed;
  final Color border; // contour des champs et de la barre de recherche
  final Color divider;
  final Color placeholder;
  final Color skeleton;
  final Color toast;
  final Color avatarMint;
  final Color avatarLavender;
  final Color statsBackdrop; // bande noire entre les cartes des statistiques

  const PinPalette({
    required this.bg,
    required this.sheet,
    required this.text,
    required this.textMuted,
    required this.secondaryButton,
    required this.secondaryButtonPressed,
    required this.border,
    required this.divider,
    required this.placeholder,
    required this.skeleton,
    required this.toast,
    required this.avatarMint,
    required this.avatarLavender,
    required this.statsBackdrop,
  });

  static const light = PinPalette(
    bg: Color(0xFFFFFFFF),
    sheet: Color(0xFFFFFFFF),
    text: Color(0xFF111111),
    textMuted: Color(0xFF62625B),
    secondaryButton: Color(0xFFE5E5E0),
    secondaryButtonPressed: Color(0xFFD7D7D2),
    border: Color(0xFF91918C),
    divider: Color(0xFFE5E5E0),
    placeholder: Color(0xFF767676),
    skeleton: Color(0xFFEFEFEC),
    toast: Color(0xFF111111),
    avatarMint: Color(0xFFC7EEDB),
    avatarLavender: Color(0xFFDDE0FD),
    statsBackdrop: Color(0xFF000000),
  );

  static const dark = PinPalette(
    bg: Color(0xFF111111),
    sheet: Color(0xFF1E1E1E),
    text: Color(0xFFF5F5F2),
    textMuted: Color(0xFFABABA6),
    secondaryButton: Color(0xFF33332F),
    secondaryButtonPressed: Color(0xFF45453F),
    border: Color(0xFF6E6E69),
    divider: Color(0xFF2E2E2B),
    placeholder: Color(0xFF8E8E89),
    skeleton: Color(0xFF242422),
    toast: Color(0xFF33332F),
    avatarMint: Color(0xFF2F5A47),
    avatarLavender: Color(0xFF3B3F6B),
    statsBackdrop: Color(0xFF000000),
  );

  @override
  PinPalette copyWith() => this;

  @override
  PinPalette lerp(ThemeExtension<PinPalette>? other, double t) {
    if (other is! PinPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PinPalette(
      bg: l(bg, other.bg),
      sheet: l(sheet, other.sheet),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      secondaryButton: l(secondaryButton, other.secondaryButton),
      secondaryButtonPressed: l(secondaryButtonPressed, other.secondaryButtonPressed),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      placeholder: l(placeholder, other.placeholder),
      skeleton: l(skeleton, other.skeleton),
      toast: l(toast, other.toast),
      avatarMint: l(avatarMint, other.avatarMint),
      avatarLavender: l(avatarLavender, other.avatarLavender),
      statsBackdrop: l(statsBackdrop, other.statsBackdrop),
    );
  }
}

extension PinPaletteContext on BuildContext {
  PinPalette get pal => Theme.of(this).extension<PinPalette>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class GestaltTheme {
  static const Color pinterestRed = Color(0xFFE60023);
  static const Color pinterestRedPressed = Color(0xFFB60000);

  static const double cardRadius = 16.0;
  static const double sheetRadius = 32.0;

  static ThemeData light() => _build(Brightness.light, PinPalette.light);
  static ThemeData dark() => _build(Brightness.dark, PinPalette.dark);

  static ThemeData _build(Brightness brightness, PinPalette p) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final text = GoogleFonts.interTightTextTheme(base.textTheme).apply(
      bodyColor: p.text,
      displayColor: p.text,
    );
    return base.copyWith(
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      primaryColor: pinterestRed,
      colorScheme: (brightness == Brightness.light ? const ColorScheme.light() : const ColorScheme.dark()).copyWith(
        primary: pinterestRed,
        onPrimary: Colors.white,
        secondary: p.text,
        surface: p.bg,
        onSurface: p.text,
        surfaceContainerHighest: p.secondaryButton,
      ),
      textTheme: text,
      extensions: [p],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.text),
        titleTextStyle: GoogleFonts.interTight(fontSize: 17, fontWeight: FontWeight.w600, color: p.text),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.sheet,
        modalBackgroundColor: p.sheet,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.text,
        selectionColor: pinterestRed.withValues(alpha: 0.25),
        selectionHandleColor: pinterestRed,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: pinterestRed),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.text : p.secondaryButtonPressed,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
