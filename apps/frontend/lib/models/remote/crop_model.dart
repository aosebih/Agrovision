library;

class RemoteCrop {
  final String id;
  final String name;
  final String? variety;
  final String status;
  final String? growthStage;
  final String? plantedDate;
  final String? expectedHarvestDate;
  final double? healthScore;
  final String? notes;
  final String? fieldId;
  final Map<String, dynamic>? field;

  const RemoteCrop({
    required this.id,
    required this.name,
    this.variety,
    required this.status,
    this.growthStage,
    this.plantedDate,
    this.expectedHarvestDate,
    this.healthScore,
    this.notes,
    this.fieldId,
    this.field,
  });

  factory RemoteCrop.fromJson(Map<String, dynamic> j) => RemoteCrop(
        id: j['id'] as String,
        name: j['name'] as String,
        variety: j['variety'] as String?,
        status: j['status'] as String? ?? 'planted',
        growthStage: j['growthStage'] as String?,
        plantedDate: j['plantedDate'] as String?,
        expectedHarvestDate: j['expectedHarvestDate'] as String?,
        healthScore: j['healthScore'] != null
            ? (j['healthScore'] as num).toDouble()
            : null,
        notes: j['notes'] as String?,
        fieldId: j['fieldId'] as String?,
        field: j['field'] as Map<String, dynamic>?,
      );

  /// Status color key
  String get statusKey {
    if (healthScore != null) {
      if (healthScore! >= 80) return 'healthy';
      if (healthScore! >= 55) return 'warning';
      return 'critical';
    }
    switch (status) {
      case 'growing':
      case 'planted':
        return 'healthy';
      case 'ready_to_harvest':
        return 'warning';
      default:
        return 'healthy';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'planted':
        return 'مزروع';
      case 'growing':
        return 'ينمو';
      case 'ready_to_harvest':
        return 'جاهز للحصاد';
      case 'harvested':
        return 'تم الحصاد';
      default:
        return status;
    }
  }

  String get fieldName => field?['name'] as String? ?? '-';
}