import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/user_role.dart';
import 'profile_completion_banner.dart';

class BentoHomeScreen extends ConsumerWidget {
  const BentoHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);
    return authAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        final showBanner =
            user?.role == UserRole.patient &&
            (user?.pharmacyDetails?['profileIsComplete'] == false);
        return Scaffold(
          appBar: AppBar(title: const Text('Bento Home')),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (showBanner)
                ProfileCompletionBanner(
                  onComplete: () {
                    // TODO: Navigate to Profile Edit screen
                  },
                ),
              // ...rest of your home content...
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Welcome to Bento Home!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
