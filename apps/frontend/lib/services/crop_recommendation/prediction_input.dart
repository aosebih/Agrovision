class PredictionInput {
  final double nitrogen, phosphorus, potassium, temperature, humidity, ph, rainfall;

  PredictionInput({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
  });

  Map<String, dynamic> toJson() => {
    'Nitrogen': nitrogen,
    'phosphorus': phosphorus,
    'potassium': potassium,
    'temperature': temperature,
    'humidity': humidity,
    'ph': ph,
    'rainfall': rainfall,
  };
}
