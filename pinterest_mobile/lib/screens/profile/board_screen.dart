import 'package:flutter/material.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../models/board.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

class BoardScreen extends StatefulWidget {
  final Board board;
  const BoardScreen({super.key, required this.board});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _api = ApiService();
  late Board _board = widget.board;
  List<Pin>? _pins;

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
    final pins = await _api.fetchBoardPins(_board.id);
    final boards = await _api.fetchBoards();
    if (!mounted) return;
    final fresh = boards?.where((b) => b.id == _board.id).firstOrNull;
    setState(() {
      _pins = pins ?? [];
      if (fresh != null) _board = fresh;
    });
  }

  void _more() {
    showPinSheet(
      context,
      title: 'Options du tableau',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          SheetOption('Modifier le tableau', onTap: () {
            Navigator.pop(ctx);
            _edit();
          }),
          SheetOption('Supprimer le tableau', destructive: true, onTap: () {
            Navigator.pop(ctx);
            _delete();
          }),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final updated = await showPinSheet<Board>(
      context,
      title: 'Modifier le tableau',
      builder: (_) => _EditBoardForm(board: _board),
    );
    if (updated == null || !mounted) return;
    setState(() => _board = updated);
    AppState.dataChanged();
  }

  Future<void> _delete() async {
    final ok = await confirmPin(
      context,
      title: 'Supprimer ce tableau ?',
      message: 'Le tableau « ${_board.name} » et ses Épingles enregistrées seront supprimés de votre profil.',
      confirmLabel: 'Supprimer',
    );
    if (!ok || !mounted) return;
    if (await _api.deleteBoard(_board.id)) {
      AppState.dataChanged();
      if (!mounted) return;
      Navigator.pop(context);
      showPinToast(context, 'Tableau supprimé');
    } else if (mounted) {
      showPinToast(context, 'Suppression impossible. Réessayez.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final count = _pins?.length ?? _board.pinCount;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
        actions: [
          PinIconButton(PinIcons.ellipsis, iconSize: 22, tooltip: 'Options du tableau', onPressed: _more),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  Text(_board.name,
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  if (_board.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(_board.description,
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: p.textMuted)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_board.secret) ...[
                        PinIcon(PinIcons.lock, size: 15, color: p.textMuted),
                        const SizedBox(width: 6),
                        Text('Secret · ', style: TextStyle(fontSize: 14, color: p.textMuted)),
                      ],
                      Text('$count Épingle${count > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 14, color: p.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_pins == null)
            const SliverPinSkeleton(count: 6)
          else if (_pins!.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                title: 'Ce tableau est vide',
                message: 'Enregistrez des Épingles ici depuis l’accueil ou la recherche.',
              ),
            )
          else
            SliverPinGrid(pins: _pins!, heroScope: 'board_${_board.id}', onChanged: _load),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _EditBoardForm extends StatefulWidget {
  final Board board;
  const _EditBoardForm({required this.board});

  @override
  State<_EditBoardForm> createState() => _EditBoardFormState();
}

class _EditBoardFormState extends State<_EditBoardForm> {
  late final _name = TextEditingController(text: widget.board.name);
  late final _desc = TextEditingController(text: widget.board.description);
  late bool _secret = widget.board.secret;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ApiService()
        .updateBoard(widget.board.id, name: _name.text.trim(), secret: _secret, description: _desc.text.trim());
    if (!mounted) return;
    if (r.ok) return Navigator.pop(context, r.data);
    setState(() {
      _saving = false;
      _error = r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PinField(
              label: 'Nom',
              controller: _name,
              labelInside: false,
              errorText: _error,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 16),
          PinField(
              label: 'Description',
              controller: _desc,
              labelInside: false,
              hint: 'De quoi parle votre tableau ?',
              maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Garder ce tableau secret', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Vous seul pouvez le voir.', style: TextStyle(fontSize: 14, color: p.textMuted)),
                  ],
                ),
              ),
              Switch(value: _secret, onChanged: (v) => setState(() => _secret = v)),
            ],
          ),
          const SizedBox(height: 20),
          PinButton(
            'Terminé',
            kind: PinButtonKind.red,
            large: true,
            expand: true,
            loading: _saving,
            onPressed: _name.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }
}
