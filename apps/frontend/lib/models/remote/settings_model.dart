library;

class RemoteSettings {
  final String userName;
  final String email;
  final String? farmName;
  final bool notificationsEnabled;
  final bool weatherAlerts;
  final bool storageAlerts;
  final bool darkMode;
  final String language;
  final String location;
  final String updatedAt;

  const RemoteSettings({
    required this.userName,
    required this.email,
    this.farmName,
    required this.notificationsEnabled,
    required this.weatherAlerts,
    required this.storageAlerts,
    required this.darkMode,
    required this.language,
    required this.location,
    required this.updatedAt,
  });

  // The backend returns the User entity directly from GET /users/me
  factory RemoteSettings.fromJson(Map<String, dynamic> j) => RemoteSettings(
        userName: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        farmName: j['farmName'] as String?,
        notificationsEnabled: j['notificationsEnabled'] as bool? ?? true,
        weatherAlerts: j['weatherAlerts'] as bool? ?? true,
        storageAlerts: j['storageAlerts'] as bool? ?? false,
        darkMode: j['darkMode'] as bool? ?? false,
        language: j['language'] as String? ?? 'ar',
        location: j['location'] as String? ?? '',
        updatedAt: j['updatedAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': userName,
        'farmName': farmName,
        'notificationsEnabled': notificationsEnabled,
        'weatherAlerts': weatherAlerts,
        'storageAlerts': storageAlerts,
        'darkMode': darkMode,
        'language': language,
        'location': location,
      };

  RemoteSettings copyWith({
    String? userName,
    String? email,
    String? farmName,
    bool? notificationsEnabled,
    bool? weatherAlerts,
    bool? storageAlerts,
    bool? darkMode,
    String? language,
    String? location,
  }) =>
      RemoteSettings(
        userName: userName ?? this.userName,
        email: email ?? this.email,
        farmName: farmName ?? this.farmName,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        weatherAlerts: weatherAlerts ?? this.weatherAlerts,
        storageAlerts: storageAlerts ?? this.storageAlerts,
        darkMode: darkMode ?? this.darkMode,
        language: language ?? this.language,
        location: location ?? this.location,
        updatedAt: DateTime.now().toIso8601String(),
      );
}