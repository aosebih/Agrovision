/// Local analysis result produced by on-device TFLite inference.
library;

class AnalysisResult {
  final String id;
  final String label;        // raw model class key e.g. 'Tomato___Late_blight'

  // Bilingual display name (always set; derived from label at inference time)
  final String displayNameAr;
  final String displayNameFr;

  final String cropKey;      // which model was used e.g. 'tomato'
  final double confidence;
  final Map<String, double> probabilities;
  final bool isHealthy;
  final String severity;     // 'none' | 'low' | 'moderate' | 'severe'

  // Bilingual description & treatment (null when isHealthy == true)
  final String? descriptionAr;
  final String? descriptionFr;
  final String? treatmentAr;
  final String? treatmentFr;

  final String timestamp;

  // Optional field attribution
  final String? fieldId;
  final String? fieldName;

  const AnalysisResult({
    required this.id,
    required this.label,
    required this.displayNameAr,
    required this.displayNameFr,
    required this.cropKey,
    required this.confidence,
    required this.probabilities,
    required this.isHealthy,
    required this.severity,
    this.descriptionAr,
    this.descriptionFr,
    this.treatmentAr,
    this.treatmentFr,
    required this.timestamp,
    this.fieldId,
    this.fieldName,
  });

  // ── Language helpers ──────────────────────────────────────────────────────

  /// Returns the display name in [lang] ('fr' → French, anything else → Arabic).
  String nameForLang(String lang) =>
      lang == 'fr' ? displayNameFr : displayNameAr;

  /// Returns the description in [lang], or null if healthy.
  String? descForLang(String lang) =>
      lang == 'fr' ? descriptionFr : descriptionAr;

  /// Returns the treatment in [lang], or null if healthy.
  String? treatForLang(String lang) =>
      lang == 'fr' ? treatmentFr : treatmentAr;

  // ── Backward-compat getters ───────────────────────────────────────────────

  /// Legacy single-language display name (falls back to Arabic).
  String get displayName => displayNameAr;

  String? get disease => isHealthy ? null : displayNameAr;
  int get confidencePercent => (confidence * 100).toInt();

  // ── copyWith (used for field attribution updates) ─────────────────────────
  AnalysisResult copyWith({
    String? fieldId,
    String? fieldName,
  }) =>
      AnalysisResult(
        id: id,
        label: label,
        displayNameAr: displayNameAr,
        displayNameFr: displayNameFr,
        cropKey: cropKey,
        confidence: confidence,
        probabilities: probabilities,
        isHealthy: isHealthy,
        severity: severity,
        descriptionAr: descriptionAr,
        descriptionFr: descriptionFr,
        treatmentAr: treatmentAr,
        treatmentFr: treatmentFr,
        timestamp: timestamp,
        fieldId: fieldId ?? this.fieldId,
        fieldName: fieldName ?? this.fieldName,
      );

  // ── JSON ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'displayNameAr': displayNameAr,
    'displayNameFr': displayNameFr,
    // legacy key kept so old history entries still display correctly
    'displayName': displayNameAr,
    'cropKey': cropKey,
    'confidence': confidence,
    'probabilities': probabilities,
    'isHealthy': isHealthy,
    'severity': severity,
    'descriptionAr': descriptionAr,
    'descriptionFr': descriptionFr,
    'treatmentAr': treatmentAr,
    'treatmentFr': treatmentFr,
    // legacy keys
    'description': descriptionAr,
    'treatment': treatmentAr,
    'timestamp': timestamp,
    'fieldId': fieldId,
    'fieldName': fieldName,
  };
}
