import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/notification_item.dart';
import '../../services/api_service.dart';
import '../../services/image_picking.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  List<SearchIdea> _ideas = [];
  List<SearchIdea> _popular = [];
  bool _loading = true;
  bool _offline = false;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _typing = _focus.hasFocus));
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _offline = false;
    });
    final r = await _api.fetchSearchIdeas();
    if (!mounted) return;
    setState(() {
      _ideas = r?.ideas ?? [];
      _popular = r?.popular ?? [];
      _offline = r == null;
      _loading = false;
    });
  }

  void _search(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    RecentSearches.add(q);
    _focus.unfocus();
    _ctrl.clear();
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(query: q)));
  }

  Future<void> _searchByImage() async {
    final image = await pickImage();
    if (image == null || !mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(image: image)));
  }

  void _cancel() {
    _ctrl.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: PinSearchBar(
                      controller: _ctrl,
                      focusNode: _focus,
                      height: 52,
                      onSubmitted: _search,
                      onChanged: (_) => setState(() {}),
                      trailing: _typing && _ctrl.text.isNotEmpty
                          ? PinIconButton(PinIcons.close,
                              iconSize: 18, tooltip: 'Effacer', onPressed: () => setState(_ctrl.clear))
                          : PinIconButton(PinIcons.camera,
                              iconSize: 24, tooltip: 'Rechercher par image', onPressed: _searchByImage),
                    ),
                  ),
                  if (_typing)
                    TextButton(
                      onPressed: _cancel,
                      style: TextButton.styleFrom(foregroundColor: p.text),
                      child: const Text('Annuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
            Expanded(child: _typing ? _suggestions(p) : _discover()),
          ],
        ),
      ),
    );
  }

  Widget _suggestions(PinPalette p) {
    final q = _ctrl.text.trim().toLowerCase();
    final ideas = [..._ideas, ..._popular].where((i) => q.isNotEmpty && i.title.toLowerCase().contains(q)).toList();
    final recents = RecentSearches.items.where((r) => r.toLowerCase().contains(q)).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (q.isNotEmpty)
          _suggestionRow(PinIcons.search, 'Rechercher « ${_ctrl.text.trim()} »', () => _search(_ctrl.text)),
        for (final i in ideas) _suggestionRow(PinIcons.search, i.title, () => _search(i.query)),
        if (recents.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Recherches récentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                TextButton(
                  onPressed: () => setState(RecentSearches.clear),
                  style: TextButton.styleFrom(foregroundColor: p.textMuted),
                  child: const Text('Effacer', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          for (final r in recents) _suggestionRow(PinIcons.search, r, () => _search(r)),
        ],
        if (q.isEmpty && recents.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Recherchez des idées : montagne, setup bureau, coucher de soleil…',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontSize: 15),
            ),
          ),
      ],
    );
  }

  Widget _suggestionRow(PinIcons icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PinIcon(icon, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _discover() {
    if (_loading) return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    if (_offline) return Center(child: OfflineState(onRetry: _load));
    return RefreshIndicator(
      color: GestaltTheme.pinterestRed,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
        children: [
          _sectionTitle('Des idées pour vous'),
          _grid(_ideas),
          const SizedBox(height: 28),
          _sectionTitle('Populaire sur Pinterest'),
          _grid(_popular),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(t, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      );

  Widget _grid(List<SearchIdea> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.05,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _IdeaCard(idea: items[i], onTap: () => _search(items[i].query)),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final SearchIdea idea;
  final VoidCallback onTap;
  const _IdeaCard({required this.idea, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PinNetImage(idea.image, placeholder: const Color(0xFF555555)),
            const ColoredBox(color: Color(0x66000000)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  idea.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    shadows: [Shadow(color: Color(0x66000000), blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recherches récentes, gardées le temps de la session.
class RecentSearches {
  RecentSearches._();
  static final List<String> items = [];

  static void add(String q) {
    items.removeWhere((x) => x.toLowerCase() == q.toLowerCase());
    items.insert(0, q);
    if (items.length > 8) items.removeLast();
  }

  static void clear() => items.clear();
}
