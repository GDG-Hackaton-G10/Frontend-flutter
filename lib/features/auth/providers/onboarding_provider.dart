import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_providers.dart';

final onboardingSeenProvider =
    StateNotifierProvider<OnboardingSeenNotifier, bool?>((ref) {
      final storage = ref.watch(secureStorageProvider);
      return OnboardingSeenNotifier(storage)..load();
    });

class OnboardingSeenNotifier extends StateNotifier<bool?> {
  OnboardingSeenNotifier(this._storage) : super(null);

  static const _onboardingKey = 'seen_onboarding_v1';

  final FlutterSecureStorage _storage;

  Future<void> load() async {
    final value = await _storage.read(key: _onboardingKey);
    state = value == 'true';
  }

  Future<void> markSeen() async {
    await _storage.write(key: _onboardingKey, value: 'true');
    state = true;
  }
}
