library;

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

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final storageRaw = j['storage'] ?? j['items'] ?? [];
    final storageList = storageRaw is List
        ? storageRaw
            .map((e) => RemoteStorageItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <RemoteStorageItem>[];
    return DashboardData(
      totalCrops: j['totalCrops'] ?? 0,
      totalIrrigationEvents: j['totalIrrigationEvents'] ?? 0,
      unreadAlerts: j['unreadAlerts'] ?? 0,
      lowStockItems: j['lowStockItems'] ?? 0,
      averageCropHealth:
          double.tryParse(j['averageCropHealth']?.toString() ?? '0') ?? 0,
      storage: storageList,
    );
  }
}

// ── RemoteStorageItem: used by FertilizerDetailPage and InventoryDetailPage ──
class RemoteStorageItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentKg;
  final double capacityKg;
  final String status; // 'available' | 'low' | 'medium'
  final double? minStockLevel;
  final String lastUpdatedLabel;

  const RemoteStorageItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentKg,
    required this.capacityKg,
    required this.status,
    this.minStockLevel,
    required this.lastUpdatedLabel,
  });

  double get percentage => capacityKg > 0
      ? (currentKg / capacityKg).clamp(0.0, 1.0).toDouble()
      : 0.0;

  factory RemoteStorageItem.fromJson(Map<String, dynamic> j) {
    final qty = _d(j['quantity']);
    final minStock = _dNull(j['minStockLevel']);
    final capacity =
        minStock != null ? minStock * 3 : (qty > 0 ? qty * 2 : 100.0);
    String status;
    if (minStock == null || qty > minStock * 1.5) {
      status = 'available';
    } else if (qty <= minStock) {
      status = 'low';
    } else {
      status = 'medium';
    }
    return RemoteStorageItem(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      category: j['category'] as String? ?? 'other',
      unit: j['unit'] as String? ?? 'كغ',
      currentKg: qty,
      capacityKg: capacity,
      status: status,
      minStockLevel: minStock,
      lastUpdatedLabel: (j['updatedAt'] as String?)?.split('T').first ?? '',
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static double? _dNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
