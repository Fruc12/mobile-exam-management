import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../controllers/auth_controller.dart';

class EmailVerificationInfoScreen extends ConsumerStatefulWidget {
  const EmailVerificationInfoScreen({super.key});

  @override
  ConsumerState<EmailVerificationInfoScreen> createState() =>
      _EmailVerificationInfoScreenState();
}

class _EmailVerificationInfoScreenState
    extends ConsumerState<EmailVerificationInfoScreen> {
  bool _showEmailField = false;
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
          .resendVerificationEmail(
        email: _emailController.text.trim(),
      );

      /// 🟢 2xx → succès
      _showBanner(
        message: 'Lien de vérification envoyé.',
        color: Colors.green,
      );

      /// 🔄 Retour état initial
      setState(() {
        _showEmailField = false;
        _emailController.clear();
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;

      /// 🟡 4xx → succès UX aussi
      if (status >= 400 && status < 500) {
        _showBanner(
          message: 'Lien de vérification envoyé.',
          color: Colors.green,
        );

        setState(() {
          _showEmailField = false;
          _emailController.clear();
        });
      }
      /// 🔴 5xx → erreur bloquante
      else {
        _showBanner(
          message: 'Une erreur est survenue',
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
                Icons.mark_email_read,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'Vous devez vérifier votre adresse email avant de pouvoir vous connecter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              if (_showEmailField) ...[
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
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _showEmailField = true);
                    },
                    child: const Text('Renvoyer le lien'),
                  ),
                ),
              ],

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
