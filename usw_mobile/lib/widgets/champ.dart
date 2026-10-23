import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jetons.dart';
import '../theme/theme.dart';
import 'icone.dart';
import 'verre.dart';

/// Un champ de formulaire en verre : libelle au-dessus, icone a gauche,
/// bord ocean quand il a la main, aide ou erreur en dessous.
class ChampVerre extends StatefulWidget {
  const ChampVerre({
    super.key,
    this.libelle,
    required this.icone,
    this.indice,
    this.controleur,
    this.aide,
    this.erreur,
    this.secret = false,
    this.clavier,
    this.action,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.facultatif = false,
    this.lignes = 1,
    this.remplissage,
    this.suffixe,
  });

  /// Le nom au-dessus du champ. Sans lui, l indice seul dit quoi ecrire :
  /// les pages de compte n ont qu un champ, son indice suffit.
  final String? libelle;
  final String icone;
  final String? indice;
  final TextEditingController? controleur;
  final Widget? aide;
  final String? erreur;
  final bool secret;
  final TextInputType? clavier;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool facultatif;
  final int lignes;
  final Iterable<String>? remplissage;
  final Widget? suffixe;

  @override
  State<ChampVerre> createState() => _ChampVerreState();
}

class _ChampVerreState extends State<ChampVerre> {
  final _focus = FocusNode();
  bool _cache = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erreur = widget.erreur != null;
    final actif = _focus.hasFocus;
    final bord = erreur ? Couleurs.erreur : (actif ? Couleurs.ocean : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.libelle != null) ...[
          Text.rich(
            TextSpan(
              text: widget.libelle,
              style: Textes.libelle,
              children: [
                if (widget.facultatif)
                  TextSpan(
                    text: '  facultatif',
                    style: Textes.petit.copyWith(fontWeight: FontWeight.w400),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: Durees.interface,
          curve: Courbes.interface,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Mesures.rayonBouton + 2),
            border: Border.all(color: bord ?? Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.all(1),
          child: Verre(
            ombre: !actif,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: widget.lignes > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: widget.lignes > 1 ? 15 : 0),
                    child: Icone(widget.icone, taille: 22, couleur: erreur ? Couleurs.erreur : Couleurs.discret),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: widget.controleur,
                      focusNode: _focus,
                      autofocus: widget.autofocus,
                      obscureText: widget.secret && _cache,
                      keyboardType: widget.clavier,
                      textInputAction: widget.action,
                      onSubmitted: widget.onSubmitted,
                      onChanged: widget.onChanged,
                      autofillHints: widget.remplissage,
                      minLines: widget.lignes,
                      maxLines: widget.secret ? 1 : widget.lignes,
                      style: TextStyle(fontSize: 16, color: Couleurs.texte),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.indice,
                        hintStyle: TextStyle(fontSize: 16, color: Couleurs.discret.withValues(alpha: 0.8), fontWeight: FontWeight.w300),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (widget.suffixe != null) widget.suffixe!,
                  if (widget.secret)
                    GestureDetector(
                      onTap: () => setState(() => _cache = !_cache),
                      child: Semantics(
                        button: true,
                        label: _cache ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icone(_cache ? 'oeil' : 'oeil-barre', taille: 22, couleur: Couleurs.discret),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (erreur) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              Icone('alerte', taille: 15, couleur: Couleurs.erreur),
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.erreur!, style: Textes.petit.copyWith(color: Couleurs.erreur)),
              ),
            ],
          ),
        ] else if (widget.aide != null) ...[
          const SizedBox(height: 7),
          DefaultTextStyle.merge(style: Textes.petit, child: widget.aide!),
        ],
      ],
    );
  }
}

/// Les criteres d un mot de passe, coches au fur et a mesure.
class Criteres extends StatelessWidget {
  const Criteres({super.key, required this.criteres});

  final List<(String, bool)> criteres;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final (texte, ok) in criteres)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Durees.interface,
                width: 18,
                height: 18,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: ok ? Couleurs.succes : Couleurs.voile.withValues(alpha: 0.1)),
                child: Icone('coche', taille: 14, couleur: ok ? Colors.white : Colors.transparent),
              ),
              const SizedBox(width: 8),
              Text(texte, style: TextStyle(fontSize: 14, color: ok ? Couleurs.texte : Couleurs.discret)),
            ],
          ),
        ),
    ],
  );
}

/// Le code a six chiffres, une case de verre par chiffre.
class ChampCode extends StatefulWidget {
  const ChampCode({super.key, required this.onComplet, this.onChanged});

  final ValueChanged<String> onComplet;
  final ValueChanged<String>? onChanged;

  @override
  State<ChampCode> createState() => _ChampCodeState();
}

class _ChampCodeState extends State<ChampCode> {
  final _controleur = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controleur.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controleur.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          // Le vrai champ, invisible : il garde le clavier et le collage du code recu.
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 60,
              child: TextField(
                controller: _controleur,
                focusNode: _focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                onChanged: (v) {
                  setState(() {});
                  widget.onChanged?.call(v);
                  if (v.length == 6) widget.onComplet(v);
                },
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AnimatedContainer(
                    duration: Durees.interface,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: i == code.length && _focus.hasFocus ? Couleurs.ocean : Colors.transparent, width: 2),
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Verre(
                      child: Center(
                        child: Text(
                          i < code.length ? code[i] : '',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Couleurs.texte),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Un lien de texte, en ocean.
class Lien extends StatelessWidget {
  const Lien(this.texte, {super.key, this.onTap, this.discret = false});

  final String texte;
  final VoidCallback? onTap;
  final bool discret;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Semantics(
      link: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(texte, style: discret ? Textes.lien.copyWith(color: Couleurs.discret) : Textes.lien),
      ),
    ),
  );
}
