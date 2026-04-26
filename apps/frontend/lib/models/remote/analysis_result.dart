/// Remote model for POST /analyze response.
library;

enum PredictionLabel { healthy, diseased, uncertain }

class AnalysisResult {
  final String id;
  final String status;
  final PredictionLabel prediction;
  final double confidence;
  final String? disease;
  final String? description;
  final String? treatment;
  final String? severity;
  final String timestamp;
  final String? cropType;
  final String? fieldId;

  const AnalysisResult({
    required this.id,
    required this.status,
    required this.prediction,
    required this.confidence,
    this.disease,
    this.description,
    this.treatment,
    this.severity,
    required this.timestamp,
    this.cropType,
    this.fieldId,
  });

  bool get isHealthy => prediction == PredictionLabel.healthy;

  factory AnalysisResult.fromJson(Map<String, dynamic> j) {
    final predRaw = j['prediction'] as String;
    final pred = PredictionLabel.values.firstWhere(
      (e) => e.name == predRaw,
      orElse: () => PredictionLabel.uncertain,
    );
    return AnalysisResult(
      id: j['id'],
      status: j['status'],
      prediction: pred,
      confidence: (j['confidence'] as num).toDouble(),
      disease: j['disease'],
      description: j['description'],
      treatment: j['treatment'],
      severity: j['severity'],
      timestamp: j['timestamp'],
      cropType: j['cropType'],
      fieldId: j['fieldId'],
    );
  }
}
