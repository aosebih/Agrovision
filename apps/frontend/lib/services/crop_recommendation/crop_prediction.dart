class CropPrediction {
  final String cropEn;
  final String cropAr;
  final double confidence;
  final Map<String, double> probabilities;

  CropPrediction({
    required this.cropEn,
    required this.cropAr,
    required this.confidence,
    required this.probabilities,
  });

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    return CropPrediction(
      cropEn: json['crop_en'] as String,
      cropAr: json['crop_ar'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: (json['probabilities'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }
}
