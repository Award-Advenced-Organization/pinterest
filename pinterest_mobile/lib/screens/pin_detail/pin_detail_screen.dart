import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/gestalt_theme.dart';
import '../../core/widgets/pin_actions.dart';
import '../../core/widgets/pin_card.dart';
import '../../core/widgets/pin_grid.dart';
import '../../core/widgets/pin_icon.dart';
import '../../core/widgets/ui.dart';
import '../../models/pin.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../profile/user_profile_screen.dart';

class PinDetailScreen extends StatefulWidget {
  final Pin pin;
  final String heroTag;

  const PinDetailScreen({super.key, required this.pin, required this.heroTag});

  @override
  State<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends State<PinDetailScreen> {
  final _api = ApiService();
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();
  final _commentsKey = GlobalKey();

  bool _isMine = false;
  bool _isFollowing = false;
  bool _followBusy = false;
  int? _creatorFollowers;
  bool _posting = false;
  List<Map<String, dynamic>> _comments = [];
  final List<Pin> _related = [];
  bool _loading = true;
  int _page = 0;

  Pin get pin => widget.pin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final d = await _api.fetchPinDetail(pin.id);
    if (!mounted) return;
    if (d == null) {
      setState(() => _loading = false);
      return;
    }
    final fresh = Pin.fromJson(d);
    pin
      ..isSaved = fresh.isSaved
      ..boardId = fresh.boardId
      ..liked = fresh.liked
      ..likeCount = fresh.likeCount
      ..commentCount = fresh.commentCount;
    setState(() {
      _isMine = d['is_mine'] == true;
      _isFollowing = d['is_following'] == true;
      _comments = ((d['comments'] as List<dynamic>?) ?? []).map((c) => Map<String, dynamic>.from(c)).toList();
      _related
        ..clear()
        ..addAll(((d['related_pins'] as List<dynamic>?) ?? []).map((j) => Pin.fromJson(Map<String, dynamic>.from(j))));
      _loading = false;
    });
    if (!_isMine) {
      final creator = await _api.fetchUserProfile(pin.creator.username);
      if (mounted && creator != null) setState(() => _creatorFollowers = creator.followerCount);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _followBusy = true);
    final r = await _api.toggleFollow(pin.creator.username);
    if (!mounted) return;
    setState(() {
      _followBusy = false;
      if (r != null) {
        _isFollowing = r;
        if (_creatorFollowers != null) _creatorFollowers = _creatorFollowers! + (r ? 1 : -1);
      }
    });
    if (r == null) showPinToast(context, 'Action impossible. Réessayez.');
  }

  Future<void> _toggleLike() async {
    // Mise à jour immédiate, corrigée par la réponse du serveur.
    setState(() {
      pin.liked = !pin.liked;
      pin.likeCount += pin.liked ? 1 : -1;
    });
    final r = await _api.toggleLike(pin.id);
    if (!mounted) return;
    if (r == null) {
      setState(() {
        pin.liked = !pin.liked;
        pin.likeCount += pin.liked ? 1 : -1;
      });
      showPinToast(context, 'Action impossible. Réessayez.');
    } else {
      setState(() {
        pin.liked = r.liked;
        pin.likeCount = r.count;
      });
    }
  }

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _posting) return;
    setState(() => _posting = true);
    final created = await _api.postComment(pin.id, text);
    if (!mounted) return;
    setState(() {
      _posting = false;
      if (created != null) {
        _comments.add(created);
        pin.commentCount = _comments.length;
        _commentCtrl.clear();
      }
    });
    if (created == null) {
      showPinToast(context, 'Échec de l’envoi du commentaire.');
    } else {
      _commentFocus.unfocus();
    }
  }

  void _goToComments() {
    final ctx = _commentsKey.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    _commentFocus.requestFocus();
  }

  Future<void> _delete() async {
    final ok = await confirmPin(
      context,
      title: 'Supprimer cette Épingle ?',
      message: 'Elle sera retirée de votre profil et de vos tableaux. Cette action est définitive.',
      confirmLabel: 'Supprimer',
    );
    if (!ok || !mounted) return;
    if (await _api.deletePin(pin.id)) {
      AppState.dataChanged();
      if (!mounted) return;
      Navigator.pop(context);
      showPinToast(context, 'Épingle supprimée');
    } else if (mounted) {
      showPinToast(context, 'Suppression impossible. Réessayez.');
    }
  }

  Future<void> _openLink() async {
    final uri = Uri.tryParse(pin.link ?? '');
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) showPinToast(context, 'Impossible d’ouvrir le lien.');
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _media(context)),
          SliverToBoxAdapter(child: _actionBar(p)),
          SliverToBoxAdapter(child: _info(p)),
          SliverToBoxAdapter(child: _commentsSection(p)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Text('Plus à découvrir',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          if (_loading)
            const SliverPinSkeleton(count: 4)
          else
            SliverPinGrid(
              pins: _related,
              heroScope: 'related_${pin.id}',
              onRemove: (x) => setState(() => _related.remove(x)),
              onRestore: (i, x) => setState(() => _related.insert(i.clamp(0, _related.length), x)),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _media(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final ratio = pin.aspectRatio.clamp(0.56, 1.6);
    Widget image;
    if (pin.isCarousel) {
      image = PageView.builder(
        itemCount: pin.images.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) =>
            InteractiveViewer(maxScale: 3, child: PinNetImage(pin.images[i], placeholder: pin.color)),
      );
    } else if (pin.isCollage) {
      image = Hero(tag: widget.heroTag, child: CollageView(images: pin.collageImages, color: pin.color));
    } else {
      image = InteractiveViewer(
        maxScale: 3.5,
        child: Hero(tag: widget.heroTag, child: PinNetImage(pin.imageUrl, placeholder: pin.color)),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(aspectRatio: ratio, child: image),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: PinIconButton(
              PinIcons.back,
              size: 40,
              iconSize: 20,
              color: const Color(0xFF111111),
              background: Colors.white,
              tooltip: 'Retour',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (pin.isCarousel)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pin.images.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionBar(PinPalette p) {
    Widget counted(Widget icon, int count, VoidCallback onTap, String label) => Pressable(
          onTap: onTap,
          pressedScale: 0.88,
          child: Semantics(
            button: true,
            label: label,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  icon,
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Row(
        children: [
          counted(
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: PinIcon(
                pin.liked ? PinIcons.heartFill : PinIcons.heart,
                key: ValueKey(pin.liked),
                size: 26,
                color: pin.liked ? GestaltTheme.pinterestRed : p.text,
              ),
            ),
            pin.likeCount,
            _toggleLike,
            pin.liked ? 'Je n’aime plus' : 'J’aime',
          ),
          counted(const PinIcon(PinIcons.comment, size: 26), _comments.length, _goToComments, 'Commentaires'),
          PinIconButton(PinIcons.share,
              iconSize: 25, tooltip: 'Partager', onPressed: () => PinActions.share(context, pin)),
          PinIconButton(
            PinIcons.ellipsis,
            iconSize: 22,
            tooltip: 'Plus d’options',
            onPressed: () => PinActions.showOptions(
              context,
              pin,
              onChanged: _refresh,
              onDelete: _isMine ? _delete : null,
              onHidden: _isMine ? null : () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          pin.isSaved
              ? PinButton(
                  'Enregistrée',
                  kind: PinButtonKind.dark,
                  large: true,
                  onPressed: () => PinActions.showOptions(context, pin, onChanged: _refresh),
                )
              : PinButton(
                  'Enregistrer',
                  kind: PinButtonKind.red,
                  large: true,
                  onPressed: () => PinActions.quickSave(context, pin, onChanged: _refresh),
                ),
        ],
      ),
    );
  }

  Widget _info(PinPalette p) {
    final creator = pin.creator;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onTap: _isMine
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfileScreen(username: creator.username)),
                    ).then((_) => _load()),
            child: Row(
              children: [
                PinAvatar(url: creator.avatarUrl, name: creator.name, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(creator.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (_creatorFollowers != null)
                        Text(
                          '$_creatorFollowers abonné(e)s',
                          style: TextStyle(fontSize: 13, color: p.textMuted),
                        ),
                    ],
                  ),
                ),
                if (!_isMine && !_loading)
                  PinButton(
                    _isFollowing ? 'Abonné(e)' : 'S’abonner',
                    kind: _isFollowing ? PinButtonKind.dark : PinButtonKind.grey,
                    loading: _followBusy,
                    onPressed: _toggleFollow,
                  ),
              ],
            ),
          ),
          if (pin.title.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(pin.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
          ],
          if (pin.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(pin.description, style: TextStyle(fontSize: 15, height: 1.4, color: p.text)),
          ],
          if (pin.link != null && pin.link!.isNotEmpty) ...[
            const SizedBox(height: 14),
            PinButton(
              'Visiter ${Uri.tryParse(pin.link!)?.host.replaceFirst('www.', '') ?? ''}',
              leading: const PinIcon(PinIcons.arrowUpRight, size: 18),
              onPressed: _openLink,
            ),
          ],
        ],
      ),
    );
  }

  Widget _commentsSection(PinPalette p) {
    final me = AppState.user.value;
    final hasText = _commentCtrl.text.trim().isNotEmpty;
    return Padding(
      key: _commentsKey,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _comments.isEmpty ? 'Commentaires' : '${_comments.length} commentaire${_comments.length > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_comments.isEmpty && !_loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Aucun commentaire pour l’instant. Ajoutez-en un pour lancer la discussion !',
                style: TextStyle(fontSize: 14, color: p.textMuted),
              ),
            ),
          for (final c in _comments) _comment(c, p),
          const SizedBox(height: 4),
          Row(
            children: [
              PinAvatar(url: me?.avatarUrl ?? '', name: me?.fullName ?? '', size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.border),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          focusNode: _commentFocus,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 500,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _postComment(),
                          style: TextStyle(fontSize: 15, color: p.text),
                          decoration: InputDecoration(
                            hintText: 'Ajouter un commentaire',
                            hintStyle: TextStyle(color: p.placeholder, fontSize: 15),
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      _posting
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child:
                                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2)),
                            )
                          : PinIconButton(
                              PinIcons.arrowUp,
                              size: 36,
                              iconSize: 18,
                              tooltip: 'Publier le commentaire',
                              color: hasText ? Colors.white : p.textMuted,
                              background: hasText ? GestaltTheme.pinterestRed : p.secondaryButton,
                              onPressed: hasText ? _postComment : null,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comment(Map<String, dynamic> c, PinPalette p) {
    final author = (c['author'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinAvatar(url: (c['avatar_url'] ?? '').toString(), name: author, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$author  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: (c['text'] ?? '').toString()),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, height: 1.35, color: p.text),
                ),
                const SizedBox(height: 4),
                Text((c['time_ago'] ?? '').toString(), style: TextStyle(fontSize: 12, color: p.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
