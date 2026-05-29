import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/remote/analysis_result.dart';
import '../services/tflite_service.dart';

enum AnalysisState { idle, loadingModel, uploading, success, error }

class AnalysisProvider extends ChangeNotifier {
  final TfliteService _tflite = TfliteService();

  AnalysisState _state = AnalysisState.idle;
  AnalysisResult? _result;
  String? _errorMessage;
  List<AnalysisResult> _history = [];
  File? _selectedImage;
  String _selectedCropKey = 'bean';

  static const _historyKey = 'disease_history_v1';
  static const _maxHistory = 50;

  AnalysisState get state => _state;
  AnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;
  List<AnalysisResult> get history => List.unmodifiable(_history);
  File? get selectedImage => _selectedImage;
  String get selectedCropKey => _selectedCropKey;
  bool get isUploading =>
      _state == AnalysisState.uploading ||
      _state == AnalysisState.loadingModel;

  List<CropModelConfig> get availableModels => TfliteService.availableModels;

  // ── Feature 3: Persist history across sessions ─────────────────────────────

  Future<void> init() async {
    await _loadHistory();         // load persisted history first
    try {
      await _tflite.loadModel(_selectedCropKey);
    } catch (e) {
      debugPrint('Model pre-load failed: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        _history = list
            .map((e) => _resultFromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_history.map((r) => r.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  static AnalysisResult _resultFromJson(Map<String, dynamic> j) {
    // Back-compat: old entries stored only one language under 'displayName'.
    final legacyName = j['displayName'] as String? ?? j['label'] as String;
    final legacyDesc = j['description'] as String?;
    final legacyTreat = j['treatment'] as String?;
    return AnalysisResult(
      id: j['id'] as String,
      label: j['label'] as String,
      displayNameAr: j['displayNameAr'] as String? ?? legacyName,
      displayNameFr: j['displayNameFr'] as String? ?? legacyName,
      cropKey: j['cropKey'] as String,
      confidence: (j['confidence'] as num).toDouble(),
      probabilities: Map<String, double>.from(
          (j['probabilities'] as Map).map((k, v) =>
              MapEntry(k as String, (v as num).toDouble()))),
      isHealthy: j['isHealthy'] as bool,
      severity: j['severity'] as String,
      descriptionAr: j['descriptionAr'] as String? ?? legacyDesc,
      descriptionFr: j['descriptionFr'] as String? ?? legacyDesc,
      treatmentAr: j['treatmentAr'] as String? ?? legacyTreat,
      treatmentFr: j['treatmentFr'] as String? ?? legacyTreat,
      timestamp: j['timestamp'] as String,
      fieldId: j['fieldId'] as String?,
      fieldName: j['fieldName'] as String?,
    );
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Crop selection ─────────────────────────────────────────────────────────

  Future<void> selectCrop(String cropKey) async {
    if (cropKey == _selectedCropKey) return;
    _selectedCropKey = cropKey;
    _result = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await _tflite.loadModel(cropKey);
    } catch (e) {
      debugPrint('Pre-load failed for $cropKey: $e');
    }
  }

  void setSelectedImage(File? file) {
    _selectedImage = file;
    if (file != null) {
      _state = AnalysisState.idle;
      _result = null;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    await _loadHistory();
  }

  // ── Inference ──────────────────────────────────────────────────────────────

  Future<void> analyze({String? lang}) async {
    if (_selectedImage == null) return;

    final effectiveLang = lang ?? 'ar';

    if (_tflite.loadedCropKey != _selectedCropKey) {
      _state = AnalysisState.loadingModel;
      _errorMessage = null;
      notifyListeners();
      try {
        await _tflite.loadModel(_selectedCropKey);
      } catch (e) {
        _state = AnalysisState.error;
        final cropLabel =
            _selectedCropKey[0].toUpperCase() + _selectedCropKey.substring(1);
        _errorMessage = effectiveLang == 'fr'
            ? 'Impossible de charger le modèle "$cropLabel". Vérifiez que le fichier .tflite est bien inclus dans les assets.'
            : 'تعذّر تحميل نموذج "$cropLabel". تأكد من وجود ملف .tflite في أصول التطبيق.';
        notifyListeners();
        return;
      }
    }

    _state = AnalysisState.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      final prediction = await _tflite.predict(_selectedImage!, effectiveLang);

      final label = prediction['label'] as String;
      final displayName = prediction['displayName'] as String;
      final confidence = prediction['confidence'] as double;
      final probabilities = Map<String, double>.from(
          prediction['probabilities'] as Map);
      final isHealthy = prediction['isHealthy'] as bool;
      final severity = prediction['severity'] as String;
      final description = prediction['description'] as String?;
      final treatment = prediction['treatment'] as String?;

      _result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: label,
        displayNameAr: prediction['displayNameAr'] as String? ?? displayName,
        displayNameFr: prediction['displayNameFr'] as String? ?? displayName,
        cropKey: _selectedCropKey,
        confidence: confidence,
        probabilities: probabilities,
        isHealthy: isHealthy,
        severity: severity,
        descriptionAr: isHealthy ? null : prediction['descriptionAr'] as String?,
        descriptionFr: isHealthy ? null : prediction['descriptionFr'] as String?,
        treatmentAr: isHealthy ? null : prediction['treatmentAr'] as String?,
        treatmentFr: isHealthy ? null : prediction['treatmentFr'] as String?,
        timestamp: DateTime.now().toIso8601String(),
      );

      _state = AnalysisState.success;
      _errorMessage = null;

      // Feature 3: persist to local storage
      _history = [_result!, ..._history].take(_maxHistory).toList();
      await _saveHistory();
    } catch (e) {
      _state = AnalysisState.error;
      final isModelErr = e.toString().contains('Model not loaded') ||
          e.toString().contains('No model loaded');
      if (isModelErr) {
        final cropLabel =
            _selectedCropKey[0].toUpperCase() + _selectedCropKey.substring(1);
        _errorMessage = effectiveLang == 'fr'
            ? 'Modèle "$cropLabel" non disponible. Vérifiez les assets du projet.'
            : 'نموذج "$cropLabel" غير متوفر. تحقق من أصول المشروع.';
      } else {
        _errorMessage = effectiveLang == 'fr'
            ? 'Échec de l\'analyse. Réessayez avec une autre image.'
            : 'فشل تحليل الصورة. حاول مجدداً بصورة أخرى.';
      }
      debugPrint('Inference error: $e');
    }

    notifyListeners();
  }

  // ── Field attribution ─────────────────────────────────────────────────────

  /// Update the stored field attribution for an existing result.
  Future<void> updateFieldAttribution(
      String resultId, String? fieldId, String? fieldName) async {
    _history = _history.map((r) {
      if (r.id != resultId) return r;
      return r.copyWith(fieldId: fieldId, fieldName: fieldName);
    }).toList();
    await _saveHistory();
    notifyListeners();
  }

  void reset() {
    _state = AnalysisState.idle;
    _result = null;
    _errorMessage = null;
    _selectedImage = null;
    notifyListeners();
  }
}
