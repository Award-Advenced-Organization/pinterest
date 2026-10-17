import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialUsername;
  final String initialWebsite;

  const EditProfileScreen({
    super.key,
    this.initialName = 'Jaye ahf',
    this.initialUsername = 'ahiffent',
    this.initialWebsite = 'http://ahiffonjephte.me',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController();
    _usernameCtrl = TextEditingController(text: widget.initialUsername);
    _websiteCtrl = TextEditingController(text: widget.initialWebsite);
    _phoneCtrl = TextEditingController(text: '555-555-5555');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _websiteCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Widget _buildRoundedField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow({required String title, required String subtitle}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Modifier le profil', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: GestaltTheme.softGrey,
                foregroundColor: GestaltTheme.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Terminé', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Préservez la confidentialité de vos données personnelles. Les informations que vous ajoutez ici sont visibles par quiconque peut consulter votre profil.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundImage: AssetImage('assets/images/avatar_jaye.jpg'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GestaltTheme.softGrey,
                      foregroundColor: GestaltTheme.textDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildRoundedField(label: 'Nom', controller: _nameCtrl),
            _buildRoundedField(label: 'E-mail', controller: _emailCtrl, hint: 'Adresse e-mail'),
            _buildRoundedField(label: 'Nom d’utilisateur', controller: _usernameCtrl),
            _buildNavRow(
              title: 'Pronoms',
              subtitle: 'Indiquez comment vous souhaitez qu’on vous désigne',
            ),
            _buildNavRow(
              title: 'À propos',
              subtitle: 'Racontez votre histoire',
            ),
            _buildRoundedField(label: 'Site Web', controller: _websiteCtrl),
            const SizedBox(height: 8),
            const Text('Téléphone (public)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Code pays', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Text('Numéro de téléphone (facultatif)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: GestaltTheme.softGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Text('+0', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('0/15', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
