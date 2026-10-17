import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import '../models/pin.dart';
import '../models/user.dart';
import '../models/board.dart';
import '../models/notification_item.dart';
import '../models/conversation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // 1. Home Feed
  Future<List<Pin>> fetchHomeFeed({int page = 1, int pageSize = 20}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.homeFeed}?page=$page&page_size=$pageSize');
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => Pin.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback or offline handling
    }
    return [];
  }

  // 2. Pin Detail
  Future<Map<String, dynamic>?> fetchPinDetail(String id) async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.pinDetail(id)));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  // 3. Save / Unsave
  Future<bool> toggleSavePin(String id, {String? boardId}) async {
    try {
      final res = await _client.post(
        Uri.parse(ApiEndpoints.savePin(id)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'board_id': boardId}),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return body['is_saved'] ?? true;
      }
    } catch (_) {}
    return false;
  }

  // 4. Create Pin
  Future<Pin?> createPin({
    required String title,
    required String description,
    String? link,
    String? category,
    String? boardId,
    String? imageUrl,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse(ApiEndpoints.pins),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'link': link,
          'category': category,
          'board_id': boardId,
          'image_url': imageUrl,
        }),
      );
      if (res.statusCode == 201) {
        final body = json.decode(res.body);
        return Pin.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // 5. Search
  Future<List<Pin>> searchPins({String? query, String? category}) async {
    try {
      final params = <String, String>{};
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (category != null && category.isNotEmpty) params['category'] = category;

      final uri = Uri.parse(ApiEndpoints.search).replace(queryParameters: params);
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => Pin.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 6. User Profile
  Future<UserProfile?> fetchUserProfile(String username) async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.userProfile(username)));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return UserProfile.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // 7. Created Pins
  Future<List<Pin>> fetchUserCreatedPins(String username) async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.userCreatedPins(username)));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => Pin.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 8. Boards
  Future<List<Board>> fetchUserBoards(String username) async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.userBoards(username)));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => Board.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 9. Notifications
  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.notifications));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => NotificationItem.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 10. Conversations
  Future<List<Conversation>> fetchConversations() async {
    try {
      final res = await _client.get(Uri.parse(ApiEndpoints.conversations));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List<dynamic>? ?? [];
        return list.map((json) => Conversation.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 11. Send a message in a conversation
  Future<ChatMessage?> sendMessage(String conversationId, String text) async {
    try {
      final res = await _client.post(
        Uri.parse(ApiEndpoints.conversationMessages(conversationId)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );
      if (res.statusCode == 201) {
        final body = json.decode(res.body);
        return ChatMessage.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // 12. Follow / Unfollow a user — returns the new following state
  Future<bool> toggleFollow(String username) async {
    try {
      final res = await _client.post(
        Uri.parse('${ApiEndpoints.userProfile(username)}follow/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return body['is_following'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  // 13. Post a comment on a pin — returns the created comment
  Future<Map<String, dynamic>?> postComment(String pinId, String text) async {
    try {
      final res = await _client.post(
        Uri.parse('${ApiEndpoints.pinDetail(pinId)}comments/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );
      if (res.statusCode == 201) {
        final body = json.decode(res.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }
}
