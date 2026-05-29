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

  double get health => (healthScore ?? 0.0).clamp(0.0, 1.0);

  double get humidity => (field?['humidity'] as num?)?.toDouble() ?? 0.0;

  double get ndvi => (field?['ndvi'] as num?)?.toDouble() ?? 0.0;

  int get growthDay => (field?['growthDay'] as num?)?.toInt() ?? 0;

  double get temp => (field?['temp'] as num?)?.toDouble() ?? 0.0;

  String get fieldName => field?['name'] as String? ?? '-';

  double? get fieldLatitude {
    final v = field?['latitude'];
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  double? get fieldLongitude {
    final v = field?['longitude'];
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  // ── Bilingual crop name map ───────────────────────────────────────────────
  // The Arabic name is always the DB key; French is derived at display time.
  static const List<(String ar, String fr)> cropNamePairs = [
    ('قمح',         'Blé'),
    ('ذرة',         'Maïs'),
    ('فول الصويا',  'Soja'),
    ('أرز',         'Riz'),
    ('شعير',        'Orge'),
    ('طماطم',       'Tomate'),
    ('بطاطس',       'Pomme de terre'),
    ('بصل',         'Oignon'),
    ('ثوم',         'Ail'),
    ('جزر',         'Carotte'),
    ('فلفل',        'Poivron'),
    ('خيار',        'Concombre'),
    ('باذنجان',     'Aubergine'),
    ('كوسة',        'Courgette'),
    ('بطيخ',        'Pastèque'),
    ('عنب',         'Raisin'),
    ('زيتون',       'Olive'),
    ('تمر',         'Datte'),
    ('ليمون',       'Citron'),
    ('برتقال',      'Orange'),
  ];

  /// Returns the localized display name for [key] (always stored as Arabic).
  /// Falls back to the raw key if not found in the map.
  static String localizedName(String key, String lang) {
    if (lang != 'fr') return key;
    for (final (ar, fr) in cropNamePairs) {
      if (ar == key) return fr;
    }
    return key;
  }
}