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
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSaved = false;
  bool _isFollowing = false;
  bool _followBusy = false;
  bool _postingComment = false;
  List<Pin> _relatedPins = [];
  List<Map<String, dynamic>> _comments = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.pin.isSaved;
    _loadDetails();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final detail = await _api.fetchPinDetail(widget.pin.id);
    if (detail != null && mounted) {
      final related = (detail['related_pins'] as List<dynamic>? ?? [])
          .map((j) => Pin.fromJson(j))
          .toList();
      final comments = (detail['comments'] as List<dynamic>? ?? [])
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
      setState(() {
        _relatedPins = related;
        _comments = comments;
        _isFollowing = detail['is_following'] == true;
        _loadingRelated = false;
      });
    } else {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_followBusy) return;
    setState(() => _followBusy = true);
    final newState = await _api.toggleFollow(widget.pin.creator.username);
    if (mounted) {
      setState(() {
        _isFollowing = newState;
        _followBusy = false;
      });
    }
  }

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _postingComment) return;
    setState(() => _postingComment = true);
    final created = await _api.postComment(widget.pin.id, text);
    if (!mounted) return;
    setState(() {
      _postingComment = false;
      if (created != null) {
        _comments.add(created);
        _commentCtrl.clear();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l’envoi du commentaire.')),
        );
      }
    });
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

  Widget _buildComment(Map<String, dynamic> c) {
    final author = (c['author'] ?? '').toString();
    final avatarUrl = (c['avatar_url'] ?? '').toString();
    final initial = author.isNotEmpty ? author[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFD5D8FC),
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(ApiEndpoints.resolveUrl(avatarUrl)) : null,
            child: avatarUrl.isEmpty
                ? Text(initial, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF333333)))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                    const SizedBox(width: 8),
                    Text((c['time_ago'] ?? '').toString(), style: const TextStyle(color: GestaltTheme.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text((c['text'] ?? '').toString(), style: const TextStyle(fontSize: 14, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: GestaltTheme.softGrey,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _commentCtrl,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _postComment(),
              decoration: const InputDecoration(
                hintText: 'Ajouter un commentaire',
                hintStyle: TextStyle(color: GestaltTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _postingComment
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: GestaltTheme.pinterestRed)),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_upward, color: GestaltTheme.pinterestRed),
                onPressed: _postComment,
              ),
      ],
    );
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
                        onPressed: _followBusy ? null : _toggleFollow,
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
                  // Comments Section
                  Row(
                    children: [
                      const Text('Commentaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text('${_comments.length}', style: const TextStyle(fontSize: 16, color: GestaltTheme.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_comments.isEmpty)
                    const Text('Partagez vos impressions ou posez une question.', style: TextStyle(color: GestaltTheme.textMuted, fontSize: 13))
                  else
                    ..._comments.map(_buildComment),
                  const SizedBox(height: 12),
                  _buildCommentInput(),
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
