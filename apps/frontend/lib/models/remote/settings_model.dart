library;

class RemoteSettings {
  final bool notificationsEnabled;
  final bool weatherAlerts;
  final bool storageAlerts;
  final bool darkMode;
  final String language;
  final String location;
  final String userName;
  final String updatedAt;

  const RemoteSettings({
    required this.notificationsEnabled, required this.weatherAlerts,
    required this.storageAlerts, required this.darkMode,
    required this.language, required this.location,
    required this.userName, required this.updatedAt,
  });

  factory RemoteSettings.fromJson(Map<String, dynamic> j) => RemoteSettings(
        notificationsEnabled: j['notificationsEnabled'] ?? true,
        weatherAlerts: j['weatherAlerts'] ?? true,
        storageAlerts: j['storageAlerts'] ?? false,
        darkMode: j['darkMode'] ?? false,
        language: j['language'] ?? 'ar',
        location: j['location'] ?? '',
        userName: j['userName'] ?? '',
        updatedAt: j['updatedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'notificationsEnabled': notificationsEnabled,
        'weatherAlerts': weatherAlerts,
        'storageAlerts': storageAlerts,
        'darkMode': darkMode,
        'language': language,
        'location': location,
        'userName': userName,
      };

  RemoteSettings copyWith({
    bool? notificationsEnabled, bool? weatherAlerts,
    bool? storageAlerts, bool? darkMode,
    String? language, String? location, String? userName,
  }) => RemoteSettings(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        weatherAlerts: weatherAlerts ?? this.weatherAlerts,
        storageAlerts: storageAlerts ?? this.storageAlerts,
        darkMode: darkMode ?? this.darkMode,
        language: language ?? this.language,
        location: location ?? this.location,
        userName: userName ?? this.userName,
        updatedAt: DateTime.now().toIso8601String(),
      );
}
