import 'conversation.dart';

/// Ligne de la section « Mises à jour » de la boîte de réception.
class NotificationItem {
  final String id;
  final String text;
  final String query; // recherche ouverte quand on touche la mise à jour
  final String timeAgo;
  final String? imageUrl;
  final String? icon;

  NotificationItem({
    required this.id,
    required this.text,
    required this.query,
    required this.timeAgo,
    this.imageUrl,
    this.icon,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      query: json['query'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      imageUrl: json['image_url'],
      icon: json['icon'],
    );
  }
}

/// Ligne de la section « Activité » (suggestion d'abonnement, nouvel abonné…).
class ActivityItem {
  final String id;
  final String type; // suggestion | follow
  final String text;
  final String timeAgo;
  final ChatUser user;
  bool isFollowing;

  ActivityItem({
    required this.id,
    required this.type,
    required this.text,
    required this.timeAgo,
    required this.user,
    this.isFollowing = false,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final u = Map<String, dynamic>.from(json['user'] ?? {});
    return ActivityItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      user: ChatUser.fromJson(u),
      isFollowing: u['is_following'] ?? false,
    );
  }
}

/// Carte de la page Rechercher.
class SearchIdea {
  final String title;
  final String query;
  final String image;

  SearchIdea({required this.title, required this.query, required this.image});

  factory SearchIdea.fromJson(Map<String, dynamic> json) =>
      SearchIdea(title: json['title'] ?? '', query: json['query'] ?? '', image: json['image'] ?? '');
}
