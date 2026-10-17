import 'package:flutter/material.dart';
import 'core/theme/gestalt_theme.dart';
import 'screens/create/create_pin_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/inbox/inbox_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PinterestApp());
}

class PinterestApp extends StatelessWidget {
  const PinterestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinterest',
      debugShowCheckedModeBanner: false,
      theme: GestaltTheme.light(),
      darkTheme: GestaltTheme.dark(),
      themeMode: ThemeMode.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CreatePinScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  void _showCreationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 28, color: Colors.black),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Laissez libre cours à votre créativité dès maintenant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.25),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCreateOption(
                  icon: Icons.push_pin_outlined,
                  label: 'Épingle',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePinScreen()));
                  },
                ),
                _buildCreateOption(
                  icon: Icons.content_cut,
                  label: 'Collage',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Outil Collage ouvert')),
                    );
                  },
                ),
                _buildCreateOption(
                  icon: Icons.dashboard_outlined,
                  label: 'Tableau',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nouveau Tableau')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        final app = Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.8)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  _showCreationModal(context);
                } else {
                  setState(() => _currentIndex = index);
                }
              },
              selectedItemColor: GestaltTheme.textDark,
              unselectedItemColor: GestaltTheme.textMuted,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              backgroundColor: Colors.white,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 28),
                  activeIcon: Icon(Icons.home_filled, size: 28, color: GestaltTheme.textDark),
                  label: 'Accueil',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 28),
                  activeIcon: Icon(Icons.search, size: 30, color: GestaltTheme.textDark),
                  label: 'Rechercher',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add, size: 30),
                  activeIcon: Icon(Icons.add, size: 32, color: GestaltTheme.textDark),
                  label: 'Créer',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline, size: 26),
                  activeIcon: Icon(Icons.chat_bubble, size: 26, color: GestaltTheme.textDark),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: _currentIndex == 4
                          ? Border.all(color: GestaltTheme.textDark, width: 2)
                          : null,
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundImage: AssetImage('assets/images/avatar_jaye.jpg'),
                    ),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );

        if (!isWide) {
          return app;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF18181B),
          body: Center(
            child: Container(
              width: 430,
              height: 880,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: app,
              ),
            ),
          ),
        );
      },
    );
  }
}
