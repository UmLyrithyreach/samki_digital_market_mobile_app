import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AuthRequiredView extends StatelessWidget {
  final String title;
  final String message;

  const AuthRequiredView({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: SamkiTheme.border),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SamkiTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SamkiTheme.secondary, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Sign In / Register'),
            ),
          ],
        ),
      ),
    );
  }
}
