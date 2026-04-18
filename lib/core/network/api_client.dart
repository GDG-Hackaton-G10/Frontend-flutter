import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request (Important for uploading prescriptions)
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Simple error handling for the Hackathon
  String _handleError(DioException e) {
    final dynamic data = e.response?.data;

    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return "Something went wrong. Check your connection.";
  }
}
