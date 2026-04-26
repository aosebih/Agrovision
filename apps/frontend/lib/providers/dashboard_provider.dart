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

  /// Load dashboard + crops in parallel
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _state = LoadState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // Fire both requests concurrently
      final results = await Future.wait([
        _api.get('/dashboard'),
        _api.get('/dashboard/crops'),
      ]);

      _data = DashboardData.fromJson(results[0]['data'] as Map<String, dynamic>);
      _crops = (results[1]['data'] as List)
          .map((e) => RemoteCrop.fromJson(e as Map<String, dynamic>))
          .toList();
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
