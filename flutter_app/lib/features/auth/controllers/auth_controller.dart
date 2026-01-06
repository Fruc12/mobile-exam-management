import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/auth_service.dart';

/// ----------------------
/// STATE
/// ----------------------
class AuthState {
  final bool isAuthenticated;
  final String? email;

  const AuthState({
    required this.isAuthenticated,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
    );
  }
}

/// ----------------------
/// CONTROLLER
/// ----------------------
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authService)
      : super(const AuthState(isAuthenticated: false));

  final AuthService _authService;

  /// LOGIN → OTP
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(email, password);

    if (response.success != true) {
      printToConsole(response.message);
      throw Exception(response.message);
    }

    state = state.copyWith(email: email);
  }

  /// VERIFY OTP → TOKEN
  Future<void> verifyOtp({required String otp}) async {
    final response = await _authService.verifyOtp(otp);

    if (response.token == null) {
      throw Exception(response.message);
    }

    await SecureStorage.saveToken(response.token!);

    state = state.copyWith(isAuthenticated: true);
  }

  /// REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response =
    await _authService.register(name, email, password);

    if (response.success != true) {
      throw Exception(response.message);
    }

    state = state.copyWith(email: email);

  }

  /// RESEND EMAIL
  Future<void> resendVerificationEmail() async {
    if (state.email == null) {
      throw Exception('Email introuvable');
    }

    await _authService.resendVerificationEmail(state.email!);
  }

  /// AUTO LOGIN
  Future<void> tryAutoLogin() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    await _authService.getUser();
    state = state.copyWith(isAuthenticated: true);
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    await SecureStorage.clear();
    state = const AuthState(isAuthenticated: false);
  }
}

/// ----------------------
/// PROVIDER
/// ----------------------
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(
    AuthService(DioClient.create()),
  ),
);
