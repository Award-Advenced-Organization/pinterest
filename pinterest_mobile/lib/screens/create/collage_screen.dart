import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_card.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

/// Collage : assemble 2 à 4 Épingles enregistrées en une nouvelle Épingle.
class CollageScreen extends StatefulWidget {
  const CollageScreen({super.key});

  @override
  State<CollageScreen> createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  static const _max = 4;
  final _api = ApiService();
  final _title = TextEditingController();
  List<Pin>? _pins;
  final List<Pin> _chosen = [];
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _api.fetchSavedPins().then((p) {
      if (mounted) setState(() => _pins = p ?? []);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _toggle(Pin pin) {
    setState(() {
      if (_chosen.contains(pin)) {
        _chosen.remove(pin);
      } else if (_chosen.length < _max) {
        _chosen.add(pin);
      } else {
        showPinToast(context, 'Un collage contient au maximum $_max images.');
      }
    });
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    final images = _chosen.map((p) => p.imageUrl).toList();
    final r = await _api.createPin(
      title: _title.text.trim().isEmpty ? 'Collage' : _title.text.trim(),
      description: '',
      imageUrl: images.first,
      collageImages: images,
      width: 750,
      height: images.length == 2 ? 560 : 1000,
      dominantColor: _chosen.first.dominantColor,
    );
    if (!mounted) return;
    setState(() => _publishing = false);
    if (!r.ok) return showPinToast(context, r.error!);
    AppState.dataChanged();
    Navigator.pop(context);
    showPinToast(context, 'Collage publié sur votre profil', imageUrl: images.first);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final ready = _chosen.length >= 2;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.close, tooltip: 'Fermer', onPressed: () => Navigator.pop(context)),
        title: const Text('Créer un collage'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child:
                PinButton('Publier', kind: PinButtonKind.red, loading: _publishing, onPressed: ready ? _publish : null),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: AspectRatio(
                      aspectRatio: _chosen.length == 2 ? 750 / 560 : 0.75,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(GestaltTheme.cardRadius),
                        child: ready
                            ? CollageView(images: _chosen.map((x) => x.imageUrl).toList(), color: _chosen.first.color)
                            : Container(
                                color: p.secondaryButton,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  'Choisissez de 2 à $_max Épingles ci-dessous',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PinField(
                      label: 'Titre',
                      labelInside: false,
                      controller: _title,
                      hint: 'Donnez un nom à votre collage',
                      maxLength: 100),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Vos Épingles enregistrées · ${_chosen.length}/$_max',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_pins == null)
            const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)))
          else if (_pins!.isEmpty)
            const SliverToBoxAdapter(
                child: EmptyState(
                    title: 'Aucune Épingle enregistrée', message: 'Enregistrez des Épingles pour créer un collage.'))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childCount: _pins!.length,
                itemBuilder: (_, i) {
                  final pin = _pins![i];
                  final order = _chosen.indexOf(pin);
                  return Pressable(
                    onTap: () => _toggle(pin),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: pin.aspectRatio.clamp(0.5, 1.8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PinNetImage(pin.imageUrl, placeholder: pin.color),
                            if (order >= 0) const ColoredBox(color: Color(0x55000000)),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: order >= 0 ? GestaltTheme.pinterestRed : const Color(0x99FFFFFF),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: order >= 0
                                    ? Text('${order + 1}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
