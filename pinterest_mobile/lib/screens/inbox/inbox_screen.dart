import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/conversation.dart';
import '../../models/notification_item.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../profile/user_profile_screen.dart';
import '../search/search_results_screen.dart';
import 'conversation_screen.dart';
import 'inbox_lists.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _api = ApiService();
  List<ActivityItem> _activity = [];
  List<Conversation> _conversations = [];
  List<NotificationItem> _updates = [];
  bool _loading = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    AppState.dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppState.dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([_api.fetchActivity(), _api.fetchConversations(), _api.fetchNotifications()]);
    if (!mounted) return;
    setState(() {
      _offline = results.every((r) => r == null);
      _activity = (results[0] as List<ActivityItem>?) ?? _activity;
      _conversations = (results[1] as List<Conversation>?) ?? _conversations;
      _updates = (results[2] as List<NotificationItem>?) ?? _updates;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const Text('Boîte de réception', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          PinIconButton(
            PinIcons.compose,
            iconSize: 26,
            tooltip: 'Nouveau message',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewMessageScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : _offline
              ? Center(child: OfflineState(onRetry: _load))
              : RefreshIndicator(
                  color: GestaltTheme.pinterestRed,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      SectionHeader(
                        'Activité',
                        onSeeAll: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen())),
                      ),
                      for (final a in _activity.take(2)) ActivityTile(item: a, onChanged: () => setState(() {})),
                      SectionHeader(
                        'Messages',
                        onSeeAll: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationsScreen())),
                      ),
                      for (final c in _conversations.take(3))
                        ConversationTile(
                          conversation: c,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ConversationScreen(conversation: c)),
                          ).then((_) => setState(() {})),
                        ),
                      _contactTile(p),
                      const SectionHeader('Mises à jour'),
                      if (_updates.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          child: Text('Vous êtes à jour.', style: TextStyle(color: p.textMuted, fontSize: 15)),
                        ),
                      for (final n in _updates) _updateTile(n, p),
                    ],
                  ),
                ),
    );
  }

  Widget _contactTile(PinPalette p) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewMessageScreen())),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: p.secondaryButton, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const PinIcon(PinIcons.personAdd, size: 24, strokeWidth: 1.8),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contacter un utilisateur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Connectez-vous pour entamer une discussion',
                      style: TextStyle(fontSize: 14, color: p.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _updateTile(NotificationItem n, PinPalette p) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(query: n.query))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            n.imageUrl != null
                ? ClipOval(child: PinNetImage(n.imageUrl!, width: 48, height: 48))
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: p.secondaryButton, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const PinIcon(PinIcons.search, size: 22),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.35)),
                  const SizedBox(height: 4),
                  Text(n.timeAgo, style: TextStyle(fontSize: 13, color: p.textMuted)),
                ],
              ),
            ),
            PinIconButton(
              PinIcons.ellipsis,
              iconSize: 18,
              tooltip: 'Options',
              onPressed: () => showPinSheet(
                context,
                title: 'Options',
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SheetOption(
                    'Masquer cette mise à jour',
                    onTap: () async {
                      Navigator.pop(ctx);
                      setState(() => _updates.remove(n));
                      await _api.dismissNotification(n.id);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne « Activité » : suggestion d'abonnement ou nouvel abonné.
class ActivityTile extends StatefulWidget {
  final ActivityItem item;
  final VoidCallback? onChanged;
  const ActivityTile({super.key, required this.item, this.onChanged});

  @override
  State<ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<ActivityTile> {
  final _api = ApiService();
  bool _busy = false;

  ActivityItem get a => widget.item;

  Future<void> _follow() async {
    setState(() => _busy = true);
    final r = await _api.toggleFollow(a.user.username);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r != null) a.isFollowing = r;
    });
    if (r == null) showPinToast(context, 'Action impossible. Réessayez.');
    widget.onChanged?.call();
  }

  Future<void> _greet() async {
    setState(() => _busy = true);
    final conv = await _api.openConversation(a.user.username);
    final sent = conv == null ? null : await _api.sendMessage(conv.id, 'Salut ! 👋 Merci pour l’abonnement.');
    if (!mounted) return;
    setState(() => _busy = false);
    if (conv == null || sent == null) return showPinToast(context, 'Envoi impossible. Réessayez.');
    conv.messages.add(sent);
    AppState.dataChanged();
    Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conv)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isSuggestion = a.type == 'suggestion';
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(username: a.user.username))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PinAvatar(url: a.user.avatarUrl, name: a.user.name, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          isSuggestion ? '${a.text} ${a.user.name}' : '${a.user.name} ${a.text}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.35),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(a.timeAgo, style: TextStyle(fontSize: 13, color: p.textMuted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  isSuggestion
                      ? PinButton(
                          a.isFollowing ? 'Abonné(e)' : 'S’abonner',
                          kind: a.isFollowing ? PinButtonKind.dark : PinButtonKind.grey,
                          loading: _busy,
                          onPressed: _follow,
                        )
                      : PinButton('Saluer', loading: _busy, onPressed: _greet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  const ConversationTile({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final u = conversation.withUser;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            PinAvatar(url: u.avatarUrl, name: u.name, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessage.isEmpty ? 'Nouvelle conversation' : conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: p.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(conversation.timeAgo, style: TextStyle(fontSize: 13, color: p.textMuted)),
          ],
        ),
      ),
    );
  }
}
