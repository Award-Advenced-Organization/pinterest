class ChatMessage {
  final String from; // 'me' | 'them'
  final String text;
  final String time;

  ChatMessage({required this.from, required this.text, required this.time});

  bool get isMine => from == 'me';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      from: json['from'] ?? 'them',
      text: json['text'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class ChatUser {
  final String name;
  final String username;
  final String avatarUrl;

  ChatUser({required this.name, required this.username, required this.avatarUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}

class Conversation {
  final String id;
  final ChatUser withUser;
  String lastMessage;
  String timeAgo;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.withUser,
    required this.lastMessage,
    required this.timeAgo,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return Conversation(
      id: json['id'] ?? '',
      withUser: ChatUser.fromJson(json['with_user'] ?? {}),
      lastMessage: json['last_message'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      messages: rawMessages.map((m) => ChatMessage.fromJson(m)).toList(),
    );
  }
}
