import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crop_prediction.dart';
import 'prediction_input.dart';

class CropApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static Future<CropPrediction> predict(PredictionInput input) async {
    final r = await http.post(
      Uri.parse('$_baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );
    if (r.statusCode == 200) {
      return CropPrediction.fromJson(jsonDecode(r.body));
    }
    throw Exception('API error: ${r.statusCode}');
  }

  static Future<List<String>> getCrops() async {
    final r = await http.get(Uri.parse('$_baseUrl/crops'));
    if (r.statusCode == 200) {
      return List<String>.from(jsonDecode(r.body)['crops']);
    }
    throw Exception('Failed to fetch crops');
  }
}
