import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../models/conversation.dart';
import '../../models/notification_item.dart';
import '../../services/api_service.dart';
import 'conversation_screen.dart';
import 'inbox_screen.dart';

/// « Tout voir » de la section Activité.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<ActivityItem>? _items;

  @override
  void initState() {
    super.initState();
    ApiService().fetchActivity().then((a) {
      if (mounted) setState(() => _items = a ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
        title: const Text('Activité'),
      ),
      body: _items == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : _items!.isEmpty
              ? const EmptyState(title: 'Aucune activité pour l’instant')
              : ListView(children: [for (final a in _items!) ActivityTile(item: a)]),
    );
  }
}

/// « Tout voir » de la section Messages.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ApiService().fetchConversations();
    if (mounted) setState(() => _items = c ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
        title: const Text('Messages'),
        actions: [
          PinIconButton(
            PinIcons.compose,
            tooltip: 'Nouveau message',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewMessageScreen()))
                .then((_) => _load()),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _items == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : _items!.isEmpty
              ? EmptyState(
                  title: 'Aucun message',
                  message: 'Partagez des idées avec vos amis en leur envoyant un message.',
                  actionLabel: 'Nouveau message',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewMessageScreen()))
                      .then((_) => _load()),
                )
              : ListView(
                  children: [
                    for (final c in _items!)
                      ConversationTile(
                        conversation: c,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ConversationScreen(conversation: c)),
                        ).then((_) => setState(() {})),
                      ),
                  ],
                ),
    );
  }
}

/// Choix du destinataire d'un nouveau message.
class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<ChatUser>? _users;
  String? _opening;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final users = await _api.searchUsers(q);
    if (mounted) setState(() => _users = users);
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(q));
  }

  Future<void> _open(ChatUser u) async {
    setState(() => _opening = u.username);
    final conv = await _api.openConversation(u.username);
    if (!mounted) return;
    setState(() => _opening = null);
    if (conv == null) return showPinToast(context, 'Impossible d’ouvrir la conversation.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conv)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.close, tooltip: 'Fermer', onPressed: () => Navigator.pop(context)),
        title: const Text('Nouveau message'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PinSearchBar(controller: _ctrl, hint: 'Rechercher par nom', autofocus: true, onChanged: _onChanged),
          ),
          Expanded(
            child: _users == null
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                : _users!.isEmpty
                    ? EmptyState(title: 'Aucun résultat', message: 'Personne ne correspond à « ${_ctrl.text} ».')
                    : ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text('Suggestions',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.textMuted)),
                          ),
                          for (final u in _users!)
                            InkWell(
                              onTap: _opening == null ? () => _open(u) : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    PinAvatar(url: u.avatarUrl, name: u.name, size: 48),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.name,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          Text('@${u.username}', style: TextStyle(fontSize: 14, color: p.textMuted)),
                                        ],
                                      ),
                                    ),
                                    if (_opening == u.username)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.2, color: GestaltTheme.pinterestRed),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
