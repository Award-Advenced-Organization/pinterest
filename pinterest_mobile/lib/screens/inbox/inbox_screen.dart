import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Boîte de réception',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Section 1: Activité
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Activité', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Icon(Icons.chevron_right, size: 20, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Item 1: Alassanemomo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5D8FC), // Soft purple/periwinkle from screenshot
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 15, height: 1.3),
                            children: [
                              TextSpan(text: 'Vous connaissez peut-être ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: 'Alassanemomo', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: '   1 sem.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GestaltTheme.softGrey,
                            foregroundColor: GestaltTheme.textDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('S’abonner', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Item 2: Zora
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('ZORA', style: TextStyle(color: Color(0xFFE5C158), fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 15, height: 1.3),
                            children: [
                              TextSpan(text: 'zora est abonné(e) à vos Épingles', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: '   03/26', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GestaltTheme.softGrey,
                            foregroundColor: GestaltTheme.textDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Saluer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Section 2: Messages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Messages', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Icon(Icons.chevron_right, size: 20, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: GestaltTheme.softGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_add_alt_1_outlined, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contacter un utilisateur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Connectez-vous pour entamer une discussion', style: TextStyle(color: GestaltTheme.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Section 3: Mises à jour
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Mises à jour', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            ),
            const SizedBox(height: 8),
            // Notif 1
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: GestaltTheme.softGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Web Site Motion Design.',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                        ),
                        const SizedBox(height: 4),
                        Text('07/26', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                ],
              ),
            ),
            // Notif 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: GestaltTheme.softGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vous n’avez pas encore trouvé ce qu’il vous faut ? Explorez les idées associées à Naruto guide.',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                        ),
                        const SizedBox(height: 4),
                        Text('07/26', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
