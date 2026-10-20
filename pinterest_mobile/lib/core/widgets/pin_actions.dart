import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/board.dart';
import '../../models/conversation.dart';
import '../../models/pin.dart';
import '../../screens/create/create_board_screen.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../constants/api_endpoints.dart';
import '../theme/gestalt_theme.dart';
import 'pin_icon.dart';
import 'ui.dart';

/// Actions communes à toutes les Épingles : enregistrer, choisir un tableau, partager, masquer, signaler.
class PinActions {
  PinActions._();

  static final _api = ApiService();

  /// Contexte encore valide après la fermeture d'une feuille ou le recyclage d'une carte.
  static BuildContext _root(BuildContext context) => Navigator.of(context, rootNavigator: true).context;

  /// Enregistre dans le profil (« Idées non organisées »), puis propose de choisir un tableau.
  static Future<void> quickSave(BuildContext context, Pin pin, {VoidCallback? onChanged}) async {
    final root = _root(context);
    final r = await _api.savePin(pin.id);
    if (!root.mounted) return;
    if (!r.ok) return showPinToast(root, r.error!);
    pin
      ..isSaved = true
      ..boardId = null;
    onChanged?.call();
    AppState.dataChanged();
    showPinToast(
      root,
      'Enregistrée dans votre profil',
      imageUrl: pin.imageUrl,
      actionLabel: 'Modifier',
      onAction: () => pickBoard(root, pin, onChanged: onChanged),
    );
  }

  static Future<void> unsave(BuildContext context, Pin pin, {VoidCallback? onChanged}) async {
    final root = _root(context);
    final previousBoard = pin.boardId;
    if (!await _api.unsavePin(pin.id)) {
      if (root.mounted) showPinToast(root, 'Impossible de retirer l’Épingle. Réessayez.');
      return;
    }
    pin
      ..isSaved = false
      ..boardId = null;
    onChanged?.call();
    AppState.dataChanged();
    if (!root.mounted) return;
    showPinToast(
      root,
      'Épingle retirée de votre profil',
      imageUrl: pin.imageUrl,
      actionLabel: 'Annuler',
      onAction: () async {
        final r = await _api.savePin(pin.id, boardId: previousBoard);
        if (!r.ok) return;
        pin
          ..isSaved = true
          ..boardId = previousBoard;
        onChanged?.call();
        AppState.dataChanged();
      },
    );
  }

  /// Liste des tableaux avec « Créer un tableau » ; renvoie le tableau choisi.
  static Future<Board?> chooseBoard(BuildContext context,
      {String? currentBoardId, String title = 'Enregistrer dans un tableau'}) {
    return showPinSheet<Board>(context, title: title, builder: (_) => _BoardPicker(currentBoardId: currentBoardId));
  }

  /// Feuille « Enregistrer dans un tableau ».
  static Future<void> pickBoard(BuildContext context, Pin pin, {VoidCallback? onChanged}) async {
    final root = _root(context);
    final board = await chooseBoard(root, currentBoardId: pin.boardId);
    if (board == null || !root.mounted) return;
    final r = await _api.savePin(pin.id, boardId: board.id);
    if (!root.mounted) return;
    if (!r.ok) return showPinToast(root, r.error!);
    pin
      ..isSaved = true
      ..boardId = board.id;
    onChanged?.call();
    AppState.dataChanged();
    showPinToast(root, 'Enregistrée dans « ${board.name} »', imageUrl: pin.imageUrl);
  }

  static Future<void> share(BuildContext context, Pin pin) {
    return showPinSheet(_root(context), title: 'Partager', builder: (ctx) => _ShareSheet(pin: pin));
  }

  static Future<void> hide(BuildContext context, Pin pin,
      {required VoidCallback onHidden, VoidCallback? onRestored}) async {
    final root = _root(context);
    onHidden();
    await _api.hidePin(pin.id);
    if (!root.mounted) return;
    showPinToast(
      root,
      'Épingle masquée. Vous verrez moins d’Épingles de ce type.',
      actionLabel: 'Annuler',
      onAction: () async {
        if (await _api.unhidePin(pin.id)) onRestored?.call();
      },
    );
  }

  /// Menu « … » d'une Épingle.
  static Future<void> showOptions(
    BuildContext context,
    Pin pin, {
    VoidCallback? onChanged,
    VoidCallback? onHidden,
    VoidCallback? onRestored,
    VoidCallback? onDelete,
  }) {
    final root = _root(context);
    return showPinSheet(
      root,
      title: 'Options',
      builder: (ctx) {
        void then(VoidCallback f) {
          Navigator.pop(ctx);
          f();
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            if (pin.isSaved) ...[
              SheetOption('Changer de tableau', onTap: () => then(() => pickBoard(root, pin, onChanged: onChanged))),
              SheetOption('Retirer de votre profil', onTap: () => then(() => unsave(root, pin, onChanged: onChanged))),
            ] else
              SheetOption('Enregistrer', onTap: () => then(() => quickSave(root, pin, onChanged: onChanged))),
            SheetOption('Partager', onTap: () => then(() => share(root, pin))),
            SheetOption(
              'Copier le lien de l’image',
              onTap: () => then(() async {
                await Clipboard.setData(ClipboardData(text: ApiEndpoints.resolveUrl(pin.imageUrl)));
                if (root.mounted) showPinToast(root, 'Lien copié');
              }),
            ),
            if (onHidden != null)
              SheetOption(
                'Masquer l’Épingle',
                subtitle: 'Vous verrez moins d’Épingles de ce type',
                onTap: () => then(() => hide(root, pin, onHidden: onHidden, onRestored: onRestored)),
              ),
            if (onDelete != null)
              SheetOption('Supprimer l’Épingle', destructive: true, onTap: () => then(onDelete))
            else
              SheetOption('Signaler l’Épingle', onTap: () => then(() => report(root, pin, onHidden: onHidden))),
          ],
        );
      },
    );
  }

  static Future<void> report(BuildContext context, Pin pin, {VoidCallback? onHidden}) async {
    const reasons = [
      'Spam',
      'Nudité ou pornographie',
      'Automutilation',
      'Fausses informations',
      'Activités haineuses',
      'Violence explicite',
      'Atteinte à la propriété intellectuelle',
    ];
    final reason = await showPinSheet<String>(
      context,
      title: 'Signaler l’Épingle',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [for (final r in reasons) SheetOption(r, onTap: () => Navigator.pop(ctx, r))],
      ),
    );
    if (reason == null || !context.mounted) return;
    onHidden?.call();
    await _api.hidePin(pin.id);
    if (context.mounted) showPinToast(context, 'Merci pour votre signalement. Cette Épingle a été masquée.');
  }
}

class _BoardPicker extends StatefulWidget {
  final String? currentBoardId;
  const _BoardPicker({this.currentBoardId});

  @override
  State<_BoardPicker> createState() => _BoardPickerState();
}

class _BoardPickerState extends State<_BoardPicker> {
  List<Board>? _boards;

  @override
  void initState() {
    super.initState();
    ApiService().fetchBoards().then((b) {
      if (mounted) setState(() => _boards = b ?? []);
    });
  }

  Future<void> _create() async {
    final board = await Navigator.push<Board>(
      context,
      MaterialPageRoute(builder: (_) => const CreateBoardScreen(), fullscreenDialog: true),
    );
    if (board != null && mounted) Navigator.pop(context, board);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    if (_boards == null) {
      return const Padding(
          padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)));
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (_boards!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Text(
              'Vous n’avez pas encore de tableau. Créez-en un pour ranger cette Épingle.',
              style: TextStyle(color: p.textMuted, fontSize: 14),
            ),
          ),
        for (final b in _boards!)
          _row(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PinNetImage(b.coverImages.isEmpty ? '' : b.coverImages.first, width: 52, height: 52),
            ),
            title: b.name,
            trailing: b.id == widget.currentBoardId
                ? PinIcon(PinIcons.check, size: 20, color: p.text)
                : b.secret
                    ? PinIcon(PinIcons.lock, size: 18, color: p.textMuted)
                    : null,
            onTap: () => Navigator.pop(context, b),
          ),
        _row(
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: p.secondaryButton, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const PinIcon(PinIcons.plus, size: 24),
          ),
          title: 'Créer un tableau',
          onTap: _create,
        ),
      ],
    );
  }

  Widget _row({required Widget leading, required String title, Widget? trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  final Pin pin;
  const _ShareSheet({required this.pin});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _api = ApiService();
  List<ChatUser>? _users;
  final Set<String> _sent = {};

  @override
  void initState() {
    super.initState();
    _api.searchUsers('').then((u) {
      if (mounted) setState(() => _users = u);
    });
  }

  Future<void> _sendTo(ChatUser u) async {
    if (_sent.contains(u.username)) return;
    setState(() => _sent.add(u.username));
    final conv = await _api.openConversation(u.username);
    final msg = conv == null ? null : await _api.sendMessage(conv.id, '', pinId: widget.pin.id);
    if (!mounted) return;
    if (msg == null) {
      setState(() => _sent.remove(u.username));
      showPinToast(context, 'Envoi impossible. Réessayez.');
    } else {
      AppState.dataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Envoyer à', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 104,
            child: _users == null
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _target(
                        circle: Container(
                          decoration: BoxDecoration(color: p.secondaryButton, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const PinIcon(PinIcons.link, size: 26),
                        ),
                        label: 'Copier le lien',
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: ApiEndpoints.resolveUrl(widget.pin.imageUrl)));
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          showPinToast(context, 'Lien copié');
                        },
                      ),
                      for (final u in _users!)
                        _target(
                          circle: Stack(
                            children: [
                              PinAvatar(url: u.avatarUrl, name: u.name, size: 60),
                              if (_sent.contains(u.username))
                                Container(
                                  decoration: const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const PinIcon(PinIcons.check, size: 26, color: Colors.white),
                                ),
                            ],
                          ),
                          label: _sent.contains(u.username) ? 'Envoyé' : u.name,
                          onTap: () => _sendTo(u),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _target({required Widget circle, required String label, required VoidCallback onTap}) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            SizedBox(width: 60, height: 60, child: circle),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
