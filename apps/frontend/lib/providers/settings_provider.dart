import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/remote/settings_model.dart';
// Required packages (add to pubspec.yaml if not present):
//   geolocator: ^12.0.0
//   geocoding: ^3.0.0

class SettingsProvider extends ChangeNotifier {
  final ApiClient _api;

  SettingsProvider(this._api);

  // Default fallback used before the first successful API load
  RemoteSettings _settings = const RemoteSettings(
    userName: '',
    email: '',
    farmName: null,
    notificationsEnabled: true,
    weatherAlerts: true,
    storageAlerts: false,
    darkMode: false,
    language: 'ar',
    location: '',
    updatedAt: '',
  );

  bool _isLoading = false;
  bool _isLocating = false;
  String? _errorMessage;

  RemoteSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  String? get errorMessage => _errorMessage;

  /// Saves a plain location string (city name or coordinate string) and
  /// syncs it to the backend.
  Future<void> updateLocation(String location) =>
      update(_settings.copyWith(location: location));

  Future<void> updateProfile({
    required String userName,
    required String farmName,
    required String email,
  }) =>
      update(_settings.copyWith(
        userName: userName,
        farmName: farmName.isEmpty ? null : farmName,
        email: email,
      ));

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/users/me');
      _settings = RemoteSettings.fromJson(res as Map<String, dynamic>);
      await _persistLocally(_settings);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _settings = await _loadLocally() ?? _settings;
    } catch (_) {
      _errorMessage = 'تعذر تحميل بيانات المستخدم';
      _settings = await _loadLocally() ?? _settings;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> update(RemoteSettings updated) async {
    final previous = _settings;
    _settings = updated;
    notifyListeners();

    try {
      final res = await _api.patch('/users/me', updated.toJson());
      _settings = RemoteSettings.fromJson(res as Map<String, dynamic>);
      await _persistLocally(_settings);
      _errorMessage = null;
    } on ApiException catch (e) {
      _settings = previous;
      _errorMessage = e.message;
    } catch (_) {
      _settings = previous;
      _errorMessage = 'فشل حفظ الإعدادات';
    }
    notifyListeners();
  }

  // ── Change Password ───────────────────────────────────────────────────────
  Future<void> changePassword(String newPassword) async {
    try {
      await _api.patch('/users/me', {'password': newPassword});
    } on ApiException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (_) {
      _errorMessage = 'فشل تغيير كلمة المرور';
      rethrow;
    }
  }

  // Convenience toggles
  Future<void> toggleNotifications(bool val) =>
      update(_settings.copyWith(notificationsEnabled: val));

  Future<void> toggleWeatherAlerts(bool val) =>
      update(_settings.copyWith(weatherAlerts: val));

  Future<void> toggleStorageAlerts(bool val) =>
      update(_settings.copyWith(storageAlerts: val));

  Future<void> toggleDarkMode(bool val) async {
    _settings = _settings.copyWith(darkMode: val);
    notifyListeners();
    await _persistLocally(_settings);
    try { await _api.patch('/users/me', _settings.toJson()); } catch (_) {}
  }

  Future<void> changeLanguage(String lang) async {
    _settings = _settings.copyWith(language: lang);
    notifyListeners();
    await _persistLocally(_settings);
    try { await _api.patch('/users/me', _settings.toJson()); } catch (_) {}
  }

  // ── Local persistence (fallback when offline) ─────────────────────────────
  static const _prefsKey = 'agri_settings';

  Future<void> _persistLocally(RemoteSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefsKey}_name', s.userName);
    await prefs.setString('${_prefsKey}_email', s.email);
    await prefs.setString('${_prefsKey}_farm', s.farmName ?? '');
    await prefs.setBool('${_prefsKey}_notif', s.notificationsEnabled);
    await prefs.setBool('${_prefsKey}_weather', s.weatherAlerts);
    await prefs.setBool('${_prefsKey}_storage', s.storageAlerts);
    await prefs.setBool('${_prefsKey}_dark', s.darkMode);
    await prefs.setString('${_prefsKey}_lang', s.language);
    await prefs.setString('${_prefsKey}_loc', s.location);
  }

  Future<RemoteSettings?> _loadLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('${_prefsKey}_notif')) return null;
    return RemoteSettings(
      userName: prefs.getString('${_prefsKey}_name') ?? '',
      email: prefs.getString('${_prefsKey}_email') ?? '',
      farmName: prefs.getString('${_prefsKey}_farm'),
      notificationsEnabled: prefs.getBool('${_prefsKey}_notif') ?? true,
      weatherAlerts: prefs.getBool('${_prefsKey}_weather') ?? true,
      storageAlerts: prefs.getBool('${_prefsKey}_storage') ?? false,
      darkMode: prefs.getBool('${_prefsKey}_dark') ?? false,
      language: prefs.getString('${_prefsKey}_lang') ?? 'ar',
      location: prefs.getString('${_prefsKey}_loc') ?? '',
      updatedAt: '',
    );
  }
}