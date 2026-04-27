import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

enum LoadState { idle, loading, loaded, error }

class DashboardSummary {
  final int totalCrops;
  final int totalIrrigationEvents;
  final int unreadAlerts;
  final int lowStockItems;
  final double averageCropHealth;

  DashboardSummary({
    required this.totalCrops,
    required this.totalIrrigationEvents,
    required this.unreadAlerts,
    required this.lowStockItems,
    required this.averageCropHealth,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    totalCrops: j['totalCrops'] ?? 0,
    totalIrrigationEvents: j['totalIrrigationEvents'] ?? 0,
    unreadAlerts: j['unreadAlerts'] ?? 0,
    lowStockItems: j['lowStockItems'] ?? 0,
    averageCropHealth: double.tryParse(j['averageCropHealth']?.toString() ?? '0') ?? 0,
  );
}

class CropHealthEntry {
  final String id;
  final String name;
  final double healthScore;
  final String growthStage;
  final String status;

  CropHealthEntry({
    required this.id,
    required this.name,
    required this.healthScore,
    required this.growthStage,
    required this.status,
  });

  factory CropHealthEntry.fromJson(Map<String, dynamic> j) => CropHealthEntry(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    healthScore: (j['healthScore'] as num?)?.toDouble() ?? 0,
    growthStage: j['growthStage'] ?? '',
    status: j['status'] ?? 'unknown',
  );
}

class AlertEntry {
  final String type;
  final String severity;
  final int count;

  AlertEntry({required this.type, required this.severity, required this.count});

  factory AlertEntry.fromJson(Map<String, dynamic> j) => AlertEntry(
    type: j['type'] ?? '',
    severity: j['severity'] ?? '',
    count: int.tryParse(j['count']?.toString() ?? '0') ?? 0,
  );
}

class IrrigationStats {
  final int totalEvents;
  final double totalWaterLiters;
  final double totalDurationMinutes;
  final double averageWaterPerEvent;

  IrrigationStats({
    required this.totalEvents,
    required this.totalWaterLiters,
    required this.totalDurationMinutes,
    required this.averageWaterPerEvent,
  });

  factory IrrigationStats.fromJson(Map<String, dynamic> j) => IrrigationStats(
    totalEvents: j['totalEvents'] ?? 0,
    totalWaterLiters: (j['totalWaterLiters'] as num?)?.toDouble() ?? 0,
    totalDurationMinutes: (j['totalDurationMinutes'] as num?)?.toDouble() ?? 0,
    averageWaterPerEvent: double.tryParse(j['averageWaterPerEvent']?.toString() ?? '0') ?? 0,
  );
}

class AnalyticsProvider extends ChangeNotifier {
  final ApiClient _api;
  AnalyticsProvider(this._api);

  LoadState _state = LoadState.idle;
  String? _errorMessage;

  DashboardSummary? _summary;
  List<CropHealthEntry> _cropHealth = [];
  List<AlertEntry> _alerts = [];
  IrrigationStats? _irrigation;
  Map<String, dynamic>? _fertilizerUsage;

  LoadState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;
  DashboardSummary? get summary => _summary;
  List<CropHealthEntry> get cropHealth => List.unmodifiable(_cropHealth);
  List<AlertEntry> get alerts => List.unmodifiable(_alerts);
  IrrigationStats? get irrigation => _irrigation;
  Map<String, dynamic>? get fertilizerUsage => _fertilizerUsage;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.get('/analytics/dashboard'),
        _api.get('/analytics/crop-health'),
        _api.get('/analytics/alerts'),
        _api.get('/analytics/irrigation'),
        _api.get('/analytics/fertilizers'),
      ]);

      _summary = DashboardSummary.fromJson(results[0] as Map<String, dynamic>);

      final cropData = results[1];
      if (cropData is List) {
        _cropHealth = cropData.map((e) => CropHealthEntry.fromJson(e as Map<String, dynamic>)).toList();
      }

      final alertData = results[2];
      if (alertData is List) {
        _alerts = alertData.map((e) => AlertEntry.fromJson(e as Map<String, dynamic>)).toList();
      }

      _irrigation = IrrigationStats.fromJson(results[3] as Map<String, dynamic>);
      _fertilizerUsage = results[4] as Map<String, dynamic>?;

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
}
