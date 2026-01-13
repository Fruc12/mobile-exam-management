import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute l'état d'initialisation
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      data: (_) => _buildRouterApp(ref),
      loading: () => _buildLoadingApp(),
      error: (err, stack) => _buildRouterApp(ref), // En cas d'erreur, on laisse le routeur gérer (vers login)
    );
  }

  Widget _buildRouterApp(WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Exam Management',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      routerConfig: router,
    );
  }

  Widget _buildLoadingApp() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}