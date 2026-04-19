import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prescription_navigator/core/index.dart';

import '../../../app/main_entry_screen.dart';
import '../providers/auth_controller.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_state.dart';
import 'login_page.dart';
import 'onboarding_flow.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final onboardingSeen = ref.watch(onboardingSeenProvider);

    if (onboardingSeen == null) {
      return const Scaffold(
        body: Center(child: AppLoadingSpinner(size: AppSpinnerSize.large)),
      );
    }

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: AppLoadingSpinner(size: AppSpinnerSize.large)),
      );
    }

    if (authState.status == AuthStatus.authenticated) {
      return const MainEntryScreen();
    }

    if (!onboardingSeen) {
      return OnboardingFlow(
        onFinished: () {
          ref.read(onboardingSeenProvider.notifier).markSeen();
        },
      );
    }

    return const LoginPage();
  }
}
