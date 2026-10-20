import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/gestalt_theme.dart';
import 'pin_icon.dart';

class RadialAction {
  final PinIcons icon;
  final String label;
  final VoidCallback onSelected;
  const RadialAction(this.icon, this.label, this.onSelected);
}

/// Menu qui s'ouvre en éventail autour du doigt sur un appui long (geste signature de Pinterest).
/// On glisse jusqu'à une action et on relâche ; si on relâche ailleurs, le menu reste ouvert
/// et l'on peut toucher une action ou à côté pour fermer.
class RadialMenu {
  RadialMenu._();

  static OverlayEntry? _entry;
  static final _key = GlobalKey<_RadialOverlayState>();

  static void show(
    BuildContext context, {
    required Offset origin,
    required Rect highlight,
    required double highlightRadius,
    required List<RadialAction> actions,
  }) {
    dismiss();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => _RadialOverlay(
        key: _key,
        origin: origin,
        highlight: highlight,
        highlightRadius: highlightRadius,
        actions: actions,
        onClose: dismiss,
      ),
    );
    overlay.insert(_entry!);
  }

  static void update(Offset position) => _key.currentState?.hover(position);

  static void release() => _key.currentState?.release();

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _RadialOverlay extends StatefulWidget {
  final Offset origin;
  final Rect highlight;
  final double highlightRadius;
  final List<RadialAction> actions;
  final VoidCallback onClose;

  const _RadialOverlay({
    super.key,
    required this.origin,
    required this.highlight,
    required this.highlightRadius,
    required this.actions,
    required this.onClose,
  });

  @override
  State<_RadialOverlay> createState() => _RadialOverlayState();
}

class _RadialOverlayState extends State<_RadialOverlay> with SingleTickerProviderStateMixin {
  static const double _radius = 82;
  static const double _button = 52;

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();
  int? _hovered;
  List<Offset> _centers = const [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Offset> _computeCenters(Size screen) {
    final o = widget.origin;
    final base = math.atan2(screen.height / 2 - o.dy, screen.width / 2 - o.dx);
    const step = 50 * math.pi / 180;
    final n = widget.actions.length;
    return [
      for (var i = 0; i < n; i++)
        () {
          final a = base + (i - (n - 1) / 2) * step;
          final c = o + Offset(math.cos(a), math.sin(a)) * _radius;
          return Offset(
            c.dx.clamp(_button / 2 + 8, screen.width - _button / 2 - 8),
            c.dy.clamp(_button / 2 + 40, screen.height - _button / 2 - 8),
          );
        }(),
    ];
  }

  void hover(Offset p) {
    int? found;
    for (var i = 0; i < _centers.length; i++) {
      if ((p - _centers[i]).distance < _button * 0.75) found = i;
    }
    if (found != _hovered) setState(() => _hovered = found);
  }

  void release() {
    if (_hovered != null) _run(_hovered!);
  }

  void _run(int i) {
    final action = widget.actions[i];
    widget.onClose();
    action.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final screen = MediaQuery.of(context).size;
    _centers = _computeCenters(screen);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(_ctrl.value.clamp(0.0, 1.0));
        final fade = _ctrl.value;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: CustomPaint(
                  painter: _DimPainter(
                    hole: widget.highlight,
                    radius: widget.highlightRadius,
                    color: Colors.black.withValues(alpha: (context.isDark ? 0.6 : 0.45) * fade),
                  ),
                ),
              ),
            ),
            // Cercle à l'endroit du doigt.
            Positioned(
              left: widget.origin.dx - 26,
              top: widget.origin.dy - 26,
              child: IgnorePointer(
                child: Opacity(
                  opacity: fade,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
                    ),
                  ),
                ),
              ),
            ),
            for (var i = 0; i < widget.actions.length; i++)
              _buildAction(i, Offset.lerp(widget.origin, _centers[i], t)!, fade, p),
          ],
        );
      },
    );
  }

  Widget _buildAction(int i, Offset c, double fade, PinPalette p) {
    final hovered = _hovered == i;
    final a = widget.actions[i];
    return Positioned(
      left: c.dx - _button / 2,
      top: c.dy - _button / 2,
      child: Opacity(
        opacity: fade,
        child: GestureDetector(
          onTap: () => _run(i),
          child: AnimatedScale(
            scale: hovered ? 1.18 : 1,
            duration: const Duration(milliseconds: 120),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: _button,
                  height: _button,
                  decoration: BoxDecoration(
                    color: hovered ? GestaltTheme.pinterestRed : p.sheet,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 3))],
                  ),
                  alignment: Alignment.center,
                  child: PinIcon(a.icon, size: 24, color: hovered ? Colors.white : p.text, background: p.sheet),
                ),
                if (hovered)
                  Positioned(
                    bottom: _button + 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: p.sheet, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        a.label,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: p.text, decoration: TextDecoration.none),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Assombrit l'écran en laissant l'Épingle visible.
class _DimPainter extends CustomPainter {
  final Rect hole;
  final double radius;
  final Color color;

  _DimPainter({required this.hole, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(hole, Radius.circular(radius)));
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.color != color || old.hole != hole;
}
