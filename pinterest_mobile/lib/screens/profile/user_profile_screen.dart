import 'package:flutter/material.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/pin.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../inbox/conversation_screen.dart';

/// Profil public d'un créateur (ouvert depuis une Épingle ou la boîte de réception).
class UserProfileScreen extends StatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _api = ApiService();
  UserProfile? _user;
  List<Pin> _pins = [];
  bool _loading = true;
  bool _followBusy = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _api.fetchUserProfile(widget.username),
      _api.fetchCreatedPins(widget.username),
    ]);
    if (!mounted) return;
    setState(() {
      _user = results[0] as UserProfile?;
      _pins = (results[1] as List<Pin>?) ?? [];
      _loading = false;
    });
  }

  Future<void> _toggleFollow() async {
    final u = _user;
    if (u == null) return;
    setState(() => _followBusy = true);
    final r = await _api.toggleFollow(u.username);
    if (!mounted) return;
    if (r == null) {
      setState(() => _followBusy = false);
      return showPinToast(context, 'Action impossible. Réessayez.');
    }
    final refreshed = await _api.fetchUserProfile(u.username);
    if (!mounted) return;
    setState(() {
      _user = refreshed ?? u;
      _followBusy = false;
    });
  }

  Future<void> _message() async {
    setState(() => _opening = true);
    final conv = await _api.openConversation(widget.username);
    if (!mounted) return;
    setState(() => _opening = false);
    if (conv == null) return showPinToast(context, 'Impossible d’ouvrir la conversation.');
    Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conv)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final u = _user;
    return Scaffold(
      appBar: AppBar(
        leading: PinIconButton(PinIcons.back, tooltip: 'Retour', onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : u == null
              ? OfflineState(onRetry: () {
                  setState(() => _loading = true);
                  _load();
                })
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          PinAvatar(url: u.avatarUrl, name: u.fullName, size: 112, background: p.avatarMint),
                          const SizedBox(height: 14),
                          Text(u.fullName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('@${u.username}', style: TextStyle(fontSize: 14, color: p.textMuted)),
                          const SizedBox(height: 10),
                          Text(
                            '${u.followerCount} abonné(e)s · ${u.followingCount} abonnements',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PinButton('Message', large: true, loading: _opening, onPressed: _message),
                              const SizedBox(width: 10),
                              PinButton(
                                u.isFollowing ? 'Abonné(e)' : 'S’abonner',
                                large: true,
                                kind: u.isFollowing ? PinButtonKind.dark : PinButtonKind.red,
                                loading: _followBusy,
                                onPressed: _toggleFollow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Créées', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                              width: 52,
                              height: 3,
                              decoration: BoxDecoration(color: p.text, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    if (_pins.isEmpty)
                      const SliverToBoxAdapter(child: EmptyState(title: 'Aucune Épingle pour l’instant'))
                    else
                      SliverPinGrid(pins: _pins, heroScope: 'user_${u.username}'),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
    );
  }
}
