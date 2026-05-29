import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

import 'load_state.dart';

class RemoteAlert {
  final String id;
  final String title;
  final String message;
  final String type;
  final String severity;
  final bool isRead;
  final bool isAcknowledged;
  final String createdAt;

  RemoteAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.isRead,
    required this.isAcknowledged,
    required this.createdAt,
  });

  factory RemoteAlert.fromJson(Map<String, dynamic> j) => RemoteAlert(
        id: j['id'] as String,
        title: j['title'] as String,
        message: j['message'] as String,
        type: j['type'] as String? ?? 'system',
        severity: j['severity'] as String? ?? 'info',
        isRead: j['isRead'] as bool? ?? false,
        isAcknowledged: j['isAcknowledged'] as bool? ?? false,
        createdAt: j['createdAt'] as String? ?? '',
      );

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';
}

class AlertsProvider extends ChangeNotifier {
  final ApiClient _api;
  AlertsProvider(this._api);

  LoadState _state = LoadState.idle;
  List<RemoteAlert> _alerts = [];
  int _unreadCount = 0;
  String? _errorMessage;

  LoadState get state => _state;
  List<RemoteAlert> get alerts => List.unmodifiable(_alerts);
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;

  Future<void> load({String? type}) async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final path = type != null
          ? '/alerts?type=$type&limit=50'
          : '/alerts?limit=50';
      final res = await _api.get(path);
      final list = res['items'] as List? ?? res['data'] as List? ?? [];
      _alerts = list
          .map((e) => RemoteAlert.fromJson(e as Map<String, dynamic>))
          .toList();
      _unreadCount = _alerts.where((a) => !a.isRead).length;
      _state = LoadState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (_) {
      _state = LoadState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await _api.patch('/alerts/$id/read', {});
      final idx = _alerts.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final old = _alerts[idx];
        _alerts = List.from(_alerts)
          ..[idx] = RemoteAlert(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            severity: old.severity,
            isRead: true,
            isAcknowledged: old.isAcknowledged,
            createdAt: old.createdAt,
          );
        _unreadCount = _alerts.where((a) => !a.isRead).length;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.patch('/alerts/mark-all-read', {});
      _alerts = _alerts
          .map((a) => RemoteAlert(
                id: a.id,
                title: a.title,
                message: a.message,
                type: a.type,
                severity: a.severity,
                isRead: true,
                isAcknowledged: a.isAcknowledged,
                createdAt: a.createdAt,
              ))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> acknowledge(String id) async {
    try {
      await _api.patch('/alerts/$id/acknowledge', {});
      final idx = _alerts.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final old = _alerts[idx];
        _alerts = List.from(_alerts)
          ..[idx] = RemoteAlert(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            severity: old.severity,
            isRead: true,
            isAcknowledged: true,
            createdAt: old.createdAt,
          );
        _unreadCount = _alerts.where((a) => !a.isRead).length;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteAlert(String id) async {
    try {
      await _api.delete('/alerts/$id');
      _alerts = _alerts.where((a) => a.id != id).toList();
      _unreadCount = _alerts.where((a) => !a.isRead).length;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteAll() async {
    try {
      await _api.delete('/alerts');
      _alerts = [];
      _unreadCount = 0;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }
}