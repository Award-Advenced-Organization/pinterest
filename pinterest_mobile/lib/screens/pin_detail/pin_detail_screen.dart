import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_card.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';

class PinDetailScreen extends StatefulWidget {
  final Pin pin;

  const PinDetailScreen({super.key, required this.pin});

  @override
  State<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends State<PinDetailScreen> {
  final ApiService _api = ApiService();
  bool _isSaved = false;
  bool _isFollowing = false;
  List<Pin> _relatedPins = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.pin.isSaved;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final detail = await _api.fetchPinDetail(widget.pin.id);
    if (detail != null && mounted) {
      final related = (detail['related_pins'] as List<dynamic>? ?? [])
          .map((j) => Pin.fromJson(j))
          .toList();
      setState(() {
        _relatedPins = related;
        _loadingRelated = false;
      });
    } else {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  Future<void> _toggleSave() async {
    final newState = await _api.toggleSavePin(widget.pin.id);
    if (mounted) {
      setState(() => _isSaved = newState);
      widget.pin.isSaved = newState;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Enregistrée dans vos tableaux !' : 'Retirée de vos tableaux'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.resolveUrl(widget.pin.imageUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _toggleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaved ? GestaltTheme.textDark : GestaltTheme.pinterestRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              _isSaved ? 'Enregistré' : 'Enregistrer',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive Zoomable Image with Hero Transition
            Hero(
              tag: 'pin_${widget.pin.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InteractiveViewer(
                  maxScale: 3.5,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 380, color: Colors.grey[200]),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (widget.pin.title.isNotEmpty)
                    Text(
                      widget.pin.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    ),
                  if (widget.pin.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.pin.description,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Creator row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: widget.pin.creator.avatarUrl.isNotEmpty
                            ? NetworkImage(ApiEndpoints.resolveUrl(widget.pin.creator.avatarUrl))
                            : null,
                        child: widget.pin.creator.avatarUrl.isEmpty
                            ? Text(widget.pin.creator.name.isNotEmpty ? widget.pin.creator.name[0] : 'U')
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pin.creator.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            Text(
                              '@${widget.pin.creator.username}',
                              style: const TextStyle(color: GestaltTheme.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => _isFollowing = !_isFollowing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? GestaltTheme.softGrey : GestaltTheme.textDark,
                          foregroundColor: _isFollowing ? GestaltTheme.textDark : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          _isFollowing ? 'Abonné' : 'S’abonner',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36),
                  // Comments Section Preview
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Commentaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Icon(Icons.keyboard_arrow_down, color: GestaltTheme.textMuted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Partagez vos impressions ou posez une question.', style: TextStyle(color: GestaltTheme.textMuted, fontSize: 13)),
                  const Divider(height: 36),
                  // Related Pins Section
                  const Text(
                    'Plus d’idées similaires',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingRelated)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  else if (_relatedPins.isNotEmpty)
                    MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemCount: _relatedPins.length,
                      itemBuilder: (context, index) => PinCard(pin: _relatedPins[index]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
