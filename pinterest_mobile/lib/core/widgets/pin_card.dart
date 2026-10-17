import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../models/pin.dart';
import '../../screens/pin_detail/pin_detail_screen.dart';
import '../../services/api_service.dart';

class PinCard extends StatefulWidget {
  final Pin pin;
  final VoidCallback? onSavedChanged;

  const PinCard({super.key, required this.pin, this.onSavedChanged});

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  final ApiService _api = ApiService();

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: GestaltTheme.pinterestRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark, color: Colors.white),
                ),
                title: Text(widget.pin.isSaved ? 'Déjà enregistrée' : 'Enregistrer l’Épingle',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                subtitle: const Text('Sauvegarder dans vos tableaux'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final saved = await _api.toggleSavePin(widget.pin.id);
                  setState(() => widget.pin.isSaved = saved);
                  widget.onSavedChanged?.call();
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.black87),
                ),
                title: const Text('Partager', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility_off_outlined, color: Colors.black87),
                ),
                title: const Text('Masquer l’Épingle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.resolveUrl(widget.pin.imageUrl);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PinDetailScreen(pin: widget.pin),
          ),
        ).then((_) => setState(() {}));
      },
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners and Hero animation
            ClipRRect(
              borderRadius: BorderRadius.circular(GestaltTheme.cardRadius),
              child: AspectRatio(
                aspectRatio: widget.pin.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'pin_${widget.pin.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFEEEEEE),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (widget.pin.isVideo) ...[
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.pin.videoDuration ?? '0:22',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0x66000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_off, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Carousel Indicator Dots or Metadata Row
            if (widget.pin.isCarousel) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 4.5, height: 4.5, decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 4.5, height: 4.5, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 4.5, height: 4.5, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 4.5, height: 4.5, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showContextMenu(context),
                    child: const Icon(Icons.more_horiz, size: 18, color: GestaltTheme.textDark),
                  ),
                ],
              ),
            ] else if (widget.pin.title.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.pin.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: GestaltTheme.textDark,
                        height: 1.25,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showContextMenu(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4, top: 1),
                      child: Icon(Icons.more_horiz, size: 16, color: GestaltTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showContextMenu(context),
                    child: const Icon(Icons.more_horiz, size: 18, color: GestaltTheme.textDark),
                  ),
                ],
              ),
            ],
            if (widget.pin.creator.name.isNotEmpty && widget.pin.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: ApiEndpoints.resolveUrl(widget.pin.creator.avatarUrl),
                      width: 18,
                      height: 18,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 18,
                        height: 18,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.pin.creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: GestaltTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
