import 'package:dio/dio.dart';

import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await dio.post('/api/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final res = await dio.post('/api/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> verifyOtp(String otp) async {
    final res = await dio.post('/api/login/verify-user', data: {
      'otp': otp,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<UserModel> getUser() async {
    final res = await dio.get('/api/user');
    return UserModel.fromJson(res.data['data']);
  }

  Future<void> logout() async {
    await dio.post('/api/logout');
  }

  Future<void> resendVerificationEmail(String email) async {
    await dio.post(
      '/api/email/verification-notification',
      data: {'email': email},
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await dio.post(
      '/api/forgot-password',
      data: {'email': email},
    );
  }

}
