import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/gestalt_theme.dart';
import 'core/widgets/pin_icon.dart';
import 'core/widgets/ui.dart';
import 'models/pin.dart';
import 'screens/create/collage_screen.dart';
import 'screens/create/create_board_screen.dart';
import 'screens/create/create_pin_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/inbox/inbox_screen.dart';
import 'screens/pin_detail/pin_detail_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/stats_screen.dart';
import 'screens/search/search_results_screen.dart';
import 'screens/search/search_screen.dart';
import 'services/api_service.dart';
import 'services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.loadUser();
  runApp(const PinterestApp());
}

/// Paramètres d'adresse (version web) pour ouvrir directement un écran, utiles aux captures :
/// ?theme=dark&tab=4&open=stats
final Map<String, String> _launch = kIsWeb ? Uri.base.queryParameters : const {};

class PinterestApp extends StatelessWidget {
  const PinterestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final forced = switch (_launch['theme']) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => null,
    };
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Pinterest',
        debugShowCheckedModeBanner: false,
        theme: GestaltTheme.light(),
        darkTheme: GestaltTheme.dark(),
        themeMode: forced ?? mode,
        builder: (context, child) => _PhoneFrame(child: child!),
        home: const MainShell(),
      ),
    );
  }
}

/// Sur un grand écran (navigateur, PC), l'application s'affiche dans un cadre de téléphone.
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});

  static const _size = Size(412, 892);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width < 600) return child;
    return ColoredBox(
      color: const Color(0xFF18181B),
      child: Center(
        child: FittedBox(
          child: Container(
            width: _size.width,
            height: _size.height,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 36, offset: Offset(0, 16))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: MediaQuery(
                data: mq.copyWith(
                    size: _size, padding: const EdgeInsets.only(top: 24), viewPadding: const EdgeInsets.only(top: 24)),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = int.tryParse(_launch['tab'] ?? '') ?? 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    SizedBox.shrink(), // « Créer » ouvre une feuille, pas un onglet
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (_index == 2 || _index < 0 || _index > 4) _index = 0;
    final open = _launch['open'];
    if (open != null) WidgetsBinding.instance.addPostFrameCallback((_) => _openFromLaunch(open));
  }

  Future<void> _openFromLaunch(String open) async {
    final parts = open.split(':');
    final arg = parts.length > 1 ? parts.sublist(1).join(':') : '';
    Widget? screen;
    switch (parts.first) {
      case 'pin':
        final detail = await ApiService().fetchPinDetail(arg);
        if (detail != null) screen = PinDetailScreen(pin: Pin.fromJson(detail), heroTag: 'launch_$arg');
      case 'search':
        screen = SearchResultsScreen(query: arg);
      case 'stats':
        screen = const StatsScreen();
      case 'edit':
        screen = const EditProfileScreen();
      case 'create':
        screen = const CreatePinScreen();
      case 'board':
        screen = const CreateBoardScreen();
      case 'collage':
        screen = const CollageScreen();
      case 'sheet':
        if (mounted) _showCreateSheet();
    }
    if (screen != null && mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

  void _onTap(int i) {
    if (i == 2) return _showCreateSheet();
    if (i == _index && i == 0) AppState.homeReselected.value++;
    setState(() => _index = i);
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        void go(Widget screen) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen, fullscreenDialog: true));
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  PinIconButton(PinIcons.close, onPressed: () => Navigator.pop(ctx), tooltip: 'Fermer'),
                  const Expanded(
                    child: Text(
                      'Laissez libre cours à votre créativité dès maintenant',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CreateOption(icon: PinIcons.pin, label: 'Épingle', onTap: () => go(const CreatePinScreen())),
                  const SizedBox(width: 22),
                  _CreateOption(icon: PinIcons.collage, label: 'Collage', onTap: () => go(const CollageScreen())),
                  const SizedBox(width: 22),
                  _CreateOption(icon: PinIcons.board, label: 'Tableau', onTap: () => go(const CreateBoardScreen())),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: p.bg,
          border: Border(top: BorderSide(color: p.divider, width: 0.6)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                    icon: PinIcons.home,
                    activeIcon: PinIcons.homeFill,
                    label: 'Accueil',
                    active: _index == 0,
                    onTap: () => _onTap(0)),
                _NavItem(
                    icon: PinIcons.search,
                    activeIcon: PinIcons.searchBold,
                    label: 'Rechercher',
                    active: _index == 1,
                    onTap: () => _onTap(1)),
                _NavItem(
                    icon: PinIcons.plus,
                    activeIcon: PinIcons.plus,
                    label: 'Créer',
                    active: false,
                    onTap: () => _onTap(2)),
                _NavItem(
                    icon: PinIcons.chat,
                    activeIcon: PinIcons.chatFill,
                    label: 'Boîte de réception',
                    active: _index == 3,
                    onTap: () => _onTap(3)),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Profil',
                    selected: _index == 4,
                    child: Pressable(
                      onTap: () => _onTap(4),
                      pressedScale: 0.9,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _index == 4 ? p.text : Colors.transparent, width: 2),
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: AppState.user,
                            builder: (_, u, __) =>
                                PinAvatar(url: u?.avatarUrl ?? '', name: u?.fullName ?? '', size: 26),
                          ),
                        ),
                      ),
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

class _NavItem extends StatelessWidget {
  final PinIcons icon;
  final PinIcons activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        selected: active,
        child: Pressable(
          onTap: onTap,
          pressedScale: 0.88,
          child: Center(child: PinIcon(active ? activeIcon : icon, size: 26, strokeWidth: 1.9)),
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final PinIcons icon;
  final String label;
  final VoidCallback onTap;

  const _CreateOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: context.pal.secondaryButton, borderRadius: BorderRadius.circular(24)),
            alignment: Alignment.center,
            child: PinIcon(icon, size: 26, strokeWidth: 1.8),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
