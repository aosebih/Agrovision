import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

import 'load_state.dart';

class Field {
  final String id;
  final String name;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? areaHectares;
  final String status;
  final String? soilType;
  final String createdAt;

  const Field({
    required this.id,
    required this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.areaHectares,
    required this.status,
    this.soilType,
    required this.createdAt,
  });

  factory Field.fromJson(Map<String, dynamic> j) => Field(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        location: j['location'],
        latitude: j['latitude'] != null
            ? double.tryParse(j['latitude'].toString())
            : null,
        longitude: j['longitude'] != null
            ? double.tryParse(j['longitude'].toString())
            : null,
        areaHectares: j['areaHectares'] != null
            ? double.tryParse(j['areaHectares'].toString())
            : null,
        status: j['status'] ?? 'active',
        soilType: j['soilType'],
        createdAt: j['createdAt'] ?? '',
      );

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'fallow':
        return 'بور';
      case 'harvested':
        return 'محصود';
      default:
        return status;
    }
  }
}

class FieldsProvider extends ChangeNotifier {
  final ApiClient _api;
  FieldsProvider(this._api);

  LoadState _state = LoadState.idle;
  List<Field> _fields = [];
  String? _errorMessage;

  LoadState get state => _state;
  List<Field> get fields => List.unmodifiable(_fields);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _api.get('/fields?limit=50');
      final data = res['data'] as List? ?? res['items'] as List? ?? res as List? ?? [];
      _fields = data.map((e) => Field.fromJson(e as Map<String, dynamic>)).toList();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (_) {
      _state = LoadState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
    }
    notifyListeners();
  }

  Future<bool> addField(Map<String, dynamic> dto) async {
    try {
      await _api.post('/fields', dto);
      await load();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteField(String id) async {
    try {
      await _api.delete('/fields/$id');
      _fields = _fields.where((f) => f.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}