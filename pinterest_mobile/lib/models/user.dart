class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String avatarUrl;
  final String bio;
  final String website;
  final int followerCount;
  final int followingCount;
  final bool isVerified;
  final int createdPinsCount;
  final int savedPinsCount;
  final int boardsCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    required this.website,
    required this.followerCount,
    required this.followingCount,
    required this.isVerified,
    required this.createdPinsCount,
    required this.savedPinsCount,
    required this.boardsCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? 'ahiffent',
      fullName: json['full_name'] ?? 'Jaye ahf',
      avatarUrl: json['avatar_url'] ?? '/avatar_jaye.jpg',
      bio: json['bio'] ?? '',
      website: json['website'] ?? 'http://ahiffonjephte.me',
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 1,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 2,
      isVerified: json['is_verified'] ?? true,
      createdPinsCount: (json['created_pins_count'] as num?)?.toInt() ?? 1,
      savedPinsCount: (json['saved_pins_count'] as num?)?.toInt() ?? 22,
      boardsCount: (json['boards_count'] as num?)?.toInt() ?? 5,
    );
  }
}
