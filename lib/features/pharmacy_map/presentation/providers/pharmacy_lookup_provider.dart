import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_providers.dart';
import '../../data/services/pharmacy_lookup_service.dart';

final pharmacyLookupServiceProvider = Provider<PharmacyLookupService>((ref) {
  final client = ref.watch(authApiClientProvider);
  return PharmacyLookupService(client);
});
