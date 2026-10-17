import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_endpoints.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _ideasForYou = [
    {'title': 'Photos de mariage', 'image': '/pins/10.jpg'},
    {'title': 'Photographie portrait', 'image': '/pins/11.jpg'},
    {'title': 'Lamborghini', 'image': '/pins/12.jpg'},
    {'title': 'Bmw m5', 'image': '/pins/13.jpg'},
    {'title': 'Ios', 'image': '/pins/14.jpg'},
    {'title': 'Design d’affiche et de dépliant', 'image': '/pins/15.jpg'},
    {'title': 'Baskets pour femmes', 'image': '/pins/16.jpg'},
    {'title': 'Surfer d’argent', 'image': '/pins/17.jpg'},
  ];

  final List<Map<String, String>> _popularOnPinterest = [
    {'title': 'Coiffure homme', 'image': '/pins/18.jpg'},
    {'title': 'Outfit homme', 'image': '/pins/19.jpg'},
    {'title': 'Photo miroir', 'image': '/pins/20.jpg'},
    {'title': 'Photo clean', 'image': '/pins/21.jpg'},
  ];

  Widget _buildCategoryCard(Map<String, String> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: Colors.grey[800],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ApiEndpoints.resolveUrl(item['image']!),
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
            Container(
              color: const Color(0x6B000000), // Dark dimming overlay from reference screenshot
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Search Bar with Camera Visual Search (matching reference screenshot)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black87, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Rechercher',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87, size: 24),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recherche visuelle activée')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section 1: Des idées pour vous
              const Center(
                child: Text(
                  'Des idées pour vous',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                  ),
                  itemCount: _ideasForYou.length,
                  itemBuilder: (context, index) => _buildCategoryCard(_ideasForYou[index]),
                ),
              ),
              const SizedBox(height: 28),
              // Section 2: Populaire sur Pinterest
              const Center(
                child: Text(
                  'Populaire sur Pinterest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                  ),
                  itemCount: _popularOnPinterest.length,
                  itemBuilder: (context, index) => _buildCategoryCard(_popularOnPinterest[index]),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
