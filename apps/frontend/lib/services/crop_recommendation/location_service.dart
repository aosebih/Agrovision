import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<(double, double, String)> geocode(String address) async {
    final r = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q='
          '${Uri.encodeComponent(address)}&format=json&limit=1'),
      headers: {'User-Agent': 'CropRecommendationApp/1.0'},
    );
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as List;
      if (data.isNotEmpty) {
        return (
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
          data[0]['display_name'] as String,
        );
      }
      throw Exception('الموقع غير موجود');
    }
    throw Exception('Geocoding API error: ${r.statusCode}');
  }
}
