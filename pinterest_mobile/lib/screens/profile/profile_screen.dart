import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_card.dart';
import '../../models/pin.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabCtrl;

  UserProfile? _user;
  List<Pin> _savedPins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: 1); // Start on Enregistrées
    _loadProfile();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = await _api.fetchUserProfile('ahiffent');
    final feed = await _api.fetchHomeFeed();

    if (mounted) {
      setState(() {
        _user = user;
        _savedPins = feed.take(12).toList();
        _isLoading = false;
      });
    }
  }

  Widget _buildClusterCard({
    required String title,
    required String pinCount,
    required List<String> images,
  }) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CachedNetworkImage(
                            imageUrl: ApiEndpoints.resolveUrl(images[0]),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0E0E0)),
                          ),
                        ),
                        if (images.length > 1) ...[
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 1,
                            child: CachedNetworkImage(
                              imageUrl: ApiEndpoints.resolveUrl(images[1]),
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0E0E0)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xEBFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Text(pinCount, style: const TextStyle(color: GestaltTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: GestaltTheme.pinterestRed)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.bar_chart, size: 28),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar & User Details (matching reference screenshot)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBCE8D5), // Pastel light green circle from screenshot
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user?.fullName ?? 'Jaye ahf',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user?.username ?? 'ahiffent',
                            style: const TextStyle(fontSize: 14, color: GestaltTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1 abonné(e) · 2 abonné(e)s',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        _user?.website.replaceFirst('http://', '') ?? 'ahiffonjephte.me',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Two Action Buttons: Hub des créateurs (Red) | Modifier le profil (Grey)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GestaltTheme.pinterestRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Hub des créateurs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GestaltTheme.softGrey,
                            foregroundColor: GestaltTheme.textDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Modifier le profil', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Centered Tabs: Créées / Enregistrées
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: Colors.black,
                    indicatorWeight: 3.5,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    tabs: const [
                      Tab(text: 'Créées'),
                      Tab(text: 'Enregistrées'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // 1. Tab Créées (cf. WhatsApp Image 23.38.52.jpeg)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3C8A2), // Muted gold/tan card from screenshot
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Video Duration Pill
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('0:07', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                      // Mute Icon
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(Icons.volume_off, color: Color(0x99000000), size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Tab Enregistrées (cf. WhatsApp Image 23.38.51 (2).jpeg)
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar inside Pins with '+' Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, size: 20, color: Colors.black),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rechercher dans vos Épingles',
                                  style: TextStyle(color: GestaltTheme.textMuted, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.add, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gardez une trace de ce qui vous inspire',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Les tableaux vous permettent d’organiser les Épingles que vous enregistrez en collections. Démarrez à partir d’un cluster ci-dessous ou créez le vôtre.',
                    style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Horizontal Carousel of Clusters
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildClusterCard(
                          title: 'Tutoriel photoshop',
                          pinCount: '18 Épingles',
                          images: const ['/pins/10.jpg', '/pins/11.jpg'],
                        ),
                        _buildClusterCard(
                          title: 'Idées logo',
                          pinCount: '15 Épingles',
                          images: const ['/pins/12.jpg', '/pins/13.jpg'],
                        ),
                        _buildClusterCard(
                          title: 'Fond d’écran',
                          pinCount: '9 Épingles',
                          images: const ['/pins/14.jpg', '/pins/15.jpg'],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Section: Idées non organisées with Organiser Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Idées non organisées',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GestaltTheme.softGrey,
                          foregroundColor: GestaltTheme.textDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Organiser', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Saved pins grid
                  MasonryGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemCount: _savedPins.length,
                    itemBuilder: (context, index) => PinCard(pin: _savedPins[index]),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
