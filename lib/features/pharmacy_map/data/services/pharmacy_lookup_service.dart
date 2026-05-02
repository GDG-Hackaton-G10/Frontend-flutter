import 'package:smart_prescription_navigator/core/network/api_constants.dart';
import 'package:smart_prescription_navigator/core/network/auth_api_client.dart';

class PharmacyLookupService {
  PharmacyLookupService(this._client);

  final AuthApiClient _client;

  Future<List<Map<String, dynamic>>> fetchNearbyPharmacies({
    required List<String> medicines,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.postJson(
      ApiConstants.nearbyPharmaciesPath,
      body: {
        'medicines': medicines,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return _parsePharmacies(response);
  }

  List<Map<String, dynamic>> _parsePharmacies(Map<String, dynamic> response) {
    final candidates = <dynamic>[
      response['pharmacies'],
      response['results'],
      response['items'],
      response['data'] is Map<String, dynamic>
          ? (response['data'] as Map<String, dynamic>)['pharmacies']
          : null,
      response['data'],
    ];

    for (final candidate in candidates) {
      final parsed = _parseCandidate(candidate);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _parseCandidate(dynamic candidate) {
    if (candidate is List) {
      return candidate
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .map((item) {
            return {
              'name':
                  (item['name'] ??
                          item['pharmacyName'] ??
                          item['title'] ??
                          'Pharmacy')
                      .toString(),
              'lat': _parseCoordinate(item['lat'] ?? item['latitude']),
              'lng': _parseCoordinate(item['lng'] ?? item['longitude']),
              'type': (item['type'] ?? item['status'] ?? 'Nearby').toString(),
            };
          })
          .where((item) => item['lat'] != null && item['lng'] != null)
          .cast<Map<String, dynamic>>()
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  double? _parseCoordinate(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}
