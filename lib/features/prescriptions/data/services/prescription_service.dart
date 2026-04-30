import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_api_client.dart';
import '../models/prescription_model.dart';

class PrescriptionService {
  PrescriptionService({required this.apiClient}) : _api = apiClient;

  final ApiClient apiClient;
  final ApiClient _api;

  Future<List<Prescription>> fetchPrescriptionsForUser(String userId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/prescriptions/user/$userId');
    final request = http.Request('GET', uri);

    final streamed = await _api.send(request);
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      // Assume backend returns { success: true, data: [ ... ] } or raw list
      final listJson = body['data'] ?? body;
      if (listJson is List) {
        return listJson
            .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <Prescription>[];
    }

    throw Exception('Failed to load prescriptions (${resp.statusCode})');
  }
}
