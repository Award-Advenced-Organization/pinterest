import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/gestalt_theme.dart';

/// Jeu d'icônes à trait fin dessiné pour l'application, dans le style des captures
/// (contours arrondis, version pleine pour l'onglet actif).
enum PinIcons {
  home,
  homeFill,
  search,
  searchBold,
  plus,
  chat,
  chatFill,
  ellipsis,
  share,
  stats,
  compose,
  personAdd,
  camera,
  pin,
  collage,
  board,
  back,
  chevronRight,
  chevronDown,
  close,
  heart,
  heartFill,
  comment,
  send,
  filter,
  globe,
  eye,
  eyeOff,
  link,
  flag,
  trash,
  check,
  lock,
  hand,
  arrowUpRight,
  bookmarkFill,
  people,
  image,
  contrast,
  info,
  arrowUp,
}

const _house = 'M4 10.6 12 4l8 6.6V19a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 19z';
const _smile = 'M9.4 15.6c1.5 1.1 3.7 1.1 5.2 0';
const _bubble =
    'M12 3.75c4.7 0 8.25 3.35 8.25 7.65S16.7 19.05 12 19.05c-.97 0-1.9-.14-2.76-.4L4.5 20.25l1.1-3.9a7.2 7.2 0 0 1-1.85-4.95C3.75 7.1 7.3 3.75 12 3.75z';
const _heart = 'M12 20s-7.75-4.7-7.75-10.4A4.35 4.35 0 0 1 12 6.9a4.35 4.35 0 0 1 7.75 2.7C19.75 15.3 12 20 12 20z';
const _eye = 'M2.75 12S6.2 5.75 12 5.75 21.25 12 21.25 12 17.8 18.25 12 18.25 2.75 12 2.75 12z';

String _dots(String fill) => '<circle cx="8.3" cy="11.4" r="1.2" fill="$fill" stroke="none"/>'
    '<circle cx="12" cy="11.4" r="1.2" fill="$fill" stroke="none"/>'
    '<circle cx="15.7" cy="11.4" r="1.2" fill="$fill" stroke="none"/>';

final Map<PinIcons, String> _shapes = {
  PinIcons.home: '<path d="$_house"/><path d="$_smile"/>',
  PinIcons.homeFill: '<path d="$_house" fill="{c}"/><path d="$_smile" stroke="{b}"/>',
  PinIcons.search: '<circle cx="10.5" cy="10.5" r="6.6"/><path d="M15.4 15.4 20.5 20.5"/>',
  PinIcons.searchBold:
      '<circle cx="10.5" cy="10.5" r="6.4" stroke-width="3.2"/><path d="M15.4 15.4 20.3 20.3" stroke-width="3.2"/>',
  PinIcons.plus: '<path d="M12 4v16M4 12h16"/>',
  PinIcons.chat: '<path d="$_bubble"/>${_dots('{c}')}',
  PinIcons.chatFill: '<path d="$_bubble" fill="{c}"/>${_dots('{b}')}',
  PinIcons.ellipsis:
      '<circle cx="5" cy="12" r="2" fill="{c}" stroke="none"/><circle cx="12" cy="12" r="2" fill="{c}" stroke="none"/>'
          '<circle cx="19" cy="12" r="2" fill="{c}" stroke="none"/>',
  PinIcons.share:
      '<circle cx="18" cy="5.5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="18.5" r="2.5"/>'
          '<path d="M8.2 10.8 15.8 6.7M8.2 13.2l7.6 4.1"/>',
  PinIcons.stats:
      '<rect x="3.5" y="11" width="4" height="9.5" rx="2"/><rect x="10" y="3.5" width="4" height="17" rx="2"/>'
          '<rect x="16.5" y="8" width="4" height="12.5" rx="2"/>',
  PinIcons.compose:
      '<path d="M4 20.75h16"/><path d="M15.3 4.2a1.8 1.8 0 0 1 2.55 0l1.95 1.95a1.8 1.8 0 0 1 0 2.55L10 18.5l-4.5 1 1-4.5z"/>',
  PinIcons.personAdd:
      '<circle cx="10" cy="8" r="3.6"/><path d="M3.5 20c0-3.5 2.9-6.1 6.5-6.1 1.15 0 2.25.27 3.2.75"/><path d="M18 14.5v6M15 17.5h6"/>',
  PinIcons.camera:
      '<path d="M3.5 8.6a2 2 0 0 1 2-2h2.3l1.4-2.1h5.6l1.4 2.1h2.3a2 2 0 0 1 2 2V18a2 2 0 0 1-2 2h-13a2 2 0 0 1-2-2z"/>'
          '<circle cx="12" cy="13" r="3.4"/>',
  PinIcons.pin: '<path d="M8 3.75h8M9.6 3.75v5.9L6.5 14h11l-3.1-4.35v-5.9M12 14v6.5"/>',
  PinIcons.collage: '<path d="M10.5 4h7a2.5 2.5 0 0 1 2.5 2.5v11a2.5 2.5 0 0 1-2.5 2.5h-3"/>'
      '<circle cx="6" cy="18" r="2"/><circle cx="11" cy="18" r="2"/><path d="M7.3 16.4 12.3 8.5M9.7 16.4 4.7 8.5"/>',
  PinIcons.board: '<rect x="3.75" y="3.75" width="16.5" height="16.5" rx="3"/><path d="M12 3.75v16.5M12 12h8.25"/>',
  PinIcons.back: '<path d="M15 4.5 7.5 12l7.5 7.5"/>',
  PinIcons.chevronRight: '<path d="M9 5l7 7-7 7"/>',
  PinIcons.chevronDown: '<path d="M5 9l7 7 7-7"/>',
  PinIcons.close: '<path d="M5.5 5.5l13 13M18.5 5.5l-13 13"/>',
  PinIcons.heart: '<path d="$_heart"/>',
  PinIcons.heartFill: '<path d="$_heart" fill="{c}"/>',
  PinIcons.comment: '<path d="$_bubble"/>',
  PinIcons.send: '<path d="M20.5 3.5 3.5 10.6l6.9 3 3 6.9z"/><path d="M10.4 13.6 20.5 3.5"/>',
  PinIcons.filter:
      '<path d="M4 7.5h16M4 16.5h16"/><circle cx="9" cy="7.5" r="2.4" fill="{b}"/><circle cx="15" cy="16.5" r="2.4" fill="{b}"/>',
  PinIcons.globe: '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/>'
      '<path d="M12 3.5c2.4 2.3 3.6 5.1 3.6 8.5s-1.2 6.2-3.6 8.5c-2.4-2.3-3.6-5.1-3.6-8.5s1.2-6.2 3.6-8.5z"/>',
  PinIcons.eye: '<path d="$_eye"/><circle cx="12" cy="12" r="3"/>',
  PinIcons.eyeOff:
      '<path d="$_eye"/><circle cx="12" cy="12" r="3"/><path d="M4 4l16 16" stroke="{b}" stroke-width="4"/><path d="M4 4l16 16"/>',
  PinIcons.link:
      '<path d="M10 14a4 4 0 0 0 5.66 0l3-3A4 4 0 0 0 13 5.34l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3A4 4 0 0 0 11 18.66l1-1"/>',
  PinIcons.flag: '<path d="M5.5 21V4.5M5.5 4.5h11.5l-2.2 4 2.2 4H5.5"/>',
  PinIcons.trash: '<path d="M4.5 6.5h15M9.5 6.5v-2h5v2M6.5 6.5l1 13.5h9l1-13.5"/>',
  PinIcons.check: '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
  PinIcons.lock: '<rect x="5" y="10.5" width="14" height="10" rx="2.5"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/>',
  PinIcons.hand:
      '<path d="M9 12.5V5.25a1.5 1.5 0 0 1 3 0v6.25m0-1.25a1.5 1.5 0 0 1 3 0v1.75m0-.75a1.5 1.5 0 0 1 3 0V16a5 5 0 0 1-5 5h-1.3a4.5 4.5 0 0 1-3.8-2.1L4.6 15.6a1.5 1.5 0 0 1 2.5-1.6L9 16.4"/>',
  PinIcons.arrowUpRight: '<path d="M7 17 17 7M9 7h8v8"/>',
  PinIcons.bookmarkFill: '<path d="M6.5 3.5h11v17L12 16l-5.5 4.5z" fill="{c}"/>',
  PinIcons.people: '<circle cx="9" cy="8.5" r="3"/><path d="M3.5 19.5c0-3 2.5-5.2 5.5-5.2s5.5 2.2 5.5 5.2"/>'
      '<circle cx="16.5" cy="9.5" r="2.4"/><path d="M16.2 14.3c2.5 0 4.3 1.9 4.3 4.6"/>',
  PinIcons.image:
      '<rect x="3.5" y="4.5" width="17" height="15" rx="2.5"/><circle cx="9" cy="10" r="1.8"/><path d="M3.5 17l5-5 4 4 2.5-2.5 5.5 5.5"/>',
  PinIcons.contrast:
      '<circle cx="12" cy="12" r="8.5"/><path d="M12 3.5a8.5 8.5 0 0 1 0 17z" fill="{c}" stroke="none"/>',
  PinIcons.info:
      '<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5.5"/><circle cx="12" cy="7.9" r="1.1" fill="{c}" stroke="none"/>',
  PinIcons.arrowUp: '<path d="M12 19.5V5M6 10.5 12 4.5l6 6"/>',
};

final Map<String, String> _cache = {};

String _hex(Color c) {
  final v = c.toARGB32() & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0')}';
}

class PinIcon extends StatelessWidget {
  final PinIcons icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Couleur des parties « évidées » (sourire de la maison pleine, points de la bulle pleine).
  final Color? background;

  const PinIcon(this.icon, {super.key, this.size = 24, this.color, this.strokeWidth = 2, this.background});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.pal.text;
    final b = background ?? context.pal.bg;
    final alpha = (c.a * 1000).round() / 1000;
    final key = '${icon.name}|${_hex(c)}|${_hex(b)}|$strokeWidth|$alpha';
    final svg = _cache.putIfAbsent(key, () {
      final inner = _shapes[icon]!.replaceAll('{c}', _hex(c)).replaceAll('{b}', _hex(b));
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" opacity="$alpha">'
          '<g fill="none" stroke="${_hex(c)}" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">'
          '$inner</g></svg>';
    });
    return SvgPicture.string(svg, width: size, height: size);
  }
}
