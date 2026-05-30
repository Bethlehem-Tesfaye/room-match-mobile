import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;

  Future<Map<String, String>> _headers({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    final token = await _storage.getToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path').replace(
      queryParameters: query?.isNotEmpty == true ? query : null,
    );
    final response = await http.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    final response = await http.put(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    final response = await http.delete(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<dynamic> multipart(
    String method,
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    final request = http.MultipartRequest(method, uri);
    request.headers.addAll(await _headers(json: false));
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map && body['message'] != null
        ? body['message'] as String
        : 'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
