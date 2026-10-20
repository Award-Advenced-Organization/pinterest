import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import '../models/pin.dart';
import '../models/user.dart';
import '../models/board.dart';
import '../models/notification_item.dart';
import '../models/conversation.dart';

/// Résultat d'une action qui peut échouer avec un message à montrer à l'utilisateur.
class ApiResult<T> {
  final T? data;
  final String? error;
  const ApiResult.ok(this.data) : error = null;
  const ApiResult.fail(this.error) : data = null;
  bool get ok => error == null;
}

class FeedPage {
  final List<Pin> pins;
  final bool hasMore;
  FeedPage(this.pins, this.hasMore);
}

/// Image choisie sur l'appareil, prête à être envoyée.
class PickedImage {
  final Uint8List bytes;
  final String filename;
  final int width;
  final int height;
  final String dominantColor;
  PickedImage({
    required this.bytes,
    required this.filename,
    required this.width,
    required this.height,
    required this.dominantColor,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  static const _json = {'Content-Type': 'application/json'};
  static const _offline = 'Connexion au serveur impossible. Vérifiez qu’il est démarré.';

  Uri _u(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiEndpoints.v3}$path').replace(queryParameters: query);

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    try {
      final res = await _client.get(_u(path, query));
      if (res.statusCode == 200) return json.decode(utf8.decode(res.bodyBytes));
    } catch (_) {}
    return null;
  }

  /// Envoie une requête JSON. Renvoie le corps décodé, ou un message d'erreur.
  Future<ApiResult<Map<String, dynamic>>> _send(String method, String path, [Map<String, dynamic>? body]) async {
    try {
      final req = http.Request(method, _u(path))..headers.addAll(_json);
      if (body != null) req.body = json.encode(body);
      final res = await http.Response.fromStream(await _client.send(req));
      final decoded = res.body.isEmpty ? <String, dynamic>{} : json.decode(utf8.decode(res.bodyBytes));
      if (res.statusCode >= 200 && res.statusCode < 300) return ApiResult.ok(Map<String, dynamic>.from(decoded));
      return ApiResult.fail((decoded is Map ? decoded['error'] : null)?.toString() ?? 'Une erreur est survenue.');
    } catch (_) {
      return const ApiResult.fail(_offline);
    }
  }

  List<Pin> _pins(dynamic body) =>
      ((body?['data'] as List<dynamic>?) ?? []).map((j) => Pin.fromJson(Map<String, dynamic>.from(j))).toList();

  // --- Fil et Épingles ---

  Future<FeedPage?> fetchHomeFeed({int page = 1, int pageSize = 20}) async {
    final body = await _get('/feeds/home/', {'page': '$page', 'page_size': '$pageSize'});
    if (body == null) return null;
    return FeedPage(_pins(body), body['bookmark'] != null);
  }

  Future<Map<String, dynamic>?> fetchPinDetail(String id) async {
    final body = await _get('/pins/$id/');
    return body == null ? null : Map<String, dynamic>.from(body['data']);
  }

  /// Enregistre l'Épingle dans un tableau, ou dans « Idées non organisées » si [boardId] est nul.
  Future<ApiResult<Map<String, dynamic>>> savePin(String id, {String? boardId}) =>
      _send('POST', '/pins/$id/save/', {'board_id': boardId});

  Future<bool> unsavePin(String id) async => (await _send('DELETE', '/pins/$id/save/')).ok;

  Future<({bool liked, int count})?> toggleLike(String id) async {
    final r = await _send('POST', '/pins/$id/like/');
    if (!r.ok) return null;
    return (liked: r.data!['liked'] == true, count: (r.data!['like_count'] as num).toInt());
  }

  Future<bool> hidePin(String id) async => (await _send('POST', '/pins/$id/hide/')).ok;
  Future<bool> unhidePin(String id) async => (await _send('DELETE', '/pins/$id/hide/')).ok;
  Future<bool> deletePin(String id) async => (await _send('DELETE', '/pins/$id/')).ok;

  Future<Map<String, dynamic>?> postComment(String pinId, String text) async {
    final r = await _send('POST', '/pins/$pinId/comments/', {'text': text});
    return r.ok ? Map<String, dynamic>.from(r.data!['data']) : null;
  }

  Future<ApiResult<Pin>> createPin({
    required String title,
    required String description,
    String? link,
    String? boardId,
    PickedImage? image,
    String? imageUrl,
    List<String>? collageImages,
    int? width,
    int? height,
    String? dominantColor,
  }) async {
    try {
      final req = http.MultipartRequest('POST', _u('/pins/'));
      req.fields.addAll({
        'title': title,
        'description': description,
        if (link != null && link.isNotEmpty) 'link': link,
        if (boardId != null) 'board_id': boardId,
        if (imageUrl != null) 'image_url': imageUrl,
        if (collageImages != null) 'collage_images': json.encode(collageImages),
        'width': '${image?.width ?? width ?? 736}',
        'height': '${image?.height ?? height ?? 980}',
        'dominant_color': image?.dominantColor ?? dominantColor ?? '#d9d9d4',
      });
      if (image != null) {
        req.files.add(http.MultipartFile.fromBytes('image', image.bytes, filename: image.filename));
      }
      final res = await http.Response.fromStream(await _client.send(req));
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 201) return ApiResult.ok(Pin.fromJson(Map<String, dynamic>.from(body['data'])));
      return ApiResult.fail(body['error']?.toString() ?? 'Publication impossible.');
    } catch (_) {
      return const ApiResult.fail(_offline);
    }
  }

  // --- Recherche ---

  Future<List<Pin>?> searchPins(String query) async {
    final body = await _get('/search/', {'q': query});
    return body == null ? null : _pins(body);
  }

  Future<List<Pin>?> searchByColor(String hexColor) async {
    final body = await _get('/search/visual/', {'color': hexColor});
    return body == null ? null : _pins(body);
  }

  Future<({List<SearchIdea> ideas, List<SearchIdea> popular})?> fetchSearchIdeas() async {
    final body = await _get('/search/ideas/');
    if (body == null) return null;
    List<SearchIdea> list(String k) => ((body['data'][k] as List<dynamic>?) ?? [])
        .map((j) => SearchIdea.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    return (ideas: list('ideas'), popular: list('popular'));
  }

  // --- Utilisateurs ---

  Future<UserProfile?> fetchUserProfile(String username) async {
    final body = await _get('/users/$username/');
    return body == null ? null : UserProfile.fromJson(Map<String, dynamic>.from(body['data']));
  }

  Future<ApiResult<UserProfile>> updateMe(Map<String, dynamic> patch) async {
    final r = await _send('PATCH', '/users/me/', patch);
    return r.ok
        ? ApiResult.ok(UserProfile.fromJson(Map<String, dynamic>.from(r.data!['data'])))
        : ApiResult.fail(r.error);
  }

  Future<ApiResult<UserProfile>> uploadAvatar(PickedImage image) async {
    try {
      final req = http.MultipartRequest('POST', _u('/users/me/avatar/'))
        ..files.add(http.MultipartFile.fromBytes('image', image.bytes, filename: image.filename));
      final res = await http.Response.fromStream(await _client.send(req));
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) return ApiResult.ok(UserProfile.fromJson(Map<String, dynamic>.from(body['data'])));
      return ApiResult.fail(body['error']?.toString() ?? 'Envoi impossible.');
    } catch (_) {
      return const ApiResult.fail(_offline);
    }
  }

  Future<List<ChatUser>> searchUsers(String query) async {
    final body = await _get('/users/', {'q': query});
    return ((body?['data'] as List<dynamic>?) ?? [])
        .map((j) => ChatUser.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  /// Renvoie le nouvel état d'abonnement, ou null si le serveur n'a pas répondu.
  Future<bool?> toggleFollow(String username) async {
    final r = await _send('POST', '/users/$username/follow/');
    return r.ok ? r.data!['is_following'] == true : null;
  }

  Future<List<Pin>?> fetchCreatedPins(String username) async =>
      _pinsOrNull(await _get('/users/$username/pins/created/'));

  Future<List<Pin>?> fetchSavedPins({bool unorganizedOnly = false}) async =>
      _pinsOrNull(await _get('/users/me/pins/saved/', unorganizedOnly ? {'unorganized': '1'} : null));

  List<Pin>? _pinsOrNull(dynamic body) => body == null ? null : _pins(body);

  // --- Tableaux ---

  Future<List<Board>?> fetchBoards() async {
    final body = await _get('/users/me/boards/');
    if (body == null) return null;
    return ((body['data'] as List<dynamic>?) ?? []).map((j) => Board.fromJson(Map<String, dynamic>.from(j))).toList();
  }

  Future<List<Cluster>> fetchClusters() async {
    final body = await _get('/users/me/clusters/');
    return ((body?['data'] as List<dynamic>?) ?? [])
        .map((j) => Cluster.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<ApiResult<Board>> createBoardFromCluster(String clusterId) async {
    final r = await _send('POST', '/users/me/clusters/$clusterId/create/');
    return r.ok ? ApiResult.ok(Board.fromJson(Map<String, dynamic>.from(r.data!['data']))) : ApiResult.fail(r.error);
  }

  Future<ApiResult<Board>> createBoard(String name, {bool secret = false}) async {
    final r = await _send('POST', '/boards/', {'name': name, 'secret': secret});
    return r.ok ? ApiResult.ok(Board.fromJson(Map<String, dynamic>.from(r.data!['data']))) : ApiResult.fail(r.error);
  }

  Future<ApiResult<Board>> updateBoard(String id, {String? name, bool? secret, String? description}) async {
    final r = await _send('PATCH', '/boards/$id/', {
      if (name != null) 'name': name,
      if (secret != null) 'secret': secret,
      if (description != null) 'description': description,
    });
    return r.ok ? ApiResult.ok(Board.fromJson(Map<String, dynamic>.from(r.data!['data']))) : ApiResult.fail(r.error);
  }

  Future<bool> deleteBoard(String id) async => (await _send('DELETE', '/boards/$id/')).ok;

  Future<List<Pin>?> fetchBoardPins(String id) async => _pinsOrNull(await _get('/boards/$id/pins/'));

  Future<bool> movePinsToBoard(String boardId, List<String> pinIds) async =>
      (await _send('POST', '/boards/$boardId/pins/', {'pin_ids': pinIds})).ok;

  Future<bool> removePinFromBoard(String boardId, String pinId) async =>
      (await _send('DELETE', '/boards/$boardId/pins/$pinId/')).ok;

  // --- Boîte de réception ---

  Future<List<ActivityItem>?> fetchActivity() async {
    final body = await _get('/activity/');
    if (body == null) return null;
    return ((body['data'] as List<dynamic>?) ?? [])
        .map((j) => ActivityItem.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<List<NotificationItem>?> fetchNotifications() async {
    final body = await _get('/notifications/');
    if (body == null) return null;
    return ((body['data'] as List<dynamic>?) ?? [])
        .map((j) => NotificationItem.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<bool> dismissNotification(String id) async => (await _send('DELETE', '/notifications/$id/')).ok;

  Future<List<Conversation>?> fetchConversations() async {
    final body = await _get('/conversations/');
    if (body == null) return null;
    return ((body['data'] as List<dynamic>?) ?? [])
        .map((j) => Conversation.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  /// Ouvre la conversation existante avec [username], ou en crée une.
  Future<Conversation?> openConversation(String username) async {
    final r = await _send('POST', '/conversations/', {'username': username});
    return r.ok ? Conversation.fromJson(Map<String, dynamic>.from(r.data!['data'])) : null;
  }

  Future<ChatMessage?> sendMessage(String conversationId, String text, {String? pinId}) async {
    final r = await _send(
        'POST', '/conversations/$conversationId/messages/', {'text': text, if (pinId != null) 'pin_id': pinId});
    return r.ok ? ChatMessage.fromJson(Map<String, dynamic>.from(r.data!['data'])) : null;
  }
}
