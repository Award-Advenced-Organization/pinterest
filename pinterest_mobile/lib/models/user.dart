class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String avatarUrl;
  final String bio;
  final List<String> pronouns;
  final String website;
  final String email;
  final String countryCode;
  final String phone;
  final String appearance; // system | light | dark
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final int createdPinsCount;
  final int savedPinsCount;
  final int boardsCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    this.bio = '',
    this.pronouns = const [],
    this.website = '',
    this.email = '',
    this.countryCode = '+229',
    this.phone = '',
    this.appearance = 'system',
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.createdPinsCount = 0,
    this.savedPinsCount = 0,
    this.boardsCount = 0,
  });

  /// Site affiché sans « http:// » comme sur le profil Pinterest.
  String get websiteLabel => website.replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'/$'), '');

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'] ?? '',
      pronouns: (json['pronouns'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['country_code'] ?? '+229',
      phone: json['phone'] ?? '',
      appearance: json['appearance'] ?? 'system',
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] ?? false,
      createdPinsCount: (json['created_pins_count'] as num?)?.toInt() ?? 0,
      savedPinsCount: (json['saved_pins_count'] as num?)?.toInt() ?? 0,
      boardsCount: (json['boards_count'] as num?)?.toInt() ?? 0,
    );
  }
}
