import 'package:flutter/material.dart';
import '../services/crop_recommendation/crop_api_service.dart';
import '../services/crop_recommendation/weather_service.dart';
import '../services/crop_recommendation/location_service.dart';
import '../services/crop_recommendation/prediction_input.dart';
import 'crop_recommendation_result.dart';

class CropRecommendationHome extends StatefulWidget {
  const CropRecommendationHome({super.key});
  @override
  State<CropRecommendationHome> createState() => _CropRecommendationHomeState();
}

class _CropRecommendationHomeState extends State<CropRecommendationHome> {
  final _formKey = GlobalKey<FormState>();
  final _locationC = TextEditingController();
  final _nC = TextEditingController();
  final _pC = TextEditingController();
  final _kC = TextEditingController();
  final _phC = TextEditingController();

  bool _loading = false, _fetchingWeather = false;
  double? _temp, _humidity, _rainfall;
  String _locStatus = '';

  @override
  void dispose() {
    _locationC.dispose();
    _nC.dispose();
    _pC.dispose();
    _kC.dispose();
    _phC.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationAndWeather() async {
    if (_locationC.text.isEmpty) return;
    setState(() => _fetchingWeather = true);
    try {
      final (lat, lon, _) = await LocationService.geocode(_locationC.text);
      final (t, h, r) = await WeatherService.getWeather(lat, lon);
      setState(() {
        _temp = t; _humidity = h; _rainfall = r;
        _locStatus = '✓ تم تحديد الموقع';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally { setState(() => _fetchingWeather = false); }
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    if (_temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد الموقع أولاً')));
      return;
    }
    setState(() => _loading = true);
    try {
      final input = PredictionInput(
        nitrogen: double.parse(_nC.text),
        phosphorus: double.parse(_pC.text),
        potassium: double.parse(_kC.text),
        temperature: _temp!,
        humidity: _humidity!,
        ph: double.parse(_phC.text),
        rainfall: _rainfall ?? 150.0,
      );
      final result = await CropApiService.predict(input);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => CropRecommendationResult(
            prediction: result, input: input, location: _locationC.text),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توصية المحاصيل الزراعية'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('الموقع', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _locationC,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'أدخل اسم المدينة أو المنطقة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: _fetchingWeather
                      ? const SizedBox(width: 24, height: 24,
                          child: Padding(padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2)))
                      : const Icon(Icons.location_on, color: Colors.green),
                ),
                validator: (v) => v!.isEmpty ? 'الرجاء إدخال الموقع' : null,
              )),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _fetchingWeather ? null : _fetchLocationAndWeather,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('بحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]),
            if (_locStatus.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 6),
                child: Text(_locStatus,
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                  textAlign: TextAlign.right)),
            if (_temp != null)
              Padding(padding: const EdgeInsets.only(top: 6),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _badge(Icons.thermostat, '${_temp!.toStringAsFixed(1)}°C'),
                  _badge(Icons.water_drop, '$_humidity% رطوبة'),
                  if (_rainfall != null)
                    _badge(Icons.water, '${_rainfall!.toStringAsFixed(1)} مم أمطار'),
                ])),
            const SizedBox(height: 24),
            Text('بيانات التربة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _nC,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: _inp('النيتروجين (N)', 'mg/kg'),
                validator: (v) {
                  final n = double.tryParse(v!);
                  return (n == null || n < 0 || n > 200) ? '0-200' : null;
                },
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _pC,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: _inp('الفوسفور (P)', 'mg/kg'),
                validator: (v) {
                  final n = double.tryParse(v!);
                  return (n == null || n < 0 || n > 200) ? '0-200' : null;
                },
              )),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _kC,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: _inp('البوتاسيوم (K)', 'mg/kg'),
                validator: (v) {
                  final n = double.tryParse(v!);
                  return (n == null || n < 0 || n > 250) ? '0-250' : null;
                },
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _phC,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: _inp('نسبة الحموضة (pH)', null),
                validator: (v) {
                  final n = double.tryParse(v!);
                  return (n == null || n < 0 || n > 14) ? '0-14' : null;
                },
              )),
            ]),
            const SizedBox(height: 32),
            SizedBox(height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _predict,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _loading
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('احصل على التوصية',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      ),
    );
  }

  InputDecoration _inp(String label, String? suffix) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    suffixText: suffix,
    filled: true,
    fillColor: Colors.grey.shade50,
  );

  Widget _badge(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: Colors.orange.shade700),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: Colors.orange.shade800, fontSize: 13)),
    ]),
  );
}
