import 'package:flutter/material.dart';

import '../theme/jetons.dart';

/// Les initiales sur une teinte tiree du nom : chaque membre garde la sienne.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.nom, this.taille = 46});

  final String nom;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final initiales = nom.split(RegExp(r'\s+')).where((m) => m.isNotEmpty).take(2).map((m) => m[0].toUpperCase()).join();
    final teinte = (nom.codeUnits.fold<int>(0, (a, b) => a + b) * 47) % 360;
    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Couleurs.hsl(teinte.toDouble(), 55, 48), shape: BoxShape.circle),
      child: Text(
        initiales,
        style: TextStyle(fontSize: taille * 0.34, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
