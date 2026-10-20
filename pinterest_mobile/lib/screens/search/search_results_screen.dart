import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import 'search_screen.dart';

/// Résultats d'une recherche par mots-clés, ou par image (Épingles de couleurs proches).
class SearchResultsScreen extends StatefulWidget {
  final String? query;
  final PickedImage? image;

  const SearchResultsScreen({super.key, this.query, this.image}) : assert(query != null || image != null);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _api = ApiService();
  late final _ctrl = TextEditingController(text: widget.query ?? '');
  late String _query = widget.query ?? '';
  List<Pin>? _pins;
  bool _offline = false;

  bool get _visual => widget.image != null && _query.isEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _pins = null;
      _offline = false;
    });
    final pins = _visual ? await _api.searchByColor(widget.image!.dominantColor) : await _api.searchPins(_query);
    if (!mounted) return;
    setState(() {
      _pins = pins ?? [];
      _offline = pins == null;
    });
  }

  void _submit(String q) {
    final t = q.trim();
    if (t.isEmpty || t == _query) return;
    RecentSearches.add(t);
    setState(() => _query = t);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 64,
              titleSpacing: 0,
              backgroundColor: p.bg,
              title: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: _visual
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(widget.image!.bytes, width: 44, height: 44, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Épingles visuellement similaires',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            )
                          : PinSearchBar(controller: _ctrl, onSubmitted: _submit),
                    ),
                  ],
                ),
              ),
            ),
            if (_pins == null)
              const SliverPinSkeleton()
            else if (_offline)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: OfflineState(onRetry: _load)))
            else if (_pins!.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: EmptyState(
                    title: 'Aucun résultat pour « $_query »',
                    message: 'Essayez d’autres mots-clés, par exemple « montagne » ou « café ».',
                  ),
                ),
              )
            else
              SliverPinGrid(
                pins: _pins!,
                heroScope: 'search_${_visual ? 'image' : _query}',
                onRemove: (x) => setState(() => _pins!.remove(x)),
                onRestore: (i, x) => setState(() => _pins!.insert(i.clamp(0, _pins!.length), x)),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
