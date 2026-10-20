import 'package:flutter/material.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../services/image_picking.dart';

const _countryCodes = [
  ('Bénin', '+229'),
  ('France', '+33'),
  ('Belgique', '+32'),
  ('Canada', '+1'),
  ('Cameroun', '+237'),
  ('Côte d’Ivoire', '+225'),
  ('Maroc', '+212'),
  ('Sénégal', '+221'),
  ('Suisse', '+41'),
  ('Togo', '+228'),
];

const _pronounChoices = ['elle', 'il', 'iel', 'elles', 'ils'];

/// « Modifier le profil » : s'ouvre en feuille depuis le profil, comme sur la capture.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _api = ApiService();
  UserProfile _initial = UserProfile(id: '', username: '', fullName: '', avatarUrl: '');
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _website = TextEditingController();
  final _phone = TextEditingController();
  String _bio = '';
  List<String> _pronouns = [];
  String _countryCode = '+229';
  bool _ready = false;
  bool _saving = false;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = AppState.user.value;
    if (u != null) {
      _fill(u);
    } else {
      // Ouvert avant la fin du chargement du profil : on attend ses valeurs.
      AppState.loadUser().then((_) {
        final loaded = AppState.user.value;
        if (mounted && loaded != null) setState(() => _fill(loaded));
      });
    }
  }

  void _fill(UserProfile u) {
    _initial = u;
    _name.text = u.fullName;
    _email.text = u.email;
    _username.text = u.username;
    _website.text = u.website;
    _phone.text = u.phone;
    _bio = u.bio;
    _pronouns = [...u.pronouns];
    _countryCode = u.countryCode;
    _ready = true;
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _username, _website, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> get _patch => {
        if (_name.text.trim() != _initial.fullName) 'full_name': _name.text.trim(),
        if (_email.text.trim() != _initial.email) 'email': _email.text.trim(),
        if (_username.text.trim() != _initial.username) 'username': _username.text.trim(),
        if (_website.text.trim() != _initial.website) 'website': _website.text.trim(),
        if (_phone.text.trim() != _initial.phone) 'phone': _phone.text.trim(),
        if (_bio != _initial.bio) 'bio': _bio,
        if (_pronouns.join(',') != _initial.pronouns.join(',')) 'pronouns': _pronouns,
        if (_countryCode != _initial.countryCode) 'country_code': _countryCode,
      };

  Future<void> _save() async {
    final email = _email.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return setState(() => _error = 'Adresse e-mail invalide.');
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await _api.updateMe(_patch);
    if (!mounted) return;
    if (!r.ok) {
      return setState(() {
        _saving = false;
        _error = r.error;
      });
    }
    AppState.setUser(r.data!);
    AppState.dataChanged();
    Navigator.pop(context);
    showPinToast(context, 'Profil enregistré');
  }

  Future<void> _changePhoto() async {
    final image = await pickImage();
    if (image == null || !mounted) return;
    setState(() => _uploading = true);
    final r = await _api.uploadAvatar(image);
    if (!mounted) return;
    setState(() => _uploading = false);
    if (!r.ok) return showPinToast(context, r.error!);
    AppState.setUser(r.data!);
  }

  Future<void> _editPronouns() async {
    final result = await showPinSheet<List<String>>(
      context,
      title: 'Pronoms',
      builder: (_) => _PronounPicker(initial: _pronouns),
    );
    if (result != null) setState(() => _pronouns = result);
  }

  Future<void> _editBio() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => _AboutScreen(initial: _bio), fullscreenDialog: true),
    );
    if (result != null) setState(() => _bio = result);
  }

  Future<void> _pickCountry() async {
    final code = await showPinSheet<String>(
      context,
      title: 'Code pays',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          for (final (name, code) in _countryCodes) SheetOption('$name ($code)', onTap: () => Navigator.pop(ctx, code)),
        ],
      ),
    );
    if (code != null) setState(() => _countryCode = code);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final changed = _ready && _patch.isNotEmpty && _name.text.trim().isNotEmpty;
    return ValueListenableBuilder(
      valueListenable: AppState.user,
      builder: (context, user, _) => Scaffold(
        appBar: AppBar(
          leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
          title: const Text('Modifier le profil'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PinButton('Terminé', kind: PinButtonKind.red, loading: _saving, onPressed: changed ? _save : null),
            ),
          ],
        ),
        body: !_ready
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                children: [
                  Text(
                    'Préservez la confidentialité de vos données personnelles. Les informations que vous ajoutez ici sont '
                    'visibles par quiconque peut consulter votre profil.',
                    style: TextStyle(fontSize: 16, color: p.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PinAvatar(url: user?.avatarUrl ?? '', name: _name.text, size: 128, background: p.avatarMint),
                        if (_uploading)
                          Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle),
                            child:
                                const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: PinButton('Modifier', onPressed: _uploading ? null : _changePhoto)),
                  const SizedBox(height: 28),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: GestaltTheme.pinterestRed, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  PinField(label: 'Nom', controller: _name, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),
                  PinField(
                    label: 'E-mail',
                    controller: _email,
                    hint: 'Adresse e-mail',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  PinField(label: 'Nom d’utilisateur', controller: _username, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  _navRow(
                      'Pronoms',
                      _pronouns.isEmpty ? 'Indiquez comment vous souhaitez qu’on vous désigne' : _pronouns.join(', '),
                      _editPronouns),
                  _navRow('À propos', _bio.isEmpty ? 'Racontez votre histoire' : _bio, _editBio),
                  const SizedBox(height: 8),
                  PinField(
                      label: 'Site Web',
                      controller: _website,
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 28),
                  const Text('Téléphone (public)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Code pays', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Numéro de téléphone (facultatif)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: p.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Pressable(
                        onTap: _pickCountry,
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(color: p.secondaryButton, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Text(_countryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              const PinIcon(PinIcons.chevronDown, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PinField(
                          label: '',
                          labelInside: false,
                          controller: _phone,
                          hint: '555-555-5555',
                          maxLength: 15,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${_phone.text.length}/15', style: TextStyle(fontSize: 13, color: p.textMuted)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _navRow(String title, String subtitle, VoidCallback onTap) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: p.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const PinIcon(PinIcons.chevronRight, size: 18, strokeWidth: 2.4),
          ],
        ),
      ),
    );
  }
}

class _PronounPicker extends StatefulWidget {
  final List<String> initial;
  const _PronounPicker({required this.initial});

  @override
  State<_PronounPicker> createState() => _PronounPickerState();
}

class _PronounPickerState extends State<_PronounPicker> {
  late final List<String> _selected = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Choisissez jusqu’à 2 pronoms. Ils s’afficheront sur votre profil.',
              style: TextStyle(color: p.textMuted, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final pr in _pronounChoices)
                PinButton(
                  pr,
                  kind: _selected.contains(pr) ? PinButtonKind.dark : PinButtonKind.grey,
                  onPressed: () => setState(() {
                    if (_selected.contains(pr)) {
                      _selected.remove(pr);
                    } else if (_selected.length < 2) {
                      _selected.add(pr);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          PinButton('Terminé',
              kind: PinButtonKind.red, large: true, expand: true, onPressed: () => Navigator.pop(context, _selected)),
        ],
      ),
    );
  }
}

class _AboutScreen extends StatefulWidget {
  final String initial;
  const _AboutScreen({required this.initial});

  @override
  State<_AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<_AboutScreen> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
        title: const Text('À propos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PinButton('Terminé',
                kind: PinButtonKind.red, onPressed: () => Navigator.pop(context, _ctrl.text.trim())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PinField(
              label: 'Racontez votre histoire',
              labelInside: false,
              controller: _ctrl,
              hint: 'Parlez de vous, de ce qui vous inspire…',
              maxLines: 6,
              maxLength: 500,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_ctrl.text.length}/500', style: TextStyle(fontSize: 13, color: p.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
