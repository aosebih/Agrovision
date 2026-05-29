import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class ForecastDay {
  final String date, description, icon, condition;
  final double tempMin, tempMax;
  final int rainProbability;
  ForecastDay({required this.date, required this.description, required this.icon,
    required this.condition, required this.tempMin, required this.tempMax,
    required this.rainProbability});

  factory ForecastDay.fromJson(Map<String, dynamic> j) => ForecastDay(
    date: j['date'] as String? ?? '',
    description: j['description'] as String? ?? '',
    icon: j['icon'] as String? ?? '01d',
    condition: j['condition'] as String? ?? 'clear',
    tempMin: (j['tempMin'] as num? ?? 0).toDouble(),
    tempMax: (j['tempMax'] as num? ?? 0).toDouble(),
    rainProbability: (j['rainProbability'] as num? ?? 0).toInt(),
  );

  String get dayAr {
    try {
      const d = ['الإثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
      return d[DateTime.parse(date).weekday - 1];
    } catch (_) { return ''; }
  }
  String get dayFr {
    try {
      const d = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
      return d[DateTime.parse(date).weekday - 1];
    } catch (_) { return ''; }
  }
}

class WeatherData {
  final String city, country, description, icon, condition;
  final double temperature, feelsLike;
  final int humidity, windSpeed;
  final List<ForecastDay> forecast;
  WeatherData({required this.city, required this.country, required this.description,
    required this.icon, required this.condition, required this.temperature,
    required this.feelsLike, required this.humidity, required this.windSpeed,
    required this.forecast});

  factory WeatherData.fromJson(Map<String, dynamic> j) => WeatherData(
    city: j['city'] as String? ?? '',
    country: j['country'] as String? ?? '',
    description: j['description'] as String? ?? '',
    icon: j['icon'] as String? ?? '01d',
    condition: j['condition'] as String? ?? 'clear',
    temperature: (j['temperature'] as num? ?? 0).toDouble(),
    feelsLike: (j['feelsLike'] as num? ?? 0).toDouble(),
    humidity: (j['humidity'] as num? ?? 0).toInt(),
    windSpeed: (j['windSpeed'] as num? ?? 0).toInt(),
    forecast: (j['forecast'] as List? ?? [])
        .map((e) => ForecastDay.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

enum WeatherState { idle, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final ApiClient _api;
  WeatherProvider(this._api);

  WeatherState _state = WeatherState.idle;
  WeatherData? _weather;
  String? _error;
  String _location = 'Oran,DZ';

  WeatherState get state => _state;
  WeatherData? get weather => _weather;
  String? get error => _error;
  bool get isLoading => _state == WeatherState.loading;

  Future<void> load({String? location}) async {
    if (location != null && location.isNotEmpty) _location = location;
    _state = WeatherState.loading;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/weather/current?location=${Uri.encodeComponent(_location)}');
      _weather = WeatherData.fromJson(res as Map<String, dynamic>);
      _state = WeatherState.loaded;
    } on ApiException catch (e) {
      _state = WeatherState.error;
      _error = e.message;
    } catch (_) {
      _state = WeatherState.error;
      _error = 'فشل تحميل بيانات الطقس';
    }
    notifyListeners();
  }
}
