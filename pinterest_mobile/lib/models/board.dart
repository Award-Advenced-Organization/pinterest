class Board {
  final String id;
  final String name;
  final bool secret;
  final String description;
  final int pinCount;
  final List<String> coverImages;

  Board({
    required this.id,
    required this.name,
    required this.secret,
    this.description = '',
    required this.pinCount,
    required this.coverImages,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      secret: json['secret'] ?? false,
      description: json['description'] ?? '',
      pinCount: (json['pin_count'] as num?)?.toInt() ?? 0,
      coverImages: (json['cover_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Regroupement d'Épingles non classées proposé sur le profil (« Créer » en fait un tableau).
class Cluster {
  final String id;
  final String name;
  final int pinCount;
  final List<String> coverImages;

  Cluster({required this.id, required this.name, required this.pinCount, required this.coverImages});

  factory Cluster.fromJson(Map<String, dynamic> json) {
    return Cluster(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pinCount: (json['pin_count'] as num?)?.toInt() ?? 0,
      coverImages: (json['cover_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
