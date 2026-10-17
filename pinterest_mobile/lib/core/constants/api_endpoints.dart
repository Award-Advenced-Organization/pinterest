class ApiEndpoints {
  // Use localhost for Desktop / iOS, 10.0.2.2 for Android Emulator, or device LAN IP
  static const String baseUrl = 'http://localhost:3018';

  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$baseUrl$path';
  }

  static const String homeFeed = '$baseUrl/v3/feeds/home/';
  static const String search = '$baseUrl/v3/search/';
  static const String pins = '$baseUrl/v3/pins/';
  static const String notifications = '$baseUrl/v3/notifications/';
  static const String conversations = '$baseUrl/v3/conversations/';

  static String pinDetail(String id) => '$baseUrl/v3/pins/$id/';
  static String savePin(String id) => '$baseUrl/v3/pins/$id/save/';
  static String userProfile(String username) => '$baseUrl/v3/users/$username/';
  static String userCreatedPins(String username) => '$baseUrl/v3/users/$username/pins/created/';
  static String userBoards(String username) => '$baseUrl/v3/users/$username/boards/';
  static String conversationMessages(String id) => '$baseUrl/v3/conversations/$id/messages/';
}
