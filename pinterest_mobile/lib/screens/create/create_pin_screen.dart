import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_actions.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/board.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../services/image_picking.dart';

/// « Créer une Épingle » : image de l'appareil, titre, description, lien et tableau.
class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _api = ApiService();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _link = TextEditingController();
  PickedImage? _image;
  Board? _board;
  bool _publishing = false;
  String? _linkError;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final image = await pickImage();
    if (image != null && mounted) setState(() => _image = image);
  }

  Future<void> _chooseBoard() async {
    final b = await PinActions.chooseBoard(context, currentBoardId: _board?.id, title: 'Choisir un tableau');
    if (b != null && mounted) setState(() => _board = b);
  }

  Future<void> _publish() async {
    var link = _link.text.trim();
    if (link.isNotEmpty && !link.startsWith('http')) link = 'https://$link';
    if (link.isNotEmpty && Uri.tryParse(link)?.host.contains('.') != true) {
      return setState(() => _linkError = 'Ce lien ne semble pas valide.');
    }
    setState(() {
      _publishing = true;
      _linkError = null;
    });
    final r = await _api.createPin(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      link: link,
      boardId: _board?.id,
      image: _image,
    );
    if (!mounted) return;
    setState(() => _publishing = false);
    if (!r.ok) return showPinToast(context, r.error!);
    AppState.dataChanged();
    Navigator.pop(context);
    showPinToast(
      context,
      _board == null ? 'Épingle publiée sur votre profil' : 'Épingle publiée dans « ${_board!.name} »',
      imageUrl: r.data!.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.close, tooltip: 'Fermer', onPressed: () => Navigator.pop(context)),
        title: const Text('Créer une Épingle'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Center(child: _imageArea(p)),
                  const SizedBox(height: 24),
                  PinField(
                      label: 'Titre',
                      labelInside: false,
                      controller: _title,
                      hint: 'Indiquez un titre',
                      maxLength: 100),
                  const SizedBox(height: 18),
                  PinField(
                    label: 'Description',
                    labelInside: false,
                    controller: _desc,
                    hint: 'Ajoutez une description détaillée',
                    maxLines: 4,
                    maxLength: 800,
                  ),
                  const SizedBox(height: 18),
                  PinField(
                    label: 'Lien',
                    labelInside: false,
                    controller: _link,
                    hint: 'Ajoutez un lien',
                    keyboardType: TextInputType.url,
                    errorText: _linkError,
                    onChanged: (_) => setState(() => _linkError = null),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _chooseBoard,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Choisir un tableau',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  _board?.name ?? 'Facultatif : sinon l’Épingle est rangée dans votre profil',
                                  style: TextStyle(fontSize: 14, color: p.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const PinIcon(PinIcons.chevronRight, size: 18, strokeWidth: 2.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PinButton(
                'Publier',
                kind: PinButtonKind.red,
                large: true,
                expand: true,
                loading: _publishing,
                onPressed: _image == null ? null : _publish,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageArea(PinPalette p) {
    final image = _image;
    if (image == null) {
      return Pressable(
        onTap: _pick,
        child: Container(
          width: 240,
          height: 320,
          decoration:
              BoxDecoration(color: p.secondaryButton, borderRadius: BorderRadius.circular(GestaltTheme.cardRadius)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PinIcon(PinIcons.image, size: 40, strokeWidth: 1.7),
              const SizedBox(height: 14),
              const Text('Choisir une image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('JPG ou PNG, jusqu’à 15 Mo', style: TextStyle(fontSize: 13, color: p.textMuted)),
              const SizedBox(height: 16),
              PinButton('Importer', kind: PinButtonKind.dark, onPressed: _pick),
            ],
          ),
        ),
      );
    }
    final ratio = (image.width / image.height).clamp(0.5, 1.8);
    return SizedBox(
      width: 240,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(GestaltTheme.cardRadius),
            child: AspectRatio(aspectRatio: ratio, child: Image.memory(image.bytes, fit: BoxFit.cover)),
          ),
          Positioned(right: 8, bottom: 8, child: PinButton('Changer', onPressed: _pick)),
        ],
      ),
    );
  }
}
