import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/pin.dart';
import '../theme/gestalt_theme.dart';
import 'pin_card.dart';

int pinColumns(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w < 600 ? 2 : (w / 220).floor().clamp(3, 6);
}

/// Grille en mosaïque des Épingles (version « sliver » pour les listes défilantes).
class SliverPinGrid extends StatelessWidget {
  final List<Pin> pins;
  final String heroScope;

  /// Appelé quand une Épingle doit disparaître de la grille (masquée, signalée).
  final void Function(Pin pin)? onRemove;
  final void Function(int index, Pin pin)? onRestore;
  final VoidCallback? onChanged;
  final Set<String>? selectedIds;
  final void Function(Pin pin)? onSelect;

  const SliverPinGrid({
    super.key,
    required this.pins,
    required this.heroScope,
    this.onRemove,
    this.onRestore,
    this.onChanged,
    this.selectedIds,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: pinColumns(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 2,
        childCount: pins.length,
        itemBuilder: (context, i) {
          final pin = pins[i];
          return PinCard(
            key: ValueKey('${heroScope}_${pin.id}'),
            pin: pin,
            heroScope: heroScope,
            onChanged: onChanged,
            onHidden: onRemove == null ? null : () => onRemove!(pin),
            onRestored: onRestore == null ? null : () => onRestore!(i, pin),
            selected: selectedIds?.contains(pin.id),
            onSelect: onSelect == null ? null : () => onSelect!(pin),
          );
        },
      ),
    );
  }
}

/// Emplacements gris affichés pendant le premier chargement.
class SliverPinSkeleton extends StatelessWidget {
  final int count;
  const SliverPinSkeleton({super.key, this.count = 10});

  static const _heights = [1.45, 1.05, 1.3, 1.6, 0.95, 1.25, 1.5, 1.1, 1.35, 1.2];

  @override
  Widget build(BuildContext context) {
    final color = context.pal.skeleton;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: pinColumns(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 32,
        childCount: count,
        itemBuilder: (_, i) => AspectRatio(
          aspectRatio: 1 / _heights[i % _heights.length],
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(GestaltTheme.cardRadius)),
          ),
        ),
      ),
    );
  }
}
