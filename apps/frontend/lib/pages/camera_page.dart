import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/analysis_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tflite_service.dart';
import 'disease_diagnosis_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _picker = ImagePicker();
  String _lang = 'ar';

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: Consumer<AnalysisProvider>(
          builder: (context, provider, _) {
            // Navigate to result page once analysis succeeds
            if (provider.state == AnalysisState.success && provider.result != null) {
              final result = provider.result!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                provider.reset();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseaseDiagnosisPage(result: result, lang: _lang),
                  ),
                );
              });
            }

            return SafeArea(
              child: Column(children: [
                _header(context, provider),
                Expanded(child: _body(context, provider)),
              ]),
            );
          },
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, AnalysisProvider provider) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          GestureDetector(
            onTap: () { provider.reset(); Navigator.pop(context); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.surf(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bord(context)),
              ),
              child: Icon(Icons.close_rounded, size: 18, color: AppColors.txtSec(context)),
            ),
          ),
          const Spacer(),
          Text(
            _t(_lang, 'تشخيص المحاصيل', 'Diagnostic des cultures'),
            style: AppTextStyles.titleLarge,
          ),
        ]),
      );

  // ── Body dispatcher ──────────────────────────────────────────────────────────
  Widget _body(BuildContext context, AnalysisProvider provider) {
    if (provider.isUploading) return _loadingView(provider);
    if (provider.state == AnalysisState.error) return _errorView(context, provider);
    if (provider.selectedImage != null) return _previewView(context, provider);
    return _selectView(context, provider);
  }

  // ── 1. Select image + crop picker ────────────────────────────────────────────
  Widget _selectView(BuildContext context, AnalysisProvider provider) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Illustration banner
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primLight(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(_lang, 'التقط أو اختر صورة للمحصول', 'Prenez ou choisissez une photo'),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _t(_lang, 'لتشخيص الأمراض والآفات', 'Pour diagnostiquer les maladies'),
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // Model selector
          _modelSelector(context, provider),

          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            Expanded(
              child: _sourceButton(
                icon: Icons.camera_alt_rounded,
                label: _t(_lang, 'الكاميرا', 'Caméra'),
                color: AppColors.primary,
                bg: AppColors.primaryLight,
                onTap: () => _pickImage(context, provider, ImageSource.camera),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _sourceButton(
                icon: Icons.photo_library_rounded,
                label: _t(_lang, 'المعرض', 'Galerie'),
                color: AppColors.info,
                bg: AppColors.blueLight,
                onTap: () => _pickImage(context, provider, ImageSource.gallery),
              ),
            ),
          ]),

          const SizedBox(height: 12),

          // Last scan hint
          if (provider.history.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfAlt(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.history_rounded, size: 16, color: AppColors.txtMuted(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t(_lang,
                      'آخر تحليل: ${_latestLabel(provider)}',
                      'Dernier: ${_latestLabel(provider)}'),
                    style: AppTextStyles.caption,
                  ),
                ),
              ]),
            ),

          const SizedBox(height: 16),
        ]),
      );

  // ── 2. Preview & confirm ─────────────────────────────────────────────────────
  Widget _previewView(BuildContext context, AnalysisProvider provider) =>
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  provider.selectedImage!,
                  width: double.infinity, height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: GestureDetector(
                  onTap: () => provider.setSelectedImage(null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
              // Show selected model badge
              Positioned(
                bottom: 12, right: 12,
                child: StatusBadge(
                  label: _lang == 'fr'
                      ? _selectedModelConfig(provider).cropNameFr
                      : _selectedModelConfig(provider).cropNameAr,
                  color: AppColors.primaryDark,
                  bg: Colors.white,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Text(
            _t(_lang, 'هل تريد تحليل هذه الصورة؟', 'Analyser cette image ?'),
            style: AppTextStyles.headlineMedium, textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _t(_lang, 'سيتم تحليلها بنموذج الذكاء الاصطناعي للمحصول المختار',
               'Analysée par l\'IA dédiée à la culture sélectionnée'),
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GreenButton(
            label: _t(_lang, 'بدء التحليل', "Lancer l'analyse"),
            icon: Icons.science_rounded,
            onTap: () => provider.analyze(lang: _lang),
          ),
          const SizedBox(height: 10),
          GreenButton(
            label: _t(_lang, 'اختيار صورة أخرى', 'Choisir une autre image'),
            onTap: () => provider.setSelectedImage(null),
            outlined: true,
          ),
        ]),
      );

  // ── 3. Loading ───────────────────────────────────────────────────────────────
  Widget _loadingView(AnalysisProvider provider) {
    final isLoadingModel = provider.state == AnalysisState.loadingModel;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
          width: 70, height: 70,
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 5),
        ),
        const SizedBox(height: 24),
        Text(
          isLoadingModel
              ? _t(_lang, 'جارٍ تحميل النموذج...', 'Chargement du modèle...')
              : _t(_lang, 'جارٍ التحليل...', 'Analyse en cours...'),
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          isLoadingModel
              ? _t(_lang, 'يتم تحميل نموذج الذكاء الاصطناعي للمحصول المختار',
                          'Chargement du modèle IA pour la culture sélectionnée')
              : _t(_lang, 'يتم تحليل الصورة للكشف عن الأمراض',
                          'Analyse de l\'image pour détecter les maladies'),
          style: AppTextStyles.bodySmall, textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  // ── 4. Error ─────────────────────────────────────────────────────────────────
  Widget _errorView(BuildContext context, AnalysisProvider provider) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 70, height: 70,
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 38),
            ),
            const SizedBox(height: 20),
            Text(_t(_lang, 'فشل التحليل', 'Analyse échouée'), style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? _t(_lang, 'حدث خطأ غير متوقع', 'Erreur inattendue'),
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GreenButton(
              label: _t(_lang, 'إعادة المحاولة', 'Réessayer'),
              icon: Icons.refresh_rounded,
              onTap: () => provider.analyze(lang: _lang),
            ),
            const SizedBox(height: 10),
            GreenButton(
              label: _t(_lang, 'اختيار صورة أخرى', 'Choisir une autre image'),
              onTap: () => provider.reset(),
              outlined: true,
            ),
          ]),
        ),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────────
  CropModelConfig _selectedModelConfig(AnalysisProvider provider) =>
      TfliteService.availableModels.firstWhere(
        (m) => m.cropKey == provider.selectedCropKey,
        orElse: () => TfliteService.availableModels.first,
      );

  String _latestLabel(AnalysisProvider p) {
    final r = p.history.first;
    return r.isHealthy
        ? _t(_lang, 'سليم (${r.confidencePercent}%)', 'Sain (${r.confidencePercent}%)')
        : '${r.displayName} (${r.confidencePercent}%)';
  }

  // ── Model selector ────────────────────────────────────────────────────────────
  Widget _modelSelector(BuildContext context, AnalysisProvider provider) {
    // Exclude the tabular crop_recommendation model — it uses a different flow
    final models = TfliteService.availableModels
        .where((m) => m.cropKey != 'crop_recommendation')
        .toList();

    final selected = models.firstWhere(
      (m) => m.cropKey == provider.selectedCropKey,
      orElse: () => models.first,
    );

    return GestureDetector(
      onTap: () => _showModelPicker(context, provider, models),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bord(context)),
        ),
        child: Row(children: [
          // Chevron (acts as dropdown cue on the left in RTL)
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: AppColors.txtSec(context)),
          const Spacer(),
          // Label + crop name
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              _t(_lang, 'نموذج التشخيص', 'Modèle de diagnostic'),
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context)),
            ),
            const SizedBox(height: 2),
            Text(
              _lang == 'fr' ? selected.cropNameFr : selected.cropNameAr,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.txt(context), fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(width: 10),
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.biotech_rounded,
                color: AppColors.primary, size: 20),
          ),
        ]),
      ),
    );
  }

  void _showModelPicker(BuildContext context, AnalysisProvider provider,
      List<CropModelConfig> models) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection:
            _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
        child: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bord(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _t(_lang, 'اختر نموذج المحصول', 'Choisir le modèle de culture'),
                style: AppTextStyles.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _t(_lang,
                    'اختر المحصول المناسب للحصول على تشخيص دقيق',
                    'Sélectionnez la culture pour un diagnostic précis'),
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: models.length,
                itemBuilder: (_, i) {
                  final m = models[i];
                  final isSelected = m.cropKey == provider.selectedCropKey;
                  return InkWell(
                    onTap: () {
                      provider.selectCrop(m.cropKey);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(children: [
                        // Checkmark
                        SizedBox(
                          width: 24,
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  size: 20, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        // Name
                        Expanded(
                          child: Text(
                            _lang == 'fr' ? m.cropNameFr : m.cropNameAr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.txt(context),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        // Small badge with disease count
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.surfAlt(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${m.classes.length - 1} ${_t(_lang, 'مرض', 'maladies')}',
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.txtMuted(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ]),
        ),
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Future<void> _pickImage(BuildContext context, AnalysisProvider provider, ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1280, maxHeight: 1280);
      if (xfile == null) return;
      provider.setSelectedImage(File(xfile.path));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_t(_lang,
          'تعذر الوصول إلى ${source == ImageSource.camera ? "الكاميرا" : "المعرض"}',
          'Impossible d\'accéder à ${source == ImageSource.camera ? "la caméra" : "la galerie"}')),
        backgroundColor: AppColors.error,
      ));
    }
  }
}