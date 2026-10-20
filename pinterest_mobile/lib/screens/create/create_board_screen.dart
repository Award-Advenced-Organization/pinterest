import 'package:flutter/material.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

/// « Créer un tableau ». Renvoie le tableau créé à l'écran appelant.
class CreateBoardScreen extends StatefulWidget {
  const CreateBoardScreen({super.key});

  @override
  State<CreateBoardScreen> createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends State<CreateBoardScreen> {
  final _name = TextEditingController();
  bool _secret = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ApiService().createBoard(_name.text.trim(), secret: _secret);
    if (!mounted) return;
    if (!r.ok) {
      return setState(() {
        _saving = false;
        _error = r.error;
      });
    }
    AppState.dataChanged();
    Navigator.pop(context, r.data);
    showPinToast(context, 'Tableau « ${r.data!.name} » créé');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.close, tooltip: 'Fermer', onPressed: () => Navigator.pop(context)),
        title: const Text('Créer un tableau'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PinField(
                    label: 'Nom du tableau',
                    labelInside: false,
                    controller: _name,
                    hint: 'Par exemple, « Lieux à visiter » ou « Recettes à cuisiner »',
                    autofocus: true,
                    maxLength: 50,
                    errorText: _error,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Garder ce tableau secret',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Vous seul pouvez le voir.', style: TextStyle(fontSize: 14, color: p.textMuted)),
                          ],
                        ),
                      ),
                      Switch(value: _secret, onChanged: (v) => setState(() => _secret = v)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PinButton(
                'Créer',
                kind: PinButtonKind.red,
                large: true,
                expand: true,
                loading: _saving,
                onPressed: _name.text.trim().isEmpty ? null : _create,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
