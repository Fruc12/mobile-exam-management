import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class EmailVerificationInfoScreen extends ConsumerStatefulWidget {
  const EmailVerificationInfoScreen({super.key});

  @override
  ConsumerState<EmailVerificationInfoScreen> createState() =>
      _EmailVerificationInfoScreenState();
}

class _EmailVerificationInfoScreenState
    extends ConsumerState<EmailVerificationInfoScreen> {
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendVerificationEmail();

      setState(() {
        _success = 'Lien de vérification renvoyé avec succès.';
      });
    } catch (e) {
      setState(() => _error = e.toString());
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
                'Un lien de vérification a été envoyé à votre adresse email.\n'
                    'Veuillez vérifier votre boîte de réception avant de vous connecter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],

              if (_success != null) ...[
                const SizedBox(height: 16),
                Text(
                  _success!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _resendVerificationEmail,
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Renvoyer le lien'),
                ),
              ),
              const SizedBox(height: 12),
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
