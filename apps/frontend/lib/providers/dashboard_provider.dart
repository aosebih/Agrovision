import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/remote/dashboard_response.dart';
import '../models/remote/crop_model.dart';

enum LoadState { idle, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api;
  DashboardProvider(this._api);

  LoadState _state = LoadState.idle;
  DashboardData? _data;
  List<RemoteCrop> _crops = [];
  String? _errorMessage;

  LoadState get state => _state;
  DashboardData? get data => _data;
  List<RemoteCrop> get crops => List.unmodifiable(_crops);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _state = LoadState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _api.get('/dashboard'),
        _api.get('/dashboard/crops'),
      ]);

      // Handle both wrapped {data: ...} and direct response
      final dashRaw = results[0];
      final dashMap = dashRaw is Map && dashRaw.containsKey('data')
          ? dashRaw['data'] as Map<String, dynamic>
          : dashRaw as Map<String, dynamic>;
      _data = DashboardData.fromJson(dashMap);

      final cropsRaw = results[1];
      final cropsList = cropsRaw is Map && cropsRaw.containsKey('data')
          ? cropsRaw['data'] as List
          : cropsRaw as List;
      _crops = cropsList.map((e) => RemoteCrop.fromJson(e as Map<String, dynamic>)).toList();

      _state = LoadState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = LoadState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
    }
    notifyListeners();
  }
}
