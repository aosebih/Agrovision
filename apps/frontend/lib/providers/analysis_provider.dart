import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/remote/analysis_result.dart';

enum AnalysisState { idle, uploading, success, error }

class AnalysisProvider extends ChangeNotifier {
  final ApiClient _api;

  AnalysisProvider(this._api);

  AnalysisState _state = AnalysisState.idle;
  AnalysisResult? _result;
  String? _errorMessage;
  List<AnalysisResult> _history = [];
  File? _selectedImage;

  AnalysisState get state => _state;
  AnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;
  List<AnalysisResult> get history => List.unmodifiable(_history);
  File? get selectedImage => _selectedImage;
  bool get isUploading => _state == AnalysisState.uploading;

  void setSelectedImage(File? file) {
    _selectedImage = file;
    // Reset previous result when a new image is chosen
    if (file != null) {
      _state = AnalysisState.idle;
      _result = null;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> analyze({String? cropType, String? fieldId}) async {
    if (_selectedImage == null) return;

    _state = AnalysisState.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = <String, String>{};
      if (cropType != null) fields['cropType'] = cropType;
      if (fieldId != null) fields['fieldId'] = fieldId;

      final res = await _api.postMultipart(
        '/analyze',
        _selectedImage!,
        fields: fields.isEmpty ? null : fields,
      );

      _result = AnalysisResult.fromJson(res['data'] as Map<String, dynamic>);
      _state = AnalysisState.success;
      _errorMessage = null;

      // Prepend to local history list
      _history = [_result!, ..._history].take(20).toList();
    } on ApiException catch (e) {
      _state = AnalysisState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = AnalysisState.error;
      _errorMessage = 'فشل تحليل الصورة. حاول مجدداً.';
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      final res = await _api.get('/analyze/history');
      final list = res['data'] as List;
      _history = list
          .map((e) => AnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // History is non-critical — fail silently
    }
  }

  void reset() {
    _state = AnalysisState.idle;
    _result = null;
    _errorMessage = null;
    _selectedImage = null;
    notifyListeners();
  }
}
