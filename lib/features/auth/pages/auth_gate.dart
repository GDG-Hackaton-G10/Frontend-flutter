import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_entry_screen.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import 'welcome_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.status == AuthStatus.authenticated) {
      return const MainEntryScreen();
    }

    return const WelcomePage();
  }
}
