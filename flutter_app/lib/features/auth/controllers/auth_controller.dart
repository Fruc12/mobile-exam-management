import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// ----------------------
/// STATE
/// ----------------------
class AuthState {
  final bool isAuthenticated;
  final String? email;
  final UserModel? user;

  const AuthState({
    required this.isAuthenticated,
    this.email,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
    UserModel? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      user: user ?? this.user,
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
    await _authService.login(email, password);
  }

  /// VERIFY OTP → TOKEN
  Future<void> verifyOtp({required String otp}) async {
    final response = await _authService.verifyOtp(otp);

    if (response.token == null) {
      throw Exception(response.message);
    }

    await SecureStorage.saveToken(response.token!);
    await tryAutoLogin(); // On récupère l'user immédiatement après le token
  }

  /// REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _authService.register(name, email, password);

    if (response.success != true) {
      throw Exception(response.message);
    }
  }

  /// RESEND EMAIL
  Future<void> resendVerificationEmail({required String email}) async {
    await _authService.resendVerificationEmail(email);
  }

  /// AUTO LOGIN
  Future<void> tryAutoLogin() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    try {
      final user = await _authService.getUser();
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    await SecureStorage.clear();
    state = const AuthState(isAuthenticated: false);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> resetPassword({required String token, required String email, required String password}) async {
    await _authService.resetPassword(token, email, password);
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

final appBootstrapProvider = FutureProvider<void>((ref) async {
  try {
    final authController = ref.read(authControllerProvider.notifier);
    await authController.tryAutoLogin();
  } on DioException {
    await SecureStorage.clear();
    rethrow;
  }
});
