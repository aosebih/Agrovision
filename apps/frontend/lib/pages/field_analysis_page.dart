import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class FieldAnalysisPage extends StatelessWidget {
  final RemoteCrop crop;
  const FieldAnalysisPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surf(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.bord(context))),
                child: Icon(Icons.notifications_outlined, size: 20, color: AppColors.txtSec(context)),
              ),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(crop.fieldName, style: AppTextStyles.caption),
                Row(children: [
                  if (crop.health > 0.85) const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(crop.name, style: AppTextStyles.titleLarge),
                ]),
              ]),
            ]),
            const SizedBox(height: 6),
            Text('${_t(lang, 'تحليل يوم', 'Analyse du')} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
            const SizedBox(height: 18),
            CardShell(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_t(lang, 'مؤشر الصحة', 'Indice de santé'), style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  StatusBadge(label: '+${(crop.health * 2.4).toStringAsFixed(1)}%', color: AppColors.primary, bg: AppColors.primaryLight),
                  Text('${(crop.health * 100).toInt()}%', style: AppTextStyles.headlineLarge.copyWith(fontSize: 40, color: AppColors.primary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: crop.health,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.statusKey == 'healthy'
                      ? _t(lang, 'الظروف ممتازة للنمو الخضري.', 'Conditions excellentes.')
                      : _t(lang, 'الحالة تحتاج مراقبة.', 'Situation à surveiller.'),
                  style: AppTextStyles.bodySmall,
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: CardShell(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_t(lang, 'متوسط الرطوبة', 'Humidité moy.'), style: AppTextStyles.caption),
                    const SizedBox(height: 10),
                    Text('${crop.humidity.toInt()}%', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.info)),
                    const SizedBox(height: 6),
                    Text('${_t(lang, 'الهدف', 'Cible')}: 40-60%', style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardShell(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_t(lang, 'البيئة', 'Environnement'), style: AppTextStyles.caption),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${crop.temp.toInt()}°', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      Text(_t(lang, 'درجة الحرارة', 'Température'), style: AppTextStyles.caption),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(crop.ndvi.toStringAsFixed(2), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      Text('NDVI', style: AppTextStyles.caption),
                    ]),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }
}
