import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

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
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            PageHeader(title: _t(lang, 'تفاصيل التنبيه', 'Détails de l\'alerte'), subtitle: field),
            const SizedBox(height: 24),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: Icon(
                isFrost ? Icons.ac_unit_rounded : isIrrigation ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                size: 38, color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            StatusBadge(label: '● ${_t(lang, 'تنبيه', 'Alerte')} $type', color: AppColors.error, bg: const Color(0xFFFEF2F2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.txtMuted(context)),
                const SizedBox(width: 5),
                Text(time, style: AppTextStyles.caption),
              ]),
            ),
            const SizedBox(height: 20),
            CardShell(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_t(lang, 'التفاصيل', 'Détails'), style: AppTextStyles.headlineMedium),
                const SizedBox(height: 10),
                Text(description, style: AppTextStyles.bodySmall),
              ]),
            ),
            if (isFrost) ...[
              const SizedBox(height: 14),
              CardShell(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _tempBox('2°م', _t(lang, 'الحال', 'Actuel'), AppColors.txt(context)),
                  _tempBox('-3°م', _t(lang, 'التوقعات الأدنى', 'Min prévu'), AppColors.error),
                ]),
              ),
            ],
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }

  Widget _tempBox(String val, String label, Color color) => Column(children: [
    Text(val, style: AppTextStyles.titleLarge.copyWith(color: color, fontSize: 28)),
    Text(label, style: AppTextStyles.caption),
  ]);
}
