import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<(double, double, double)> getWeather(double lat, double lon) async {
    final r = await http.get(Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,precipitation'));
    if (r.statusCode == 200) {
      final d = jsonDecode(r.body)['current'];
      return (
        (d['temperature_2m'] as num).toDouble(),
        (d['relative_humidity_2m'] as num).toDouble(),
        ((d['precipitation'] ?? 0) as num).toDouble(),
      );
    }
    return (25.0, 65.0, 150.0);
  }
}
