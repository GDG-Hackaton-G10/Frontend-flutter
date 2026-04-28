import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/auth_notifier.dart';
import 'bento_home_screen.dart';
import 'pharmacy_dashboard_screen.dart';
import '../auth/domain/user_role.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        // If user is null or guest, always show BentoHomeScreen
        if (user == null || user.role == UserRole.guest) {
          return const BentoHomeScreen();
        }
        // If user is pharmacy, show dashboard
        if (user.role == UserRole.pharmacy) {
          return const PharmacyDashboardScreen();
        }
        // If user is patient, show BentoHomeScreen
        return const BentoHomeScreen();
      },
    );
  }
}
