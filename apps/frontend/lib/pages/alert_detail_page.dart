import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';

/// Generic alert detail page.
/// Accepts a plain map so it works with both real API data and locally-built alerts.
class AlertDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final String time;
  final String field;

  const AlertDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.time,
    required this.field,
  });

  bool get isCritical => type == 'حرجة';
  bool get isFrost => title.contains('صقيع');
  bool get isIrrigation => title.contains('ري');

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Row(children: [
          Expanded(child: GreenButton(
            label: isIrrigation ? 'اتصل بالصيانة' : 'تأكيد التنبيه',
            icon: isIrrigation ? Icons.phone_outlined : Icons.check_rounded,
            onTap: () => Navigator.pop(context),
          )),
          const SizedBox(width: 12),
          Expanded(child: GreenButton(label: 'تجاهل', onTap: () => Navigator.pop(context), outlined: true)),
        ]),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          PageHeader(title: 'تفاصيل التنبيه', subtitle: field),
          const SizedBox(height: 24),
          // Icon
          Container(width: 80, height: 80,
            decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
            child: Icon(
              isFrost ? Icons.ac_unit_rounded : isIrrigation ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              size: 38, color: AppColors.error)),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          StatusBadge(label: '● تنبيه $type', color: AppColors.error, bg: const Color(0xFFFEF2F2)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(time, style: AppTextStyles.caption),
            ])),
          const SizedBox(height: 20),
          CardShell(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('التفاصيل', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 10),
            Text(description, style: AppTextStyles.bodySmall),
          ])),
          if (isFrost) ...[
            const SizedBox(height: 14),
            CardShell(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _tempBox('2°م', 'الحال', AppColors.textPrimary),
              _tempBox('-3°م', 'التوقعات الأدنى', AppColors.error),
            ])),
          ],
          const SizedBox(height: 80),
        ]),
      )),
    ),
  );

  Widget _tempBox(String val, String label, Color color) => Column(children: [
    Text(val, style: AppTextStyles.titleLarge.copyWith(color: color, fontSize: 28)),
    Text(label, style: AppTextStyles.caption),
  ]);
}
