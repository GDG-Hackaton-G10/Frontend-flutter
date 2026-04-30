import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/auth_api_client.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/models/prescription_model.dart';
import '../../data/services/prescription_service.dart';

enum PrescriptionsStatus { initial, loading, loaded, empty, error }

class PrescriptionsState {
  const PrescriptionsState({
    this.status = PrescriptionsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final PrescriptionsStatus status;
  final List<Prescription> items;
  final String? errorMessage;

  PrescriptionsState copyWith({
    PrescriptionsStatus? status,
    List<Prescription>? items,
    String? errorMessage,
  }) {
    return PrescriptionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PrescriptionsNotifier extends StateNotifier<PrescriptionsState> {
  PrescriptionsNotifier({required this.ref})
    : super(const PrescriptionsState());

  final Ref ref;

  PrescriptionService get _service {
    final apiClient = ApiClient(
      onUnauthorized: () async {
        await ref.read(authProvider.notifier).logout();
      },
    );
    return PrescriptionService(apiClient: apiClient);
  }

  Future<void> loadPrescriptions() async {
    state = state.copyWith(status: PrescriptionsStatus.loading);

    final auth = ref.read(authProvider);
    final uid = auth.uid;
    if (uid == null || uid.isEmpty) {
      state = state.copyWith(status: PrescriptionsStatus.empty, items: []);
      return;
    }

    try {
      final list = await _service.fetchPrescriptionsForUser(uid);
      if (list.isEmpty) {
        state = state.copyWith(status: PrescriptionsStatus.empty, items: []);
      } else {
        state = state.copyWith(status: PrescriptionsStatus.loaded, items: list);
      }
    } catch (e) {
      state = state.copyWith(
        status: PrescriptionsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final prescriptionsProvider =
    StateNotifierProvider<PrescriptionsNotifier, PrescriptionsState>((ref) {
      final notifier = PrescriptionsNotifier(ref: ref);
      // Load once when provider is created
      Future.microtask(() => notifier.loadPrescriptions());
      return notifier;
    });
