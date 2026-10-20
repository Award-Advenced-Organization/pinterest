import 'package:flutter/material.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../core/theme/gestalt_theme.dart';
import '../create/create_pin_screen.dart';

class _Metric {
  final PinIcons icon;
  final String label;
  final String help;
  const _Metric(this.icon, this.label, this.help);
}

const _performance = [
  _Metric(PinIcons.eye, 'Impressions', 'Nombre de fois où vos Épingles ont été affichées à l’écran.'),
  _Metric(PinIcons.hand, 'Engagements',
      'Nombre total d’interactions avec vos Épingles : clics, enregistrements, réactions.'),
  _Metric(PinIcons.arrowUpRight, 'Clics sortants', 'Nombre de clics vers le site lié à vos Épingles.'),
  _Metric(PinIcons.bookmarkFill, 'Épingles enregistrées',
      'Nombre de fois où d’autres personnes ont enregistré vos Épingles.'),
  _Metric(PinIcons.people, 'Audience totale', 'Nombre de personnes ayant vu vos Épingles.'),
  _Metric(PinIcons.people, 'Audience engagée', 'Nombre de personnes ayant interagi avec vos Épingles.'),
];

const _audience = [
  _Metric(PinIcons.people, 'Audience totale', 'Nombre de personnes ayant vu vos Épingles sur la période.'),
  _Metric(PinIcons.people, 'Audience mensuelle',
      'Nombre de personnes ayant vu vos Épingles au cours des 30 derniers jours.'),
  _Metric(PinIcons.people, 'Audience engagée', 'Nombre de personnes ayant interagi avec vos Épingles.'),
];

/// Statistiques (Hub des créateurs) : cartes claires séparées par des bandes noires, comme sur la capture.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _tab = 0;
  int _days = 30;

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _range {
    final end = DateTime.now();
    return '${_fmt(end.subtract(Duration(days: _days)))} - ${_fmt(end)}, Organique';
  }

  Future<void> _choosePeriod() async {
    final days = await showPinSheet<int>(
      context,
      title: 'Période',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          for (final d in [7, 14, 30, 90])
            InkWell(
              onTap: () => Navigator.pop(ctx, d),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('$d derniers jours',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    if (d == _days) const PinIcon(PinIcons.check, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (days != null) setState(() => _days = days);
  }

  void _explain(_Metric m) {
    showPinSheet(
      context,
      title: m.label,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Text(m.help, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.45)),
      ),
    );
  }

  void _help() {
    showPinSheet(
      context,
      title: 'Aide',
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Text(
          'Les statistiques se mettent à jour une fois par jour. Les valeurs restent à 0 tant que vos Épingles '
          'n’ont pas été vues par d’autres personnes. Créez et partagez des Épingles pour commencer à recevoir des données.',
          style: TextStyle(fontSize: 16, height: 1.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final card = context.isDark ? p.sheet : p.bg;
    final metrics = _tab == 0 ? _performance : _audience;
    return Scaffold(
      backgroundColor: p.statsBackdrop,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Card(
            color: card,
            topFlat: true,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      PinIconButton(PinIcons.back,
                          iconSize: 26, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: PinTextTabs(
                          labels: const ['Statistiques', 'Audience'],
                          index: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                          fontSize: 18,
                        ),
                      ),
                      PinIconButton(PinIcons.filter, iconSize: 26, tooltip: 'Période', onPressed: _choosePeriod),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('$_days derniers jours', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_range, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 18),
                  Text(
                    _tab == 0 ? 'Performances globales' : 'Votre audience',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: p.divider),
                    _metricRow(metrics[i], p),
                  ],
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _tab == 0
                          ? 'Les changements en pourcentage sont comparés à $_days jours avant la période ci-dessus.'
                          : 'Il n’y a pas encore assez de données d’audience. Revenez quand vos Épingles auront été vues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: p.textMuted, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _Card(
            color: card,
            child: Column(
              children: [
                const Text('Meilleures Épingles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Triées par impressions', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                const Text(
                  'Aucune Épingle ne correspond à votre sélection de filtres. Pour afficher les données de performance, '
                  'essayez de créer une Épingle pour l’audience que vous souhaitez atteindre.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45),
                ),
                const SizedBox(height: 16),
                PinButton(
                  'Créer une Épingle',
                  kind: PinButtonKind.red,
                  large: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePinScreen(), fullscreenDialog: true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Card(
            color: card,
            child: Column(
              children: [
                const Text('À propos de ces données', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const Text(
                  'Les données rapportées ici sont une estimation. Certains graphiques nécessitent un nombre minimum '
                  'd’utilisateurs pour être affichés. Les données quotidiennes sont enregistrées en heure UTC.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45),
                ),
                const SizedBox(height: 16),
                PinButton('Obtenir de l’aide', large: true, onPressed: _help),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }

  Widget _metricRow(_Metric m, PinPalette p) {
    return InkWell(
      onTap: () => _explain(m),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            PinIcon(m.icon, size: 22, strokeWidth: 1.8),
            const SizedBox(width: 14),
            Expanded(child: Text(m.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
            const Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            PinIcon(PinIcons.chevronRight, size: 16, color: p.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool topFlat;
  const _Card({required this.child, required this.color, this.topFlat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: topFlat ? EdgeInsets.zero : const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topFlat ? 0 : 40),
          bottom: const Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}
