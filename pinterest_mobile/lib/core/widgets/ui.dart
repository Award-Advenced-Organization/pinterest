import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/api_endpoints.dart';
import '../theme/gestalt_theme.dart';
import 'pin_icon.dart';

/// Rétrécit légèrement ce qu'on touche, comme les cartes et boutons de Pinterest.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressEndCallback? onLongPressEnd;
  final double pressedScale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.pressedScale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPressStart != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onTap,
      onLongPressStart: widget.onLongPressStart == null
          ? null
          : (d) {
              _set(false);
              widget.onLongPressStart!(d);
            },
      onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
      onLongPressEnd: widget.onLongPressEnd,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

enum PinButtonKind { red, grey, dark, transparent }

class PinButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PinButtonKind kind;
  final bool large;
  final bool loading;
  final bool expand;
  final Widget? leading;

  const PinButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = PinButtonKind.grey,
    this.large = false,
    this.loading = false,
    this.expand = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final disabled = onPressed == null;
    final (bg, fg) = disabled
        ? (p.secondaryButton, p.textMuted)
        : switch (kind) {
            PinButtonKind.red => (GestaltTheme.pinterestRed, Colors.white),
            PinButtonKind.grey => (p.secondaryButton, p.text),
            PinButtonKind.dark => (p.text, p.bg),
            PinButtonKind.transparent => (Colors.transparent, p.text),
          };
    final content = loading
        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: fg, fontSize: large ? 16 : 14, fontWeight: FontWeight.w600, height: 1.15),
                ),
              ),
            ],
          );
    return Pressable(
      onTap: loading ? null : onPressed,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(minHeight: large ? 48 : 40, minWidth: expand ? double.infinity : 0),
        padding: EdgeInsets.symmetric(horizontal: large ? 20 : 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(large ? 16 : 12)),
        alignment: expand ? Alignment.center : null,
        child: expand ? content : Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    );
  }
}

/// Bouton rond contenant une icône (barres du haut, actions d'une Épingle).
class PinIconButton extends StatelessWidget {
  final PinIcons icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? background;
  final String? tooltip;

  const PinIconButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.size = 44,
    this.iconSize = 24,
    this.color,
    this.background,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Pressable(
      onTap: onPressed,
      pressedScale: 0.9,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: background == null ? null : BoxDecoration(color: background, shape: BoxShape.circle),
        child: PinIcon(icon, size: iconSize, color: color, background: background),
      ),
    );
    return tooltip == null ? btn : Semantics(button: true, label: tooltip, child: btn);
  }
}

class PinNetImage extends StatelessWidget {
  final String url;
  final Color? placeholder;
  final BoxFit fit;
  final double? width;
  final double? height;

  const PinNetImage(this.url, {super.key, this.placeholder, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final color = placeholder ?? context.pal.skeleton;
    if (url.isEmpty) return Container(width: width, height: height, color: color);
    return CachedNetworkImage(
      imageUrl: ApiEndpoints.resolveUrl(url),
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => Container(color: color),
      errorWidget: (_, __, ___) => Container(
        color: color,
        alignment: Alignment.center,
        child: PinIcon(PinIcons.image, size: 22, color: context.pal.textMuted),
      ),
    );
  }
}

class PinAvatar extends StatelessWidget {
  final String url;
  final String name;
  final double size;
  final Color? background;

  const PinAvatar({super.key, required this.url, required this.name, this.size = 48, this.background});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background ?? p.avatarLavender, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first.toUpperCase() : '',
        style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w500, color: p.text),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: ApiEndpoints.resolveUrl(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

/// Bandeau sombre en bas de l'écran (« Enregistrée dans votre profil · Modifier »).
void showPinToast(
  BuildContext context,
  String message, {
  String? imageUrl,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final p = context.pal;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.toast,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          if (imageUrl != null) ...[
            ClipRRect(borderRadius: BorderRadius.circular(8), child: PinNetImage(imageUrl, width: 36, height: 36)),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 6),
          Expanded(
            child:
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: () {
                messenger.hideCurrentSnackBar();
                onAction?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
        ],
      ),
    ),
  );
}

/// Feuille du bas avec une croix à gauche et un titre centré.
Future<T?> showPinSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  bool fullHeight = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Row(
              children: [
                PinIconButton(PinIcons.close, onPressed: () => Navigator.pop(ctx), tooltip: 'Fermer'),
                Expanded(
                  child: Text(
                    title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          if (fullHeight) Expanded(child: builder(ctx)) else Flexible(child: builder(ctx)),
        ],
      );
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: fullHeight ? SizedBox(height: MediaQuery.of(ctx).size.height * 0.9, child: body) : body,
      );
    },
  );
}

/// Fenêtre de confirmation (« Supprimer ce tableau ? »).
Future<bool> confirmPin(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title:
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      content:
          Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: ctx.pal.text, height: 1.4)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        PinButton('Annuler', large: true, onPressed: () => Navigator.pop(ctx, false)),
        PinButton(confirmLabel, large: true, kind: PinButtonKind.red, onPressed: () => Navigator.pop(ctx, true)),
      ],
    ),
  );
  return ok ?? false;
}

/// Ligne d'une feuille d'options (texte en gras, comme dans les menus Pinterest).
class SheetOption extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const SheetOption(this.label, {super.key, required this.onTap, this.subtitle, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: destructive ? GestaltTheme.pinterestRed : context.pal.text,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(fontSize: 13, color: context.pal.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Champ de saisie entouré, libellé à l'intérieur du cadre (écran « Modifier le profil »)
/// ou au-dessus (création d'Épingle et de tableau).
class PinField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool labelInside;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String? errorText;

  const PinField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.labelInside = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final borderColor = errorText != null ? GestaltTheme.pinterestRed : p.border;
    final input = TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autofocus: autofocus,
      style: TextStyle(fontSize: 16, color: p.text),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(color: p.placeholder, fontSize: 16),
        contentPadding: EdgeInsets.zero,
      ),
    );
    final box = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: labelInside ? 12 : 14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: errorText != null ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: labelInside
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.text)),
                const SizedBox(height: 6),
                input,
              ],
            )
          : input,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!labelInside) ...[
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.text)),
          const SizedBox(height: 8),
        ],
        box,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: const TextStyle(color: GestaltTheme.pinterestRed, fontSize: 13)),
        ],
      ],
    );
  }
}

/// Barre de recherche entourée (page Rechercher, « Rechercher dans vos Épingles »).
class PinSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final FocusNode? focusNode;
  final bool autofocus;
  final double height;

  const PinSearchBar({
    super.key,
    this.controller,
    this.hint = 'Rechercher',
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          PinIcon(PinIcons.search, size: 20, color: p.text),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              readOnly: onTap != null,
              onTap: onTap,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 16, color: p.text, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: p.placeholder, fontSize: 16, fontWeight: FontWeight.w500),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Onglets texte soulignés (« Créées / Enregistrées », « Statistiques / Audience », tableaux de l'accueil).
class PinTextTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool scrollable;
  final double fontSize;

  const PinTextTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.scrollable = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final tabs = [
      for (var i = 0; i < labels.length; i++)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: p.text),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i == index ? p.text : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: tabs),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: tabs);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader(this.title, {super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          if (onSeeAll != null)
            Pressable(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text('Tout voir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: p.text)),
                    const SizedBox(width: 6),
                    PinIcon(PinIcons.chevronRight, size: 18, color: p.text),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.title, this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: context.pal.textMuted, height: 1.4)),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            PinButton(actionLabel!, kind: PinButtonKind.red, large: true, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Message affiché quand le serveur ne répond pas, avec un bouton pour réessayer.
class OfflineState extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Connexion impossible',
      message: 'Le serveur ne répond pas. Vérifiez qu’il est démarré, puis réessayez.',
      actionLabel: 'Réessayer',
      onAction: onRetry,
    );
  }
}
