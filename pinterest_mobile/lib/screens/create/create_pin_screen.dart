import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../models/board.dart';
import '../../services/api_service.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();

  List<Board> _boards = [];
  String? _selectedBoardId;
  String _selectedImageUrl = '/pins/10.jpg';
  bool _isPublishing = false;

  final List<String> _sampleImages = [
    '/pins/10.jpg',
    '/pins/11.jpg',
    '/pins/12.jpg',
    '/pins/13.jpg',
    '/pins/14.jpg',
    '/pins/15.jpg',
    '/avatar_jaye.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    final boards = await _api.fetchUserBoards('ahiffent');
    if (mounted) {
      setState(() {
        _boards = boards;
        if (boards.isNotEmpty) _selectedBoardId = boards.first.id;
      });
    }
  }

  Future<void> _publishPin() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter un titre pour votre Épingle')),
      );
      return;
    }

    setState(() => _isPublishing = true);
    final created = await _api.createPin(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      link: _linkCtrl.text.trim().isNotEmpty ? _linkCtrl.text.trim() : null,
      boardId: _selectedBoardId,
      imageUrl: _selectedImageUrl,
    );

    setState(() => _isPublishing = false);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Épingle "${created.title}" publiée avec succès !'),
          backgroundColor: Colors.black87,
        ),
      );
      _titleCtrl.clear();
      _descCtrl.clear();
      _linkCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer une Épingle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publishPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: GestaltTheme.pinterestRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: _isPublishing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Publier', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: GestaltTheme.softGrey,
                borderRadius: BorderRadius.circular(GestaltTheme.cardRadius),
                border: Border.all(color: Colors.grey[300]!, width: 1.5, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text('Sélectionnez un visuel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Image haute résolution (.jpg, .png)', style: TextStyle(color: GestaltTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),
                  // Image picker quick preview chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _sampleImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final img = _sampleImages[i];
                        final isChosen = img == _selectedImageUrl;
                        return ChoiceChip(
                          label: Text('Visuel ${i + 1}'),
                          selected: isChosen,
                          onSelected: (_) => setState(() => _selectedImageUrl = img),
                          selectedColor: GestaltTheme.pinterestRed,
                          labelStyle: TextStyle(color: isChosen ? Colors.white : Colors.black87, fontSize: 11),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title Input
            const Text('Titre', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Ajouter un titre accrocheur',
                filled: true,
                fillColor: GestaltTheme.softGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 18),
            // Description Input
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'De quoi parle votre Épingle ? Expliquez en détail...',
                filled: true,
                fillColor: GestaltTheme.softGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 18),
            // Destination Link Input
            const Text('Lien de destination', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _linkCtrl,
              decoration: InputDecoration(
                hintText: 'https://votresite.com',
                filled: true,
                fillColor: GestaltTheme.softGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 18),
            // Board Selector
            const Text('Tableau', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: GestaltTheme.softGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBoardId,
                  isExpanded: true,
                  hint: const Text('Choisir un tableau'),
                  items: _boards.map((b) {
                    return DropdownMenuItem<String>(
                      value: b.id,
                      child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBoardId = val),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
