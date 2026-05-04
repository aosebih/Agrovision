library;

class DashboardData {
  final int totalCrops;
  final int totalIrrigationEvents;
  final int unreadAlerts;
  final int lowStockItems;
  final double averageCropHealth;

  const DashboardData({
    required this.totalCrops,
    required this.totalIrrigationEvents,
    required this.unreadAlerts,
    required this.lowStockItems,
    required this.averageCropHealth,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        totalCrops: j['totalCrops'] ?? 0,
        totalIrrigationEvents: j['totalIrrigationEvents'] ?? 0,
        unreadAlerts: j['unreadAlerts'] ?? 0,
        lowStockItems: j['lowStockItems'] ?? 0,
        averageCropHealth: double.tryParse(j['averageCropHealth']?.toString() ?? '0') ?? 0,
      );
}
