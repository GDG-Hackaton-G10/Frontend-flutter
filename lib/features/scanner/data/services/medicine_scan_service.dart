import 'package:smart_prescription_navigator/core/network/api_constants.dart';
import 'package:smart_prescription_navigator/core/network/auth_api_client.dart';

class MedicineScanService {
  MedicineScanService(this._client);

  final AuthApiClient _client;

  Future<List<String>> extractMedicines({required String rawText}) async {
    final response = await _client.postJson(
      ApiConstants.extractMedicinesPath,
      body: {'text': rawText},
    );

    return _parseMedicines(response);
  }

  List<String> _parseMedicines(Map<String, dynamic> response) {
    final candidates = <dynamic>[
      response['medicines'],
      response['data'] is Map<String, dynamic>
          ? (response['data'] as Map<String, dynamic>)['medicines']
          : null,
      response['data'],
      response['results'],
      response['items'],
    ];

    for (final candidate in candidates) {
      final parsed = _parseCandidate(candidate);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return const <String>[];
  }

  List<String> _parseCandidate(dynamic candidate) {
    if (candidate is List) {
      return candidate
          .map((item) {
            if (item is String) {
              return item.trim();
            }
            if (item is Map<String, dynamic>) {
              return (item['name'] ?? item['medicine'] ?? item['title'] ?? '')
                  .toString()
                  .trim();
            }
            return item.toString().trim();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (candidate is Map<String, dynamic>) {
      final nested = candidate['medicines'];
      if (nested is List) {
        return _parseCandidate(nested);
      }

      final single = (candidate['name'] ?? candidate['medicine'] ?? '')
          .toString()
          .trim();
      if (single.isNotEmpty) {
        return [single];
      }
    }

    return const <String>[];
  }
}
