import 'package:flutter/material.dart';
import '../../models/pin.dart';
import '../../screens/pin_detail/pin_detail_screen.dart';
import '../theme/gestalt_theme.dart';
import 'pin_actions.dart';
import 'pin_icon.dart';
import 'radial_menu.dart';
import 'ui.dart';

class PinCard extends StatefulWidget {
  final Pin pin;

  /// Distingue les grilles présentes en même temps (accueil, profil…) pour l'animation d'ouverture.
  final String heroScope;

  /// Retire la carte de sa grille (Épingle masquée ou signalée).
  final VoidCallback? onHidden;
  final VoidCallback? onRestored;
  final VoidCallback? onChanged;

  /// Mode sélection (« Organiser ») : toucher la carte la coche au lieu de l'ouvrir.
  final bool? selected;
  final VoidCallback? onSelect;

  const PinCard({
    super.key,
    required this.pin,
    required this.heroScope,
    this.onHidden,
    this.onRestored,
    this.onChanged,
    this.selected,
    this.onSelect,
  });

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  final _mediaKey = GlobalKey();
  int _page = 0;

  Pin get pin => widget.pin;
  bool get _selecting => widget.onSelect != null;

  void _changed() {
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  void _open() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PinDetailScreen(pin: pin, heroTag: _heroTag)),
    ).then((_) => _changed());
  }

  String get _heroTag => '${widget.heroScope}_${pin.id}';

  void _openRadial(LongPressStartDetails d) {
    final box = _mediaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    RadialMenu.show(
      context,
      origin: d.globalPosition,
      highlight: rect,
      highlightRadius: GestaltTheme.cardRadius,
      actions: [
        pin.isSaved
            ? RadialAction(PinIcons.pin, 'Retirer', () => PinActions.unsave(context, pin, onChanged: _changed))
            : RadialAction(PinIcons.pin, 'Enregistrer', () => PinActions.quickSave(context, pin, onChanged: _changed)),
        RadialAction(PinIcons.share, 'Partager', () => PinActions.share(context, pin)),
        if (widget.onHidden != null)
          RadialAction(
            PinIcons.eyeOff,
            'Masquer',
            () => PinActions.hide(context, pin, onHidden: widget.onHidden!, onRestored: widget.onRestored),
          )
        else
          RadialAction(PinIcons.ellipsis, 'Options', _showOptions),
      ],
    );
  }

  void _showOptions() {
    PinActions.showOptions(
      context,
      pin,
      onChanged: _changed,
      onHidden: widget.onHidden,
      onRestored: widget.onRestored,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final ratio = pin.aspectRatio.clamp(0.5, 1.8);
    final selected = widget.selected ?? false;

    Widget media;
    if (pin.isCollage) {
      media = CollageView(images: pin.collageImages, color: pin.color);
    } else if (pin.isCarousel) {
      media = PageView.builder(
        itemCount: pin.images.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) => PinNetImage(pin.images[i], placeholder: pin.color),
      );
    } else {
      media = PinNetImage(pin.imageUrl, placeholder: pin.color);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onTap: _selecting ? widget.onSelect : _open,
          onLongPressStart: _selecting ? null : _openRadial,
          onLongPressMoveUpdate: _selecting ? null : (d) => RadialMenu.update(d.globalPosition),
          onLongPressEnd: _selecting ? null : (_) => RadialMenu.release(),
          child: ClipRRect(
            key: _mediaKey,
            borderRadius: BorderRadius.circular(GestaltTheme.cardRadius),
            child: AspectRatio(
              aspectRatio: ratio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: _heroTag,
                    // Pendant l'animation, on montre l'image affichée (et non un carrousel remis à zéro).
                    flightShuttleBuilder: (_, __, ___, ____, _____) => PinNetImage(
                      pin.isCarousel ? pin.images[_page] : pin.imageUrl,
                      placeholder: pin.color,
                    ),
                    child: media,
                  ),
                  if (_selecting) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      color: selected ? const Color(0x66000000) : Colors.transparent,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? GestaltTheme.pinterestRed : const Color(0x99FFFFFF),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: selected
                            ? const PinIcon(PinIcons.check, size: 15, color: Colors.white, strokeWidth: 3)
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (pin.isCarousel) _CarouselDots(count: pin.images.length, index: _page, color: p.text, inactive: p.border),
        if (!_selecting)
          Align(
            alignment: Alignment.centerRight,
            child: PinIconButton(
              PinIcons.ellipsis,
              size: 30,
              iconSize: 18,
              onPressed: _showOptions,
              tooltip: 'Plus d’options',
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }
}

/// Points du carrousel : le point actif est foncé, les points éloignés rapetissent.
class _CarouselDots extends StatelessWidget {
  final int count;
  final int index;
  final Color color;
  final Color inactive;

  const _CarouselDots({required this.count, required this.index, required this.color, required this.inactive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: (i - index).abs() >= 3 ? 4 : 6,
              height: (i - index).abs() >= 3 ? 4 : 6,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: i == index ? color : inactive.withValues(alpha: 0.6)),
            ),
        ],
      ),
    );
  }
}

/// Collage : images juxtaposées séparées par un filet.
class CollageView extends StatelessWidget {
  final List<String> images;
  final Color color;

  const CollageView({super.key, required this.images, required this.color});

  @override
  Widget build(BuildContext context) {
    Widget img(String u) => PinNetImage(u, placeholder: color);
    const gap = SizedBox(width: 2, height: 2);
    if (images.length == 2) {
      return Row(children: [Expanded(child: img(images[0])), gap, Expanded(child: img(images[1]))]);
    }
    if (images.length == 3) {
      return Row(
        children: [
          Expanded(child: img(images[0])),
          gap,
          Expanded(child: Column(children: [Expanded(child: img(images[1])), gap, Expanded(child: img(images[2]))])),
        ],
      );
    }
    return Column(
      children: [
        Expanded(child: Row(children: [Expanded(child: img(images[0])), gap, Expanded(child: img(images[1]))])),
        gap,
        Expanded(child: Row(children: [Expanded(child: img(images[2])), gap, Expanded(child: img(images[3]))])),
      ],
    );
  }
}
