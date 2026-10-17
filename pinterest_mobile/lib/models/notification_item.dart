class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String? imageUrl;
  final String? icon;
  final bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.imageUrl,
    this.icon,
    required this.read,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      imageUrl: json['image_url'],
      icon: json['icon'],
      read: json['read'] ?? true,
    );
  }
}
