import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

enum AuthState { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  AuthProvider(this._api);

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _api.isAuthenticated;
  bool get isLoading => _state == AuthState.loading;

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final token = res['access_token'] as String?;
      if (token == null) throw const ApiException(statusCode: 401, message: 'لم يتم استلام رمز المصادقة');
      _api.setToken(token);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? farmName,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _api.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        if (farmName != null && farmName.isNotEmpty) 'farmName': farmName,
      });
      // Auto-login after register
      return await login(email: email, password: password);
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _api.clearToken();
    _user = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}
