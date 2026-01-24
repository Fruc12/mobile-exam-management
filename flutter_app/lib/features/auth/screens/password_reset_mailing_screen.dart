import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class PasswordResetMailingScreen extends ConsumerStatefulWidget {
  const PasswordResetMailingScreen({super.key});

  @override
  ConsumerState<PasswordResetMailingScreen> createState() =>
      _PasswordResetMailingScreenState();
}

class _PasswordResetMailingScreenState
    extends ConsumerState<PasswordResetMailingScreen> {
  bool _loading = false;

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showBanner({
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _submitEmail() async {
    setState(() => _loading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      /// 🟢 2xx → succès
      _showBanner(
        message: 'Lien de réinitialisation envoyé.',
        color: Colors.green,
      );

      /// 🔄 Retour état initial
      setState(() {
        _emailController.clear();
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;

      /// 🟡 4xx → succès UX aussi
      if (status == 400) {
        _showBanner(
          message: 'Lien de réinitialisation envoyé.',
          color: Colors.green,
        );

        setState(() {
          _emailController.clear();
        });
      }
      /// 🔴 4xx sauf 400 et 5xx → erreur bloquante
      else {
        _showBanner(
          message: e.response?.data['message'] ?? 'Une erreur est survenue',
          color: Colors.red,
        );
      }
    } catch (_) {
      _showBanner(
        message: 'Une erreur est survenue',
        color: Colors.red,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'Veuillez entrer votre adresse email. Un mail de réinitialisation de votre compte sera envoyé.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _submitEmail,
                    child: _loading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Valider'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
