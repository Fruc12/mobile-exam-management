import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/email_verification_info_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../features/actor/models/actor_model.dart';
import '../features/actor/screens/actor_form_screen.dart';
import '../features/actor/screens/actor_list_screen.dart';
import '../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    // On définit l'emplacement initial dynamiquement dès le départ
    initialLocation: authState.isAuthenticated ? '/actors' : '/login',
    redirect: (context, state) {
      final loggedIn = authState.isAuthenticated;
      final loggingIn = state.uri.toString() == '/login' ||
          state.uri.toString() == '/register' ||
          state.uri.toString() == '/otp' ||
          state.uri.toString() == '/verify-email-info';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/actors';

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, __) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/verify-email-info',
        builder: (_, __) => const EmailVerificationInfoScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/actors',
        builder: (_, __) => const ActorListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const ActorFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              // Pour l'édition, on peut passer l'objet actor via extra
              return ActorFormScreen(actor: state.extra as ActorModel?);
            },
          ),
        ],
      ),
    ],
  );
});
