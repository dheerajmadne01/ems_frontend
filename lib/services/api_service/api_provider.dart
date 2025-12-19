import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiProvider {
  ApiProvider({http.Client? client})
    : _client = client ?? http.Client(),
      _storage = GetStorage();

  final http.Client _client;
  final GetStorage _storage;

  static const String baseUrl ='https://ems-backend-00pu.onrender.com/api';
  static const String _accessTokenKey = 'auth_access_token';
  static const String _legacyTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  String? get _token => _storage.read<String>(_legacyTokenKey);

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);
    return _sendWithRefresh(
      () => _client.get(uri, headers: _buildHeaders(withAuth: withAuth)),
      withAuth: withAuth,
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendWithRefresh(
      () => _client.post(
        uri,
        headers: _buildHeaders(withAuth: withAuth),
        body: encodedBody,
      ),
      withAuth: withAuth,
    );
  }

  Map<String, String> _buildHeaders({bool withAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final currentToken = _token;
      if (currentToken != null && currentToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $currentToken';
        headers['token'] = currentToken;
      }
    }
    return headers;
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendWithRefresh(
      () => _client.put(
        uri,
        headers: _buildHeaders(withAuth: withAuth),
        body: encodedBody,
      ),
      withAuth: withAuth,
    );
  }

  Future<http.Response> _sendWithRefresh(
    Future<http.Response> Function() requestFn, {
    required bool withAuth,
  }) async {
    final response = await requestFn();
    if (!_shouldAttemptRefresh(response.statusCode, withAuth)) {
      return response;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      return response;
    }

    // Retry once with the newly issued access token.
    return requestFn();
  }

  bool _shouldAttemptRefresh(int statusCode, bool withAuth) {
    if (!withAuth) return false;
    return statusCode == 401 || statusCode == 403;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = _storage.read<String>(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      print('ApiProvider: refresh token missing, cannot refresh access token');
      return false;
    }

    final uri = Uri.parse('$baseUrl/auth/refresh-token');
    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('ApiProvider: refresh token failed with ${response.statusCode}');
        return false;
      }

      final data = _extractData(jsonDecode(response.body));
      final newAccessToken = (data['accessToken'] ?? data['token']) as String?;
      final newRefreshToken = data['refreshToken'] as String? ?? refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        print('ApiProvider: refresh response missing access token');
        return false;
      }

      _storage.write(_accessTokenKey, newAccessToken);
      _storage.write(_legacyTokenKey, newAccessToken);
      if (newRefreshToken.isNotEmpty) {
        _storage.write(_refreshTokenKey, newRefreshToken);
      }

      print('ApiProvider: access token refreshed successfully');
      return true;
    } catch (e) {
      print('ApiProvider: refresh token call failed: $e');
      return false;
    }
  }

  Map<String, dynamic> _extractData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return (payload['data'] as Map<String, dynamic>?) ?? payload;
    }
    return <String, dynamic>{};
  }
}
