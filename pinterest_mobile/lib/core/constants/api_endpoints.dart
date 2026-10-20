class ApiEndpoints {
  // localhost pour le bureau, le web et iOS ; 10.0.2.2 pour l'émulateur Android ; IP du PC pour un vrai téléphone.
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3018');

  static String resolveUrl(String path) {
    if (path.isEmpty || path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl$path';
  }

  static const String v3 = '$baseUrl/v3';
}
