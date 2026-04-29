import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/auth/pages/register_page.dart';

class AuthNudgeDialog extends StatelessWidget {
  final VoidCallback? onRegister;
  final VoidCallback? onLater;
  const AuthNudgeDialog({this.onRegister, this.onLater, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Blur background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Unlock Full Potential',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Sign up to save your scan history and track medications over time.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      onRegister ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _findRegisterPage(context),
                          ),
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Create Free Account'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onLater ?? () => Navigator.of(context).pop(),
                  child: const Text('Later'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper to find RegisterPage without import cycle
Widget _findRegisterPage(BuildContext context) {
  return const RegisterPage();
}
