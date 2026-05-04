import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/analysis_provider.dart';
import 'disease_diagnosis_page.dart';

/// Full-screen camera/upload flow.
/// This page is pushed directly from the FAB or main_scaffold camera tap.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _picker = ImagePicker();
  String? _cropType;
  final _crops = const ['قمح', 'ذرة', 'فول الصويا', 'أرز', 'شعير', 'أخرى'];

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, _) {
          // If analysis succeeded → go directly to result
          if (provider.state == AnalysisState.success && provider.result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DiseaseDiagnosisPage(result: provider.result!)),
              );
              provider.reset();
            });
          }

          return SafeArea(child: Column(children: [
            _header(context, provider),
            Expanded(child: _body(context, provider)),
          ]));
        },
      ),
    ),
  );

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, AnalysisProvider provider) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(children: [
      GestureDetector(
        onTap: () { provider.reset(); Navigator.pop(context); },
        child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary)),
      ),
      const Spacer(),
      Text('تشخيص المحاصيل', style: AppTextStyles.titleLarge),
    ]),
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  Widget _body(BuildContext context, AnalysisProvider provider) {
    if (provider.isUploading) return _loadingView();
    if (provider.state == AnalysisState.error) return _errorView(context, provider);
    if (provider.selectedImage != null) return _previewView(context, provider);
    return _selectView(context, provider);
  }

  // ── 1. Select image ──────────────────────────────────────────────────────────
  Widget _selectView(BuildContext context, AnalysisProvider provider) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      // Illustration
      Container(
        height: 200,
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 70, height: 70, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36)),
          const SizedBox(height: 16),
          Text('التقط أو اختر صورة للمحصول', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text('لتشخيص الأمراض والآفات', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
        ])),
      ),
      const SizedBox(height: 28),
      // Crop type picker
      Text('نوع المحصول (اختياري)', style: AppTextStyles.headlineMedium),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: _cropType,
          hint: Row(children: [const SizedBox(width: 14), const Icon(Icons.eco_outlined, size: 18, color: AppColors.textMuted), const SizedBox(width: 10), Text('اختر نوع المحصول', style: AppTextStyles.bodySmall)]),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          borderRadius: BorderRadius.circular(14),
          items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTextStyles.bodyMedium))).toList(),
          onChanged: (v) => setState(() => _cropType = v),
        )),
      ),
      const Spacer(),
      // Action buttons
      Row(children: [
        Expanded(child: _sourceButton(
          icon: Icons.camera_alt_rounded,
          label: 'الكاميرا',
          color: AppColors.primary,
          bg: AppColors.primaryLight,
          onTap: () => _pickImage(context, provider, ImageSource.camera),
        )),
        const SizedBox(width: 14),
        Expanded(child: _sourceButton(
          icon: Icons.photo_library_rounded,
          label: 'المعرض',
          color: AppColors.info,
          bg: AppColors.blueLight,
          onTap: () => _pickImage(context, provider, ImageSource.gallery),
        )),
      ]),
      const SizedBox(height: 12),
      // Recent scan hint
      if (provider.history.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.history_rounded, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(child: Text('آخر تحليل: ${_latestLabel(provider)}', style: AppTextStyles.caption)),
          ]),
        ),
    ]),
  );

  String _latestLabel(AnalysisProvider p) {
    final r = p.history.first;
    return r.isHealthy ? 'سليم (${(r.confidence * 100).toInt()}%)' : '${r.disease ?? "مرض"} (${(r.confidence * 100).toInt()}%)';
  }

  Widget _sourceButton({required IconData icon, required String label, required Color color, required Color bg, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.25))),
        child: Column(children: [
          Icon(icon, size: 34, color: color),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );

  // ── 2. Preview & confirm ─────────────────────────────────────────────────────
  Widget _previewView(BuildContext context, AnalysisProvider provider) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      // Image preview
      Expanded(
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(provider.selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),
          // Re-select button
          Positioned(top: 12, left: 12, child: GestureDetector(
            onTap: () => provider.setSelectedImage(null),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18)),
          )),
          if (_cropType != null)
            Positioned(bottom: 12, right: 12, child: StatusBadge(label: _cropType!, color: AppColors.primaryDark, bg: Colors.white)),
        ]),
      ),
      const SizedBox(height: 20),
      Text('هل تريد تحليل هذه الصورة؟', style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text('سيتم إرسالها إلى نظام الذكاء الاصطناعي للكشف عن الأمراض', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GreenButton(
        label: 'بدء التحليل',
        icon: Icons.science_rounded,
        onTap: () => provider.analyze(cropType: _cropType),
      ),
      const SizedBox(height: 10),
      GreenButton(label: 'اختيار صورة أخرى', onTap: () => provider.setSelectedImage(null), outlined: true),
    ]),
  );

  // ── 3. Loading ───────────────────────────────────────────────────────────────
  Widget _loadingView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(
        width: 70, height: 70,
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 5),
      ),
      const SizedBox(height: 24),
      Text('جارٍ التحليل...', style: AppTextStyles.headlineMedium),
      const SizedBox(height: 8),
      Text('يتم إرسال الصورة إلى نظام الكشف عن الأمراض', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
    ]),
  );

  // ── 4. Error ─────────────────────────────────────────────────────────────────
  Widget _errorView(BuildContext context, AnalysisProvider provider) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 70, height: 70, decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
        child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 38)),
      const SizedBox(height: 20),
      Text('فشل التحليل', style: AppTextStyles.titleLarge),
      const SizedBox(height: 8),
      Text(provider.errorMessage ?? 'حدث خطأ غير متوقع', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      GreenButton(label: 'إعادة المحاولة', icon: Icons.refresh_rounded, onTap: () => provider.analyze(cropType: _cropType)),
      const SizedBox(height: 10),
      GreenButton(label: 'اختيار صورة أخرى', onTap: () => provider.reset(), outlined: true),
    ])),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Future<void> _pickImage(BuildContext context, AnalysisProvider provider, ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        imageQuality: 80,   // compress before sending
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (xfile == null) return;
      provider.setSelectedImage(File(xfile.path));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تعذر الوصول إلى ${source == ImageSource.camera ? "الكاميرا" : "المعرض"}'),
        backgroundColor: AppColors.error,
      ));
    }
  }
}
