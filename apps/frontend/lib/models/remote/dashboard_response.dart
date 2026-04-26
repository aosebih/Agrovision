/// Remote models — exactly mirrors the NestJS API response shapes.
library;

// ── Weather ────────────────────────────────────────────────────────────────
class WeatherHour {
  final String time;
  final int temp;
  final String condition;
  const WeatherHour({required this.time, required this.temp, required this.condition});

  factory WeatherHour.fromJson(Map<String, dynamic> j) =>
      WeatherHour(time: j['time'], temp: j['temp'], condition: j['condition']);
}

class WeatherDay {
  final String day;
  final String label;
  final String condition;
  final int tempMin;
  final int tempMax;
  const WeatherDay({required this.day, required this.label,
      required this.condition, required this.tempMin, required this.tempMax});

  factory WeatherDay.fromJson(Map<String, dynamic> j) => WeatherDay(
        day: j['day'], label: j['label'], condition: j['condition'],
        tempMin: j['tempMin'], tempMax: j['tempMax']);
}

class WeatherData {
  final String location;
  final List<WeatherDay> days;
  final List<WeatherHour> todayHours;
  const WeatherData({required this.location, required this.days, required this.todayHours});

  factory WeatherData.fromJson(Map<String, dynamic> j) => WeatherData(
        location: j['location'],
        days: (j['days'] as List).map((d) => WeatherDay.fromJson(d)).toList(),
        todayHours: (j['todayHours'] as List).map((h) => WeatherHour.fromJson(h)).toList());
}

// ── Crop Health ────────────────────────────────────────────────────────────
class CropHealthSummary {
  final int totalFields;
  final int healthyCount;
  final int warningCount;
  final int criticalCount;
  final int overallHealthPercent;
  final String statusLabel;
  const CropHealthSummary({
    required this.totalFields, required this.healthyCount,
    required this.warningCount, required this.criticalCount,
    required this.overallHealthPercent, required this.statusLabel});

  factory CropHealthSummary.fromJson(Map<String, dynamic> j) =>
      CropHealthSummary(
        totalFields: j['totalFields'], healthyCount: j['healthyCount'],
        warningCount: j['warningCount'], criticalCount: j['criticalCount'],
        overallHealthPercent: j['overallHealthPercent'],
        statusLabel: j['statusLabel']);
}

// ── Storage Item ───────────────────────────────────────────────────────────
class RemoteStorageItem {
  final String id;
  final String name;
  final double currentKg;
  final double capacityKg;
  final String unit;
  final String status;   // 'available' | 'low' | 'optimal'
  final int lastUpdatedMinutesAgo;
  const RemoteStorageItem({required this.id, required this.name,
      required this.currentKg, required this.capacityKg, required this.unit,
      required this.status, required this.lastUpdatedMinutesAgo});

  double get percentage => (currentKg / capacityKg).clamp(0.0, 1.0);

  String get lastUpdatedLabel {
    if (lastUpdatedMinutesAgo < 60) return 'آخر تحديث قبل $lastUpdatedMinutesAgo دقيقة';
    final h = lastUpdatedMinutesAgo ~/ 60;
    if (h < 24) return 'آخر تحديث قبل $h ساعة';
    return 'آخر تحديث قبل ${h ~/ 24} يوم';
  }

  factory RemoteStorageItem.fromJson(Map<String, dynamic> j) =>
      RemoteStorageItem(
        id: j['id'], name: j['name'],
        currentKg: (j['currentKg'] as num).toDouble(),
        capacityKg: (j['capacityKg'] as num).toDouble(),
        unit: j['unit'], status: j['status'],
        lastUpdatedMinutesAgo: j['lastUpdatedMinutesAgo']);
}

// ── Full Dashboard ─────────────────────────────────────────────────────────
class DashboardData {
  final CropHealthSummary cropHealth;
  final WeatherData weather;
  final List<RemoteStorageItem> storage;
  final String lastUpdated;
  const DashboardData({required this.cropHealth, required this.weather,
      required this.storage, required this.lastUpdated});

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        cropHealth: CropHealthSummary.fromJson(j['cropHealth']),
        weather: WeatherData.fromJson(j['weather']),
        storage: (j['storage'] as List).map((s) => RemoteStorageItem.fromJson(s)).toList(),
        lastUpdated: j['lastUpdated']);
}
