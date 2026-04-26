/// Central HTTP client for all backend communication.
/// Change [baseUrl] to point to your NestJS server.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  // ── Configuration ──────────────────────────────────────────────────────────
  // Change this to your server IP when running on a real device.
  // For Android emulator use: http://10.0.2.2:3000/api/v1
  // For iOS simulator use:    http://localhost:3000/api/v1
  // For physical device use:  http://<YOUR_MACHINE_IP>:3000/api/v1
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _parseResponse(http.Response res) {
    final body = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(
        statusCode: res.statusCode,
        message: body['error']?.toString() ?? 'Unknown error',
      );
    }
    return body;
  }

  // ── GET ────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  // ── PUT ────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .put(Uri.parse('$baseUrl$path'),
              headers: _headers, body: json.encode(body))
          .timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  // ── Multipart (image upload) ───────────────────────────────────────────────
  Future<Map<String, dynamic>> postMultipart(
    String path,
    File imageFile, {
    Map<String, String>? fields,
  }) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        // filename hint for the server
      ));

      if (fields != null) request.fields.addAll(fields);

      final streamedResponse =
          await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamedResponse);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  void dispose() => _client.close();
}
