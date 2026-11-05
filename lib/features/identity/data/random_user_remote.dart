import 'package:dio/dio.dart';

class RandomUserProfile {
  const RandomUserProfile({
    required this.first,
    required this.last,
    required this.username,
    this.picture,
  });

  final String first;
  final String last;
  final String username;
  final String? picture;
}

/// GET https://randomuser.me/api/
class RandomUserRemote {
  RandomUserRemote(this._dio);

  final Dio _dio;

  Future<RandomUserProfile> fetch({CancelToken? cancelToken}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/',
      queryParameters: <String, dynamic>{'inc': 'name,login,picture', 'noinfo': ''},
      cancelToken: cancelToken,
    );
    final results = response.data?['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw const FormatException('randomuser.me returned no results');
    }
    final user = results.first as Map<String, dynamic>;
    final name = user['name'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final login = user['login'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final picture = user['picture'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return RandomUserProfile(
      first: (name['first'] as String?) ?? '',
      last: (name['last'] as String?) ?? '',
      username: (login['username'] as String?) ?? '',
      picture: (picture['large'] ?? picture['medium'] ?? picture['thumbnail']) as String?,
    );
  }
}
