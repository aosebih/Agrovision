import 'package:flutter/material.dart';
import '../services/crop_recommendation/crop_prediction.dart';
import '../services/crop_recommendation/prediction_input.dart';
import '../services/crop_recommendation/crop_arabic.dart';

class CropRecommendationResult extends StatelessWidget {
  final CropPrediction prediction;
  final PredictionInput input;
  final String location;

  const CropRecommendationResult({
    super.key,
    required this.prediction,
    required this.input,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final top3 = prediction.probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final medals = const ['🥇', '🥈', '🥉'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة التوصية'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          Icon(CropArabic.icon(prediction.cropEn),
               size: 80, color: CropArabic.color(prediction.cropEn)),
          const SizedBox(height: 12),
          Text(prediction.cropAr, style: const TextStyle(
            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Text(prediction.cropEn, style: TextStyle(
            fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              Text('نسبة الثقة: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Colors.green)),
            ])),
          const SizedBox(height: 32),
          _secTitle('المدخلات'),
          const SizedBox(height: 8),
          _card([
            _row('الموقع', location),
            _row('النيتروجين (N)', '${input.nitrogen.toStringAsFixed(0)} mg/kg'),
            _row('الفوسفور (P)', '${input.phosphorus.toStringAsFixed(0)} mg/kg'),
            _row('البوتاسيوم (K)', '${input.potassium.toStringAsFixed(0)} mg/kg'),
            _row('الحرارة', '${input.temperature.toStringAsFixed(1)}°C'),
            _row('الرطوبة', '${input.humidity.toStringAsFixed(0)}%'),
            _row('pH التربة', input.ph.toStringAsFixed(1)),
            _row('الأمطار', '${input.rainfall.toStringAsFixed(0)} مم'),
          ]),
          const SizedBox(height: 24),
          _secTitle('أفضل المحاصيل المقترحة'),
          const SizedBox(height: 8),
          ...top3.take(3).toList().asMap().entries.map((e) {
            final i = e.key;
            final entry = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: i == 0 ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: i == 0 ? Colors.green.shade300 : Colors.grey.shade200,
                  width: i == 0 ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Text(medals[i], style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Icon(CropArabic.icon(entry.key),
                     size: 28, color: CropArabic.color(entry.key)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(CropArabic.name(entry.key), style: TextStyle(
                        fontSize: 18,
                        fontWeight: i == 0 ? FontWeight.bold : FontWeight.w500,
                        color: i == 0 ? Colors.green.shade800 : Colors.black87)),
                      const SizedBox(width: 6),
                      Text(entry.key, style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                    Text('${(entry.value * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ])),
                if (i == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('مُوصى به',
                      style: TextStyle(color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.bold))),
              ]));
          }),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.replay),
              label: const Text('تقييم محصول آخر', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))))),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _secTitle(String t) => Align(alignment: Alignment.centerRight,
    child: Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
      color: Colors.grey.shade800)));

  Widget _card(List<Widget> c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(children: c));

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const Spacer(),
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
    ]));
}
