import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_providers.dart';
import '../../data/services/medicine_scan_service.dart';

final medicineScanServiceProvider = Provider<MedicineScanService>((ref) {
  final client = ref.watch(authApiClientProvider);
  return MedicineScanService(client);
});
