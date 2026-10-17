import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_card.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final List<Pin> _pins = [];
  bool _isLoading = true;
  int _activeTab = 0;
  String _activeCategory = 'Tout';
  final List<String> _categories = ['Tout', 'Dev Web', 'Design', 'Tech', 'Nature', 'Mode', 'Art'];

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    setState(() => _isLoading = true);
    final pins = _activeCategory == 'Tout'
        ? await _api.fetchHomeFeed()
        : await _api.searchPins(category: _activeCategory.toLowerCase().replaceAll(' ', ''));
    if (mounted) {
      setState(() {
        _pins.clear();
        _pins.addAll(pins);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.white,
              titleSpacing: 16,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_activeTab != 0) {
                        setState(() => _activeTab = 0);
                        _loadPins();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pour vous',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _activeTab == 0 ? GestaltTheme.textDark : GestaltTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? GestaltTheme.textDark : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      if (_activeTab != 1) {
                        setState(() => _activeTab = 1);
                        _loadPins();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Abonnements',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _activeTab == 1 ? GestaltTheme.textDark : GestaltTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? GestaltTheme.textDark : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _activeCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _activeCategory = cat);
                            _loadPins();
                          }
                        },
                        selectedColor: GestaltTheme.textDark,
                        backgroundColor: GestaltTheme.softGrey,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : GestaltTheme.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: GestaltTheme.pinterestRed))
              : RefreshIndicator(
                  color: GestaltTheme.pinterestRed,
                  onRefresh: _loadPins,
                  child: MasonryGridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemCount: _pins.length,
                    itemBuilder: (context, index) {
                      return PinCard(pin: _pins[index]);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
