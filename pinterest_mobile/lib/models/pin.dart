import 'package:flutter/painting.dart';

class PinCreator {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;

  PinCreator({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });

  factory PinCreator.fromJson(Map<String, dynamic> json) {
    return PinCreator(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}

class Pin {
  final String id;
  final String title;
  final String description;
  final String? link;
  final String imageUrl;

  /// Images d'un carrousel (vide si l'Épingle n'a qu'une image).
  final List<String> images;

  /// Images d'un collage créé dans l'application.
  final List<String> collageImages;
  final int width;
  final int height;
  final double aspectRatio;
  final String dominantColor;
  final String category;
  final PinCreator creator;
  final int repinCount;
  bool isSaved;
  String? boardId;
  bool liked;
  int likeCount;
  int commentCount;

  Pin({
    required this.id,
    required this.title,
    required this.description,
    this.link,
    required this.imageUrl,
    this.images = const [],
    this.collageImages = const [],
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.dominantColor,
    required this.category,
    required this.creator,
    required this.repinCount,
    this.isSaved = false,
    this.boardId,
    this.liked = false,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  bool get isCarousel => images.length > 1;
  bool get isCollage => collageImages.length > 1;

  Color get color {
    final hex = dominantColor.replaceAll('#', '');
    final v = int.tryParse(hex, radix: 16);
    return v == null ? const Color(0xFFE5E5E0) : Color(0xFF000000 | v);
  }

  factory Pin.fromJson(Map<String, dynamic> json) {
    final w = (json['width'] as num?)?.toInt() ?? 736;
    final h = (json['height'] as num?)?.toInt() ?? 1000;
    final ar = (json['aspect_ratio'] as num?)?.toDouble() ?? (w / h);
    List<String> strings(dynamic v) => (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];
    return Pin(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'],
      imageUrl: json['image_url'] ?? '',
      images: strings(json['images']),
      collageImages: strings(json['collage_images']),
      width: w,
      height: h,
      aspectRatio: ar > 0 ? ar : 0.75,
      dominantColor: json['dominant_color'] ?? '#E5E5E0',
      category: json['category'] ?? '',
      creator: PinCreator.fromJson(json['creator'] ?? {}),
      repinCount: (json['repin_count'] as num?)?.toInt() ?? 0,
      isSaved: json['is_saved'] ?? false,
      boardId: json['board_id'],
      liked: json['liked'] ?? false,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    );
  }
}
