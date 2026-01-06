import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      message: json['message'],
      token: json['token'],
      user: json['data'] != null && json['data']['user'] != null
          ? UserModel.fromJson(json['data']['user'])
          : null,
    );
  }
}
