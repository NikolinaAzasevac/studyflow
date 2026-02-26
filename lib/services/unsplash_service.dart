import 'dart:convert';

import 'package:http/http.dart' as http;

class UnsplashImage {
  final String id;
  final String thumbUrl;
  final String fullUrl;
  final String photographer;
  final String photographerProfile;

  const UnsplashImage({
    required this.id,
    required this.thumbUrl,
    required this.fullUrl,
    required this.photographer,
    required this.photographerProfile,
  });
}

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey = String.fromEnvironment(
    'UNSPLASH_ACCESS_KEY',
    defaultValue: 'YOUR_UNSPLASH_ACCESS_KEY',
  );

  Future<List<UnsplashImage>> searchPhotos(String query) async {
    if (query.trim().isEmpty || _accessKey == 'YOUR_UNSPLASH_ACCESS_KEY') {
      return [];
    }

    final uri = Uri.parse(
      '$_baseUrl/search/photos',
    ).replace(queryParameters: {'query': query, 'per_page': '18'});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Client-ID $_accessKey'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>?) ?? [];
    return results.map((item) {
      final data = item as Map<String, dynamic>;
      final urls = data['urls'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      return UnsplashImage(
        id: data['id'] as String,
        thumbUrl: urls['small'] as String,
        fullUrl: urls['regular'] as String,
        photographer: user['name'] as String? ?? 'Unknown',
        photographerProfile: user['links']?['html'] as String? ?? '',
      );
    }).toList();
  }
}
