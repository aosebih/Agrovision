import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/remote/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiClient _api;

  SettingsProvider(this._api);

  // Default fallback (used before first API load)
  RemoteSettings _settings = const RemoteSettings(
    notificationsEnabled: true,
    weatherAlerts: true,
    storageAlerts: false,
    darkMode: false,
    language: 'ar',
    location: 'سالیناس، کالیفورنیا',
    userName: 'أحمد المنصور',
    updatedAt: '',
  );

  bool _isLoading = false;
  String? _errorMessage;

  RemoteSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/settings');
      _settings = RemoteSettings.fromJson(res['data'] as Map<String, dynamic>);
      await _persistLocally(_settings);
    } on ApiException {
      // Fall back to locally cached settings
      _settings = await _loadLocally() ?? _settings;
    } catch (_) {
      _settings = await _loadLocally() ?? _settings;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────────
  Future<void> update(RemoteSettings updated) async {
    // Optimistic update
    _settings = updated;
    notifyListeners();

    try {
      final res = await _api.put('/settings', updated.toJson());
      _settings = RemoteSettings.fromJson(res['data'] as Map<String, dynamic>);
      await _persistLocally(_settings);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'فشل حفظ الإعدادات';
    }
    notifyListeners();
  }

  // Convenience toggles
  Future<void> toggleNotifications(bool val) =>
      update(_settings.copyWith(notificationsEnabled: val));

  Future<void> toggleWeatherAlerts(bool val) =>
      update(_settings.copyWith(weatherAlerts: val));

  Future<void> toggleStorageAlerts(bool val) =>
      update(_settings.copyWith(storageAlerts: val));

  Future<void> toggleDarkMode(bool val) =>
      update(_settings.copyWith(darkMode: val));

  // ── Persistence ─────────────────────────────────────────────────────────────
  static const _prefsKey = 'agri_settings';

  Future<void> _persistLocally(RemoteSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefsKey}_notif', s.notificationsEnabled);
    await prefs.setBool('${_prefsKey}_weather', s.weatherAlerts);
    await prefs.setBool('${_prefsKey}_storage', s.storageAlerts);
    await prefs.setBool('${_prefsKey}_dark', s.darkMode);
    await prefs.setString('${_prefsKey}_lang', s.language);
    await prefs.setString('${_prefsKey}_loc', s.location);
    await prefs.setString('${_prefsKey}_name', s.userName);
  }

  Future<RemoteSettings?> _loadLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('${_prefsKey}_notif')) return null;
    return RemoteSettings(
      notificationsEnabled: prefs.getBool('${_prefsKey}_notif') ?? true,
      weatherAlerts: prefs.getBool('${_prefsKey}_weather') ?? true,
      storageAlerts: prefs.getBool('${_prefsKey}_storage') ?? false,
      darkMode: prefs.getBool('${_prefsKey}_dark') ?? false,
      language: prefs.getString('${_prefsKey}_lang') ?? 'ar',
      location: prefs.getString('${_prefsKey}_loc') ?? '',
      userName: prefs.getString('${_prefsKey}_name') ?? '',
      updatedAt: '',
    );
  }
}
