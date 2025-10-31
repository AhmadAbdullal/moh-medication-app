import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:moh_medication_app/core/config.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;

  Future<http.Response> get(String path) async {
    final response = await _httpClient.get(Uri.parse('$baseUrl$path'));
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final response = await _httpClient.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final response = await _httpClient.delete(Uri.parse('$baseUrl$path'));
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw ApiException(
      response.statusCode,
      response.body,
    );
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
