import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/board.dart';
import '../../models/pin.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../create/collage_screen.dart';
import '../create/create_board_screen.dart';
import '../create/create_pin_screen.dart';
import 'board_screen.dart';
import 'edit_profile_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  int _tab = 1; // 0 = Créées, 1 = Enregistrées
  List<Pin> _created = [];
  List<Board> _boards = [];
  List<Cluster> _clusters = [];
  final List<Pin> _unorganized = [];
  bool _loading = true;
  bool _offline = false;
  String? _creatingCluster;

  /// Mode « Organiser » : Épingles cochées à ranger dans un tableau.
  Set<String>? _selection;

  @override
  void initState() {
    super.initState();
    AppState.dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppState.dataVersion.removeListener(_load);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _api.fetchCreatedPins('me'),
      _api.fetchBoards(),
      _api.fetchClusters(),
      _api.fetchSavedPins(unorganizedOnly: true),
    ]);
    if (AppState.user.value == null) await AppState.loadUser();
    if (!mounted) return;
    setState(() {
      _offline = results[1] == null;
      _created = (results[0] as List<Pin>?) ?? _created;
      _boards = (results[1] as List<Board>?) ?? _boards;
      _clusters = results[2] as List<Cluster>;
      final unorganized = results[3] as List<Pin>?;
      if (unorganized != null) {
        _unorganized
          ..clear()
          ..addAll(unorganized);
      }
      _loading = false;
    });
  }

  String get _filter => _searchCtrl.text.trim().toLowerCase();

  Future<void> _createFromCluster(Cluster c) async {
    setState(() => _creatingCluster = c.id);
    final r = await _api.createBoardFromCluster(c.id);
    if (!mounted) return;
    setState(() => _creatingCluster = null);
    if (!r.ok) return showPinToast(context, r.error!);
    showPinToast(context, 'Tableau « ${r.data!.name} » créé avec ${r.data!.pinCount} Épingles');
    AppState.dataChanged();
  }

  Future<void> _moveSelection() async {
    final ids = _selection!.toList();
    if (ids.isEmpty) return;
    final board = await showPinSheet<Board>(
      context,
      title: 'Déplacer vers un tableau',
      builder: (ctx) => _BoardChoice(boards: _boards),
    );
    if (board == null || !mounted) return;
    if (await _api.movePinsToBoard(board.id, ids)) {
      if (!mounted) return;
      setState(() => _selection = null);
      showPinToast(context,
          '${ids.length} Épingle${ids.length > 1 ? 's' : ''} déplacée${ids.length > 1 ? 's' : ''} dans « ${board.name} »');
      AppState.dataChanged();
    } else if (mounted) {
      showPinToast(context, 'Déplacement impossible. Réessayez.');
    }
  }

  void _showMore() {
    showPinSheet(
      context,
      title: 'Profil',
      builder: (ctx) {
        void then(VoidCallback f) {
          Navigator.pop(ctx);
          f();
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            SheetOption('Modifier le profil', onTap: () => then(_editProfile)),
            SheetOption('Apparence',
                subtitle: _appearanceLabel(AppState.user.value?.appearance), onTap: () => then(_chooseAppearance)),
            SheetOption('Copier le lien du profil', onTap: () => then(_copyProfileLink)),
          ],
        );
      },
    );
  }

  String _appearanceLabel(String? v) => switch (v) {
        'light' => 'Clair',
        'dark' => 'Sombre',
        _ => 'Paramètres de l’appareil',
      };

  Future<void> _chooseAppearance() async {
    final current = AppState.user.value?.appearance ?? 'system';
    final choice = await showPinSheet<String>(
      context,
      title: 'Apparence',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          for (final v in ['system', 'light', 'dark'])
            InkWell(
              onTap: () => Navigator.pop(ctx, v),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(_appearanceLabel(v),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    if (v == current) const PinIcon(PinIcons.check, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (choice == null || choice == current) return;
    final r = await _api.updateMe({'appearance': choice});
    if (!mounted) return;
    if (r.ok) {
      AppState.setUser(r.data!);
    } else {
      showPinToast(context, r.error!);
    }
  }

  Future<void> _copyProfileLink() async {
    final u = AppState.user.value;
    if (u == null) return;
    await Clipboard.setData(ClipboardData(text: 'https://www.pinterest.fr/${u.username}/'));
    if (mounted) showPinToast(context, 'Lien du profil copié');
  }

  Future<void> _editProfile() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(heightFactor: 0.96, child: EditProfileScreen()),
    );
  }

  void _showCreateMenu() {
    showPinSheet(
      context,
      title: 'Créer',
      builder: (ctx) {
        void go(Widget screen) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen, fullscreenDialog: true));
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            SheetOption('Épingle', onTap: () => go(const CreatePinScreen())),
            SheetOption('Tableau', onTap: () => go(const CreateBoardScreen())),
            SheetOption('Collage', onTap: () => go(const CollageScreen())),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<UserProfile?>(
          valueListenable: AppState.user,
          builder: (context, user, _) {
            if (_loading && user == null) return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
            if (user == null) return Center(child: OfflineState(onRetry: _load));
            return Stack(
              children: [
                RefreshIndicator(
                  color: GestaltTheme.pinterestRed,
                  onRefresh: () async {
                    await AppState.loadUser();
                    await _load();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _topBar()),
                      SliverToBoxAdapter(child: _header(user, p)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabsHeader(
                          user: user,
                          tab: _tab,
                          onTab: (i) => setState(() {
                            _tab = i;
                            _selection = null;
                          }),
                          onMore: _showMore,
                          background: p.bg,
                        ),
                      ),
                      if (_offline) SliverToBoxAdapter(child: OfflineState(onRetry: _load)),
                      ...(_tab == 0 ? _createdTab() : _savedTab(p)),
                      const SliverToBoxAdapter(child: SizedBox(height: 96)),
                    ],
                  ),
                ),
                if (_selection != null) _selectionBar(p),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Row(
        children: [
          PinIconButton(
            PinIcons.stats,
            iconSize: 26,
            tooltip: 'Statistiques',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          const Spacer(),
          PinIconButton(PinIcons.share, iconSize: 25, tooltip: 'Partager le profil', onPressed: _copyProfileLink),
          PinIconButton(PinIcons.ellipsis, iconSize: 22, tooltip: 'Plus d’options', onPressed: _showMore),
        ],
      ),
    );
  }

  Widget _header(UserProfile u, PinPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PinAvatar(url: u.avatarUrl, name: u.fullName, size: 72, background: p.avatarMint),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.15)),
                    const SizedBox(height: 4),
                    Text(
                      u.pronouns.isEmpty ? u.username : '${u.username} · ${u.pronouns.join('/')}',
                      style: TextStyle(fontSize: 14, color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${u.followerCount} abonné(e) · ${u.followingCount} abonné(e)s',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (u.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(u.bio, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
          if (u.website.isNotEmpty) ...[
            const SizedBox(height: 10),
            Pressable(
              onTap: () => launchUrl(Uri.parse(u.website.startsWith('http') ? u.website : 'https://${u.website}')),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PinIcon(PinIcons.globe, size: 18, strokeWidth: 1.7),
                  const SizedBox(width: 6),
                  Text(u.websiteLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PinButton(
                  'Hub des créateurs',
                  kind: PinButtonKind.red,
                  large: true,
                  expand: true,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: PinButton('Modifier le profil', large: true, expand: true, onPressed: _editProfile)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _createdTab() {
    if (_loading) return const [SliverPinSkeleton(count: 4)];
    if (_created.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            title: 'Inspirez-vous, créez',
            message: 'Les Épingles que vous créez s’afficheront ici.',
            actionLabel: 'Créer une Épingle',
            onAction: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CreatePinScreen(), fullscreenDialog: true)),
          ),
        ),
      ];
    }
    return [
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverPinGrid(pins: _created, heroScope: 'created'),
    ];
  }

  List<Widget> _savedTab(PinPalette p) {
    final f = _filter;
    final boards = _boards.where((b) => f.isEmpty || b.name.toLowerCase().contains(f)).toList();
    final pins = _unorganized.where((x) => f.isEmpty || x.title.toLowerCase().contains(f)).toList();
    final selecting = _selection != null;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 16),
          child: Row(
            children: [
              Expanded(
                child: PinSearchBar(
                  controller: _searchCtrl,
                  hint: 'Rechercher dans vos Épingles',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 4),
              PinIconButton(PinIcons.plus, iconSize: 28, tooltip: 'Créer', onPressed: _showCreateMenu),
            ],
          ),
        ),
      ),
      if (_boards.isEmpty && f.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'Gardez une trace de ce qui vous inspire',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les tableaux vous permettent d’organiser les Épingles que vous enregistrez en collections. '
                  'Démarrez à partir d’un cluster ci-dessous ou créez le vôtre.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4, color: p.text),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        )
      else if (boards.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.98,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _BoardCard(
                board: boards[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BoardScreen(board: boards[i]))),
              ),
              childCount: boards.length,
            ),
          ),
        ),
      if (_clusters.isNotEmpty && f.isEmpty && !selecting) ...[
        if (_boards.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text('Tableaux suggérés', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _clusters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _ClusterCard(
                cluster: _clusters[i],
                busy: _creatingCluster == _clusters[i].id,
                onCreate: () => _createFromCluster(_clusters[i]),
              ),
            ),
          ),
        ),
      ],
      SliverToBoxAdapter(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Divider(color: p.divider)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selecting ? 'Sélectionnez des Épingles' : 'Idées non organisées',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (pins.isNotEmpty || selecting)
                    PinButton(
                      selecting ? 'Annuler' : 'Organiser',
                      onPressed: () => setState(() => _selection = selecting ? null : <String>{}),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (_loading)
        const SliverPinSkeleton(count: 4)
      else if (pins.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              f.isEmpty
                  ? 'Toutes vos Épingles sont rangées dans des tableaux.'
                  : 'Aucune Épingle ne correspond à « ${_searchCtrl.text.trim()} ».',
              style: TextStyle(fontSize: 15, color: p.textMuted),
            ),
          ),
        )
      else
        SliverPinGrid(
          pins: pins,
          heroScope: 'saved',
          onChanged: _load,
          selectedIds: _selection,
          onSelect: selecting
              ? (pin) =>
                  setState(() => _selection!.contains(pin.id) ? _selection!.remove(pin.id) : _selection!.add(pin.id))
              : null,
        ),
    ];
  }

  Widget _selectionBar(PinPalette p) {
    final n = _selection!.length;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        decoration: BoxDecoration(
          color: p.sheet,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                n == 0 ? 'Aucune sélection' : '$n sélectionnée${n > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (_boards.isEmpty)
              PinButton(
                'Créer un tableau',
                kind: PinButtonKind.red,
                large: true,
                onPressed: () async {
                  final board = await Navigator.push<Board>(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateBoardScreen(), fullscreenDialog: true),
                  );
                  if (board != null && mounted) {
                    _boards = [board];
                    _moveSelection();
                  }
                },
              )
            else
              PinButton('Déplacer', kind: PinButtonKind.red, large: true, onPressed: n == 0 ? null : _moveSelection),
          ],
        ),
      ),
    );
  }
}

/// Onglets « Créées / Enregistrées » qui restent en haut ; une fois collés, l'avatar et « … » apparaissent.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  final UserProfile user;
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onMore;
  final Color background;

  _TabsHeader(
      {required this.user, required this.tab, required this.onTab, required this.onMore, required this.background});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: overlapsContent ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: PinAvatar(url: user.avatarUrl, name: user.fullName, size: 40, background: context.pal.avatarMint),
            ),
          ),
          Expanded(
              child: PinTextTabs(labels: const ['Créées', 'Enregistrées'], index: tab, onChanged: onTab, fontSize: 17)),
          AnimatedOpacity(
            opacity: overlapsContent ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: PinIconButton(PinIcons.ellipsis,
                iconSize: 22, tooltip: 'Plus d’options', onPressed: overlapsContent ? onMore : null),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsHeader old) => old.tab != tab || old.user != user || old.background != background;
}

/// Trois images : une grande à gauche, deux petites empilées à droite (couverture de tableau).
class BoardCover extends StatelessWidget {
  final List<String> images;
  final double radius;
  const BoardCover({super.key, required this.images, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget slot(int i) => i < images.length ? PinNetImage(images[i]) : ColoredBox(color: p.skeleton);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: p.bg,
        child: Row(
          children: [
            Expanded(flex: 2, child: slot(0)),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [Expanded(child: slot(1)), const SizedBox(height: 2), Expanded(child: slot(2))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;
  const _BoardCard({required this.board, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: BoardCover(images: board.coverImages)),
          const SizedBox(height: 8),
          Text(board.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              if (board.secret) ...[PinIcon(PinIcons.lock, size: 13, color: p.textMuted), const SizedBox(width: 4)],
              Text('${board.pinCount} Épingle${board.pinCount > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 13, color: p.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  final Cluster cluster;
  final bool busy;
  final VoidCallback onCreate;
  const _ClusterCard({required this.cluster, required this.busy, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      width: 172,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 116,
            child: Stack(
              fit: StackFit.expand,
              children: [
                BoardCover(images: cluster.coverImages),
                Center(child: PinButton('Créer', loading: busy, onPressed: onCreate)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(cluster.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text('${cluster.pinCount} Épingles', style: TextStyle(fontSize: 13, color: p.textMuted)),
        ],
      ),
    );
  }
}

class _BoardChoice extends StatelessWidget {
  final List<Board> boards;
  const _BoardChoice({required this.boards});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final b in boards)
          InkWell(
            onTap: () => Navigator.pop(context, b),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  SizedBox(width: 52, height: 52, child: BoardCover(images: b.coverImages, radius: 12)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(b.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
