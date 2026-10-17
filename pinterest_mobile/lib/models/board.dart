class Board {
  final String id;
  final String name;
  final bool secret;
  final int pinCount;
  final List<String> coverImages;

  Board({
    required this.id,
    required this.name,
    required this.secret,
    required this.pinCount,
    required this.coverImages,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      secret: json['secret'] ?? false,
      pinCount: (json['pin_count'] as num?)?.toInt() ?? 0,
      coverImages: (json['cover_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
