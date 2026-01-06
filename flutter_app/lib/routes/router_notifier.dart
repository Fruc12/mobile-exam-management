// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../features/auth/controllers/auth_controller.dart';
// import '../features/auth/controllers/auth_state.dart';
//
// class RouterNotifier extends ChangeNotifier {
//   RouterNotifier(this.ref) {
//     ref.listen<AuthStatus>(
//       authControllerProvider as ProviderListenable<AuthStatus>,
//           (_, __) => notifyListeners(),
//     );
//   }
//
//   final Ref ref;
//
//   AuthState get authState => ref.read(authControllerProvider);
// }
