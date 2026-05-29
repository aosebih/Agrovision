// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String baseUrl = 'http://10.142.58.124:3000/api/v1';

  Future<AskResponse> ask(String question) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/ask'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AskResponse.fromJson(jsonDecode(response.body));
      } else {
        return AskResponse.error('خطأ في الخادم: ${response.statusCode}');
      }
    } catch (e) {
      return AskResponse.error('تعذّر الاتصال بالخادم');
    }
  }
}

class AskResponse {
  final String answer;
  final bool success;
  final double? confidence;
  final List<String>? sources;
  final String timestamp;

  AskResponse({
    required this.answer,
    required this.success,
    this.confidence,
    this.sources,
    required this.timestamp,
  });

  factory AskResponse.fromJson(Map<String, dynamic> json) {
    return AskResponse(
      answer: json['answer'] ?? '',
      success: json['success'] ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
      sources: json['sources'] != null
          ? List<String>.from(json['sources'])
          : null,
      timestamp: json['timestamp'] ?? '',
    );
  }

  factory AskResponse.error(String message) {
    return AskResponse(
      answer: message,
      success: false,
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}