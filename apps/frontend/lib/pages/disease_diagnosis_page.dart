import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/analysis_result.dart';

/// Displays the structured result returned by POST /analyze.
/// Receives an [AnalysisResult] parsed from the real API response.
class DiseaseDiagnosisPage extends StatelessWidget {
  final AnalysisResult result;
  const DiseaseDiagnosisPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(children: [
              Expanded(
                  child: GreenButton(
                label: result.isHealthy ? 'حفظ التقرير' : '✓ تطابق المعالجة',
                icon: result.isHealthy
                    ? Icons.save_outlined
                    : Icons.check_rounded,
                onTap: () => Navigator.pop(context),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: GreenButton(
                label: 'تحليل جديد',
                onTap: () => Navigator.pop(context),
                outlined: true,
              )),
            ]),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              // Header
              Row(children: [
                GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.share_outlined,
                        size: 22, color: AppColors.textSecondary)),
                const Spacer(),
                Text('نتيجة التشخيص', style: AppTextStyles.titleLarge),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 15, color: AppColors.textSecondary)),
                ),
              ]),
              const SizedBox(height: 20),

              // Result hero card
              _heroCard(),
              const SizedBox(height: 16),

              // Confidence + metadata
              _metaCard(),
              const SizedBox(height: 14),

              // Description
              if (result.description != null) ...[
                _descCard(),
                const SizedBox(height: 14),
              ],

              // Treatment (only for diseased)
              if (!result.isHealthy && result.treatment != null) ...[
                _treatmentCard(),
                const SizedBox(height: 14),
              ],

              // Healthy success state
              if (result.isHealthy) _healthyCard(),

              const SizedBox(height: 80),
            ]),
          )),
        ),
      );

  Widget _heroCard() {
    final isHealthy = result.isHealthy;
    final color = isHealthy ? AppColors.primary : AppColors.error;
    final bg = isHealthy ? AppColors.primaryLight : const Color(0xFFFEF2F2);
    final icon = isHealthy ? Icons.eco_rounded : Icons.bug_report_outlined;
    final label = isHealthy ? 'النبات سليم' : (result.disease ?? 'مرض مكتشف');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: color)),
        const SizedBox(height: 14),
        Text(label,
            style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        if (!isHealthy && result.severity != null)
          StatusBadge(
            label: 'شدة: ${_severityLabel(result.severity!)}',
            color: _severityColor(result.severity!),
            bg: _severityBg(result.severity!),
          ),
        if (isHealthy)
          const StatusBadge(
              label: '✓ لم يتم اكتشاف أمراض',
              color: AppColors.primaryDark,
              bg: AppColors.primaryLight),
      ]),
    );
  }

  Widget _metaCard() => CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('تفاصيل التحليل', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 14),
        _metaRow('الثقة', '${(result.confidence * 100).toStringAsFixed(1)}%'),
        const Divider(height: 20),
        _metaRow('نوع المحصول', result.cropType ?? 'غير محدد'),
        const Divider(height: 20),
        _metaRow('معرف التحليل', result.id.substring(0, 8).toUpperCase()),
        const Divider(height: 20),
        _metaRow('التوقيت', _formatTimestamp(result.timestamp)),
        // Confidence bar
        const SizedBox(height: 14),
        Text('مستوى الثقة', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.confidence,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                  result.isHealthy ? AppColors.primary : AppColors.error),
              minHeight: 8,
            )),
      ]));

  Widget _metaRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      ]);

  Widget _descCard() => CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          const Icon(Icons.description_outlined,
              size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('الوصف', style: AppTextStyles.headlineMedium),
        ]),
        const SizedBox(height: 10),
        Text(result.description!, style: AppTextStyles.bodySmall),
      ]));

  Widget _treatmentCard() => CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          const Icon(Icons.medical_services_outlined,
              size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('المعالجة الموصى بها', style: AppTextStyles.headlineMedium),
        ]),
        const SizedBox(height: 12),
        Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child:
                      Text(result.treatment!, style: AppTextStyles.bodySmall)),
              const SizedBox(width: 12),
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.local_pharmacy_outlined,
                      size: 18, color: AppColors.primaryDark)),
            ])),
        if (result.severity != null) ...[
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.orange),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('⚠ يطلب إجراء فوري لمنع الانتشار',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600))),
              ])),
        ],
      ]));

  Widget _healthyCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('النبات في حالة صحية ممتازة',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('استمر في برنامج العناية الحالي. راجع كل أسبوع.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primaryDark)),
          ])),
        ]),
      );

  String _severityLabel(String s) => s == 'high'
      ? 'عالية'
      : s == 'medium'
          ? 'متوسطة'
          : 'منخفضة';
  Color _severityColor(String s) => s == 'high'
      ? AppColors.error
      : s == 'medium'
          ? AppColors.orange
          : AppColors.warning;
  Color _severityBg(String s) => s == 'high'
      ? const Color(0xFFFEF2F2)
      : s == 'medium'
          ? AppColors.orangeLight
          : const Color(0xFFFFFBEB);

  String _formatTimestamp(String ts) {
    final dt = DateTime.tryParse(ts);
    if (dt == null) return ts;
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
