import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() { _error = null; });

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 🔴 Validation locale
    if (password != confirmPassword) {
      setState(() {
        _error = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(authControllerProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: password,
      );

      context.go('/verify-email-info');
    } on DioException catch (e) {
      setState(() => _error = e.response?.data['message']);
    } on Exception {
      setState(() => _error = "Une erreur s'est produite");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('S’inscrire'),
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
