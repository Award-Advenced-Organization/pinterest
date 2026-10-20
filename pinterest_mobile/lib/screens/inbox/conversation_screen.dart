import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/conversation.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../pin_detail/pin_detail_screen.dart';
import '../profile/user_profile_screen.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  const ConversationScreen({super.key, required this.conversation});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  Conversation get _conv => widget.conversation;
  List<ChatMessage> get _messages => _conv.messages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _send({Pin? pin}) async {
    final text = pin == null ? _controller.text.trim() : '';
    if ((text.isEmpty && pin == null) || _sending) return;
    final optimistic = ChatMessage(from: 'me', text: text, time: _now(), pinId: pin?.id, pinImage: pin?.imageUrl);
    setState(() {
      _messages.add(optimistic);
      if (pin == null) _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    final saved = await _api.sendMessage(_conv.id, text, pinId: pin?.id);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (saved == null) {
        _messages.remove(optimistic);
      } else {
        _conv
          ..lastMessage = text.isEmpty ? 'A envoyé une Épingle' : text
          ..timeAgo = 'À l’instant';
      }
    });
    if (saved == null) {
      showPinToast(context, 'Échec de l’envoi. Réessayez.');
    } else {
      AppState.dataChanged();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _pickPin() async {
    final pin = await showPinSheet<Pin>(
      context,
      title: 'Envoyer une Épingle',
      fullHeight: true,
      builder: (_) => const _SavedPinPicker(),
    );
    if (pin != null) _send(pin: pin);
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(username: _conv.withUser.username)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final user = _conv.withUser;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
        title: Pressable(
          onTap: _openProfile,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinAvatar(url: user.avatarUrl, name: user.name, size: 32),
              const SizedBox(width: 10),
              Flexible(child: Text(user.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        actions: [
          PinIconButton(PinIcons.info, tooltip: 'Voir le profil', onPressed: _openProfile),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyHeader(user, p)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) => _Bubble(message: _messages[i]),
                  ),
          ),
          _InputBar(controller: _controller, onSend: () => _send(), onAttach: _pickPin),
        ],
      ),
    );
  }

  Widget _emptyHeader(ChatUser user, PinPalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinAvatar(url: user.avatarUrl, name: user.name, size: 88),
            const SizedBox(height: 14),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('@${user.username}', style: TextStyle(color: p.textMuted, fontSize: 14)),
            const SizedBox(height: 16),
            Text(
              'Envoyez un message ou une Épingle pour démarrer la conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  Future<void> _openPin(BuildContext context) async {
    final d = await ApiService().fetchPinDetail(message.pinId!);
    if (d == null || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PinDetailScreen(pin: Pin.fromJson(d), heroTag: 'msg_${message.pinId}_${message.time}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final mine = message.isMine;
    final maxW = MediaQuery.sizeOf(context).width * 0.72;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.pinImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Pressable(
                onTap: message.pinId == null ? null : () => _openPin(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PinNetImage(message.pinImage!, width: 180, height: 230),
                ),
              ),
            ),
          if (message.text.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: maxW),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? p.text : p.secondaryButton,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(message.text, style: TextStyle(color: mine ? p.bg : p.text, fontSize: 15, height: 1.3)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(message.time, style: TextStyle(fontSize: 11, color: p.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _InputBar({required this.controller, required this.onSend, required this.onAttach});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.divider))),
        child: Row(
          children: [
            PinIconButton(PinIcons.plus, tooltip: 'Envoyer une Épingle', onPressed: onAttach),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: p.border), borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(fontSize: 15, color: p.text),
                  decoration: InputDecoration(
                    hintText: 'Envoyer un message',
                    hintStyle: TextStyle(color: p.placeholder, fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final active = value.text.trim().isNotEmpty;
                return PinIconButton(
                  PinIcons.send,
                  size: 44,
                  iconSize: 20,
                  tooltip: 'Envoyer',
                  color: active ? Colors.white : p.textMuted,
                  background: active ? GestaltTheme.pinterestRed : p.secondaryButton,
                  onPressed: active ? onSend : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Grille des Épingles enregistrées pour en joindre une à un message.
class _SavedPinPicker extends StatefulWidget {
  const _SavedPinPicker();

  @override
  State<_SavedPinPicker> createState() => _SavedPinPickerState();
}

class _SavedPinPickerState extends State<_SavedPinPicker> {
  List<Pin>? _pins;

  @override
  void initState() {
    super.initState();
    ApiService().fetchSavedPins().then((p) {
      if (mounted) setState(() => _pins = p ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pins == null) return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    if (_pins!.isEmpty) return const EmptyState(title: 'Aucune Épingle enregistrée');
    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      itemCount: _pins!.length,
      itemBuilder: (_, i) {
        final pin = _pins![i];
        return Pressable(
          onTap: () => Navigator.pop(context, pin),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
                aspectRatio: pin.aspectRatio.clamp(0.5, 1.8), child: PinNetImage(pin.imageUrl, placeholder: pin.color)),
          ),
        );
      },
    );
  }
}
