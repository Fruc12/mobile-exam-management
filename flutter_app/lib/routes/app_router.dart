import 'package:exam_management/features/auth/screens/password_forgot_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/email_verification_info_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../features/actor/models/actor_model.dart';
import '../features/actor/screens/actor_detail_screen.dart';
import '../features/actor/screens/actor_form_screen.dart';
import '../features/actor/screens/actor_list_screen.dart';
import '../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/actors' : '/login',
    redirect: (context, state) {
      final loggedIn = authState.isAuthenticated;
      final loggingIn = state.uri.toString() == '/login' ||
          state.uri.toString() == '/register' ||
          state.uri.toString() == '/otp' ||
          state.uri.toString() == '/verify-email-info' ||
          state.uri.toString() == '/forgot-password' ||
          state.uri.toString().startsWith('/reset-password');

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/actors';

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/verify-email-info',
        builder: (context, state) => const EmailVerificationInfoScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const PasswordResetMailingScreen(),
      ),
      // GoRoute(
      //   path: '/reset-password/:token',
      //   builder: (context, state) {
      //     final String token = state.pathParameters['token'] ?? '';
      //     return PasswordResetScreen(token: token);
      //   },
      // ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/actors',
        builder: (context, state) => const ActorListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) {
              final userId = state.uri.queryParameters['userId'];
              return ActorFormScreen(userId: userId != null ? int.tryParse(userId) : null);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              final userId = state.uri.queryParameters['userId'];
              
              return ActorDetailScreen(
                actorId: (id != 0 && id != null) ? id : null,
                userId: userId != null ? int.tryParse(userId) : null,
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  return ActorFormScreen(actor: state.extra as ActorModel?);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
