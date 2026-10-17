import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/conversation.dart';
import '../../services/api_service.dart';
import 'conversation_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ApiService _api = ApiService();
  List<Conversation> _conversations = [];
  final Set<String> _followed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final convs = await _api.fetchConversations();
    if (!mounted) return;
    setState(() {
      _conversations = convs;
      _loading = false;
    });
  }

  Future<void> _openConversation(Conversation conv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conv)),
    );
    if (!mounted) return;
    // La dernière ligne a pu changer après l'envoi d'un message.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Boîte de réception',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: GestaltTheme.pinterestRed,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _sectionHeader('Activité', showSeeAll: true),
              const SizedBox(height: 8),
              _activityItem(
                avatar: _letterAvatar('A', const Color(0xFFD5D8FC)),
                richText: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15, height: 1.3),
                  children: [
                    TextSpan(text: 'Vous connaissez peut-être ', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: 'Alassanemomo', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: '   1 sem.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                actionLabel: 'S’abonner',
                followUsername: 'alassanemomo',
              ),
              _activityItem(
                avatar: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('ZORA', style: TextStyle(color: Color(0xFFE5C158), fontSize: 11, fontWeight: FontWeight.w900)),
                ),
                richText: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15, height: 1.3),
                  children: [
                    TextSpan(text: 'zora est abonné(e) à vos Épingles', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: '   03/26', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                actionLabel: 'Saluer',
              ),

              const SizedBox(height: 20),
              _sectionHeader('Messages', showSeeAll: true),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(color: GestaltTheme.pinterestRed, strokeWidth: 2.5)),
                )
              else
                ..._conversations.map(_conversationTile),
              _contactUserTile(),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text('Mises à jour', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              ),
              const SizedBox(height: 8),
              _updateItem('Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Web Site Motion Design.', '07/26'),
              _updateItem('Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Naruto guide.', '07/26'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- Blocs réutilisables ---

  Widget _sectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          if (showSeeAll)
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[700]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _letterAvatar(String letter, Color bg) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(letter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
    );
  }

  Widget _activityItem({required Widget avatar, required TextSpan richText, required String actionLabel, String? followUsername}) {
    final isFollowed = followUsername != null && _followed.contains(followUsername);
    final label = isFollowed ? 'Abonné' : actionLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: richText),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: followUsername == null
                      ? () {}
                      : () async {
                          final newState = await _api.toggleFollow(followUsername);
                          if (!mounted) return;
                          setState(() {
                            if (newState) {
                              _followed.add(followUsername);
                            } else {
                              _followed.remove(followUsername);
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowed ? GestaltTheme.hoverGrey : GestaltTheme.softGrey,
                    foregroundColor: GestaltTheme.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationTile(Conversation conv) {
    final user = conv.withUser;
    return InkWell(
      onTap: () => _openConversation(conv),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            _convAvatar(user),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: GestaltTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(conv.timeAgo, style: const TextStyle(color: GestaltTheme.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _convAvatar(ChatUser user) {
    final fallback = _letterAvatar(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', const Color(0xFFD5D8FC));
    if (user.avatarUrl.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: ApiEndpoints.resolveUrl(user.avatarUrl),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _contactUserTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: GestaltTheme.softGrey, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.person_add_alt_1_outlined, size: 24, color: Colors.black),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contacter un utilisateur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                SizedBox(height: 2),
                Text('Connectez-vous pour entamer une discussion', style: TextStyle(color: GestaltTheme.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _updateItem(String text, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: GestaltTheme.softGrey, shape: BoxShape.circle),
            child: const Icon(Icons.search, size: 24, color: Colors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz, color: Colors.black, size: 20),
        ],
      ),
    );
  }
}
