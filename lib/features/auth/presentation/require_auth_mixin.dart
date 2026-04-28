import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';
import '../domain/user_role.dart';

mixin RequireAuthMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  void requireAuth(BuildContext context, VoidCallback action) {
    final user = ref.read(authNotifierProvider).value;
    if (user?.role == UserRole.guest) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Sign In Required'),
          content: const Text('Please sign in to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to sign in
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      action();
    }
  }
}
