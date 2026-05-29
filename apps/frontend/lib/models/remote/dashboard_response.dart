library;

class RemoteStorageItem {
  final String id;
  final String name;
  final String type;
  final double currentKg;
  final double capacityKg;
  final String unit;
  final String status;
  final String lastUpdated;

  const RemoteStorageItem({
    required this.id,
    required this.name,
    required this.type,
    required this.currentKg,
    required this.capacityKg,
    required this.unit,
    required this.status,
    required this.lastUpdated,
  });

  factory RemoteStorageItem.fromJson(Map<String, dynamic> j) =>
      RemoteStorageItem(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        type: j['type'] as String? ?? '',
        currentKg: (j['currentKg'] as num?)?.toDouble() ??
            (j['current'] as num?)?.toDouble() ??
            0,
        capacityKg: (j['capacityKg'] as num?)?.toDouble() ??
            (j['capacity'] as num?)?.toDouble() ??
            0,
        unit: j['unit'] as String? ?? 'كجم',
        status: j['status'] as String? ?? 'available',
        lastUpdated: j['lastUpdated'] as String? ?? '',
      );

  double get percentage =>
      capacityKg > 0 ? (currentKg / capacityKg).clamp(0.0, 1.0) : 0.0;

  String get lastUpdatedLabel =>
      lastUpdated.isEmpty ? 'منذ فترة' : 'آخر تحديث: $lastUpdated';
}

class DashboardData {
  final int totalCrops;
  final int totalIrrigationEvents;
  final int unreadAlerts;
  final int lowStockItems;
  final double averageCropHealth;
  final List<RemoteStorageItem> storage;

  const DashboardData({
    required this.totalCrops,
    required this.totalIrrigationEvents,
    required this.unreadAlerts,
    required this.lowStockItems,
    required this.averageCropHealth,
    this.storage = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        totalCrops: j['totalCrops'] ?? 0,
        totalIrrigationEvents: j['totalIrrigationEvents'] ?? 0,
        unreadAlerts: j['unreadAlerts'] ?? 0,
        lowStockItems: j['lowStockItems'] ?? 0,
        averageCropHealth:
            double.tryParse(j['averageCropHealth']?.toString() ?? '0') ?? 0,
        storage: (j['storage'] as List?)
                ?.map(
                    (e) => RemoteStorageItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
