import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/ui.dart';
import '../../models/board.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _scroll = ScrollController();

  List<Board> _boards = [];
  int _tab = 0; // 0 = Tout, puis un onglet par tableau
  final List<Pin> _pins = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    AppState.dataVersion.addListener(_onDataChanged);
    AppState.homeReselected.addListener(_onReselected);
    _loadBoards();
    _reload();
  }

  @override
  void dispose() {
    AppState.dataVersion.removeListener(_onDataChanged);
    AppState.homeReselected.removeListener(_onReselected);
    _scroll.dispose();
    super.dispose();
  }

  Board? get _board => _tab == 0 || _tab > _boards.length ? null : _boards[_tab - 1];

  Future<void> _loadBoards() async {
    final boards = await _api.fetchBoards();
    if (!mounted || boards == null) return;
    setState(() {
      final current = _board?.id;
      _boards = boards;
      final i = boards.indexWhere((b) => b.id == current);
      _tab = i < 0 ? 0 : i + 1;
    });
  }

  void _onDataChanged() {
    _loadBoards();
    if (_board != null) _reload();
  }

  void _onReselected() {
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      _reload();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = _pins.isEmpty;
      _offline = false;
    });
    final board = _board;
    if (board != null) {
      final pins = await _api.fetchBoardPins(board.id);
      if (!mounted) return;
      setState(() {
        _offline = pins == null;
        _pins
          ..clear()
          ..addAll(pins ?? []);
        _hasMore = false;
        _loading = false;
      });
      return;
    }
    final page = await _api.fetchHomeFeed(page: 1);
    if (!mounted) return;
    setState(() {
      _offline = page == null;
      _pins
        ..clear()
        ..addAll(page?.pins ?? []);
      _page = 1;
      _hasMore = page?.hasMore ?? false;
      _loading = false;
    });
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _board != null) return;
    if (_scroll.position.extentAfter < 900) _loadMore();
  }

  Future<void> _loadMore() async {
    _loadingMore = true;
    final page = await _api.fetchHomeFeed(page: _page + 1);
    _loadingMore = false;
    if (!mounted || page == null) return;
    setState(() {
      _page++;
      final known = _pins.map((p) => p.id).toSet();
      _pins.addAll(page.pins.where((p) => !known.contains(p.id)));
      _hasMore = page.hasMore;
    });
  }

  void _selectTab(int i) {
    if (i == _tab) return;
    setState(() {
      _tab = i;
      _pins.clear();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final showTabs = _boards.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: GestaltTheme.pinterestRed,
          backgroundColor: p.sheet,
          onRefresh: () async {
            await _loadBoards();
            await _reload();
          },
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (showTabs)
                SliverAppBar(
                  floating: true,
                  snap: true,
                  toolbarHeight: 52,
                  automaticallyImplyLeading: false,
                  backgroundColor: p.bg,
                  // Hors du titre de la barre, qui tronquerait les noms de tableaux.
                  flexibleSpace: Align(
                    alignment: Alignment.bottomLeft,
                    child: PinTextTabs(
                      labels: ['Tout', ..._boards.map((b) => b.name)],
                      index: _tab,
                      onChanged: _selectTab,
                      scrollable: true,
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox(height: 6)),
              if (_loading)
                const SliverPinSkeleton()
              else if (_offline && _pins.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: Center(child: OfflineState(onRetry: _reload)))
              else if (_pins.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyState(
                      title: _board == null ? 'Rien à afficher pour l’instant' : 'Aucune Épingle dans ce tableau',
                      message: _board == null
                          ? 'Tirez vers le bas pour actualiser le fil.'
                          : 'Enregistrez des Épingles dans « ${_board!.name} » pour les retrouver ici.',
                    ),
                  ),
                )
              else
                SliverPinGrid(
                  pins: _pins,
                  heroScope: 'home',
                  onRemove: (pin) => setState(() => _pins.remove(pin)),
                  onRestore: (i, pin) => setState(() => _pins.insert(i.clamp(0, _pins.length), pin)),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 72,
                  child: _hasMore && !_loading
                      ? const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)))
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
