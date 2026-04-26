/// Remote model for GET /api/v1/dashboard/crops
library;

class RemoteCrop {
  final String id;
  final String name;
  final String field;
  final String variety;
  final double health;
  final String statusLabel;
  final double humidity;
  final double temp;
  final double ndvi;
  final int growthDay;
  final String lastScanned;

  const RemoteCrop({
    required this.id,
    required this.name,
    required this.field,
    required this.variety,
    required this.health,
    required this.statusLabel,
    required this.humidity,
    required this.temp,
    required this.ndvi,
    required this.growthDay,
    required this.lastScanned,
  });

  factory RemoteCrop.fromJson(Map<String, dynamic> j) => RemoteCrop(
        id: j['id'] as String,
        name: j['name'] as String,
        field: j['field'] as String,
        variety: j['variety'] as String,
        health: (j['health'] as num).toDouble(),
        statusLabel: j['statusLabel'] as String,
        humidity: (j['humidity'] as num).toDouble(),
        temp: (j['temp'] as num).toDouble(),
        ndvi: (j['ndvi'] as num).toDouble(),
        growthDay: (j['growthDay'] as num).toInt(),
        lastScanned: j['lastScanned'] as String,
      );

  /// Convenience: status color key based on health score
  String get statusKey {
    if (health >= 0.80) return 'healthy';
    if (health >= 0.55) return 'warning';
    return 'critical';
  }
}
