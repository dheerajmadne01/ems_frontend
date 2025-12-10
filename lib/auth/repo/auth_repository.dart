import 'dart:convert';
import 'package:emp_management/auth/model/auth_models.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiProvider _api;
  final GetStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _legacyTokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/auth/login',
      withAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      final result = LoginResponse.fromJson(json);

      _persistAuthData(result);

      return result;
    }

    throw Exception('Login failed: ${response.body}');
  }

  Future<void> logout() async {
    _storage.remove(_accessTokenKey);
    _storage.remove(_legacyTokenKey);
    _storage.remove(_refreshTokenKey);
    _storage.remove('auth_role');
    _storage.remove('auth_id');
    _storage.remove('auth_name');
    _storage.remove('auth_email');
  }

  void _persistAuthData(LoginResponse response) {
    _storage.write(_accessTokenKey, response.accessToken);
    _storage.write(_legacyTokenKey, response.accessToken);
    if (response.refreshToken.isNotEmpty) {
      _storage.write(_refreshTokenKey, response.refreshToken);
    }

    _storage.write('auth_role', response.user.role);
    _storage.write('auth_id', response.user.id);
    _storage.write('auth_name', response.user.name);
    _storage.write('auth_email', response.user.email);
  }
}


