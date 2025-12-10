
class LoginResponse {
  LoginResponse({
    required this.statusCode,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final int statusCode;
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return LoginResponse(
      statusCode: json['status_code'] as int? ??
          data['status_code'] as int? ??
          200,
      message: json['message'] as String? ??
          data['message'] as String? ??
          '',
      accessToken: data['accessToken'] as String? ??
          data['token'] as String? ??
          '',
      refreshToken: data['refreshToken'] as String? ?? '',
      user: UserProfile.fromJson(
        (data['user'] as Map<String, dynamic>?) ??
            (json['user'] as Map<String, dynamic>),
      ),
    );
  }
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

