import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/dashboard_response.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class FertilizerDetailPage extends StatelessWidget {
  final RemoteStorageItem item;
  const FertilizerDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(title: _t(lang, 'تفاصيل السماد', 'Détails de l\'engrais')),
            const SizedBox(height: 20),
            CardShell(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.primLight(context), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.eco_rounded, size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(item.name, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
                Text(item.lastUpdatedLabel, style: AppTextStyles.bodySmall),
                const SizedBox(height: 10),
                StatusBadge(
                  label: '✓ ${_t(lang, 'متوفر', 'Disponible')}',
                  color: item.status == 'available' ? AppColors.primaryDark : AppColors.error,
                  bg: item.status == 'available' ? AppColors.primaryLight : const Color(0xFFFEF2F2),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            CardShell(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_t(lang, 'مستوى المخزون', 'Niveau de stock'), style: AppTextStyles.headlineMedium),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${item.currentKg.toInt()} ${item.unit}', style: AppTextStyles.valueLarge.copyWith(color: AppColors.primary)),
                  Text('${_t(lang, 'من', 'de')} ${item.capacityKg.toInt()} ${item.unit}', style: AppTextStyles.bodySmall),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percentage,
                    backgroundColor: AppColors.surfAlt(context),
                    valueColor: AlwaysStoppedAnimation<Color>(item.status == 'low' ? AppColors.error : AppColors.primary),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(item.percentage * 100).toInt()}% ${_t(lang, 'من الطاقة القصوى', 'de la capacité max')}', style: AppTextStyles.caption),
              ]),
            ),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }
}
