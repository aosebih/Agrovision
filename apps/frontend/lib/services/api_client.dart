library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient extends ChangeNotifier {
  static const String baseUrl = 'http://10.142.58.124:3000/api/v1';
  static const Duration _timeout = Duration(seconds: 30);
  static const _tokenKey = 'auth_token';

  final http.Client _client;
  String? _token;
  late final Future<void> ready;

  ApiClient({http.Client? client}) : _client = client ?? http.Client() {
    ready = _loadToken();
  }

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved != null) {
      _token = saved;
      notifyListeners();
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  Map<String, String> get _headers {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  dynamic _parseResponse(http.Response res) {
    final body = json.decode(res.body);
    if (res.statusCode >= 400) {
      final msg = body is Map
          ? (body['message']?.toString() ?? body['error']?.toString() ?? 'Unknown error')
          : 'Unknown error';
      throw ApiException(statusCode: res.statusCode, message: msg);
    }
    return body;
  }

  Future<dynamic> get(String path) async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl$path'), headers: _headers).timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.post(Uri.parse('$baseUrl$path'), headers: _headers, body: json.encode(body)).timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.patch(Uri.parse('$baseUrl$path'), headers: _headers, body: json.encode(body)).timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.put(Uri.parse('$baseUrl$path'), headers: _headers, body: json.encode(body)).timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final res = await _client.delete(Uri.parse('$baseUrl$path'), headers: _headers).timeout(_timeout);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  Future<dynamic> postMultipart(String path, File imageFile, {Map<String, String>? fields}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      if (fields != null) request.fields.addAll(fields);
      final streamedResponse = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamedResponse);
      return _parseResponse(res);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'لا يوجد اتصال بالشبكة');
    } on TimeoutException {
      throw const ApiException(statusCode: 408, message: 'انتهت مهلة الاتصال');
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}