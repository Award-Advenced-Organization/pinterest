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
  final int width;
  final int height;
  final double aspectRatio;
  final String dominantColor;
  final String category;
  final PinCreator creator;
  final int repinCount;
  bool isSaved;
  final bool isVideo;
  final String? videoDuration;
  final bool isCarousel;

  Pin({
    required this.id,
    required this.title,
    required this.description,
    this.link,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.dominantColor,
    required this.category,
    required this.creator,
    required this.repinCount,
    this.isSaved = false,
    this.isVideo = false,
    this.videoDuration,
    this.isCarousel = false,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    final w = (json['width'] as num?)?.toInt() ?? 736;
    final h = (json['height'] as num?)?.toInt() ?? 1000;
    final ar = (json['aspect_ratio'] as num?)?.toDouble() ?? (w / h);

    return Pin(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'],
      imageUrl: json['image_url'] ?? '',
      width: w,
      height: h,
      aspectRatio: ar > 0 ? ar : 0.75,
      dominantColor: json['dominant_color'] ?? '#EFEFEF',
      category: json['category'] ?? 'general',
      creator: PinCreator.fromJson(json['creator'] ?? {}),
      repinCount: (json['repin_count'] as num?)?.toInt() ?? 0,
      isSaved: json['is_saved'] ?? false,
      isVideo: json['is_video'] ?? (json['video_duration'] != null),
      videoDuration: json['video_duration'],
      isCarousel: json['is_carousel'] ?? false,
    );
  }
}
