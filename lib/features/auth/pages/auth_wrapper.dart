import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../home/presentation/screens/main_navigation_wrapper.dart';
import '../providers/onboarding_provider.dart';
import 'login_page.dart';
import 'onboarding_flow.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingSeen = ref.watch(onboardingSeenProvider);

    if (onboardingSeen == null || authState.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isAuthenticated) {
      return MainNavigationWrapper(role: authState.role);
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
