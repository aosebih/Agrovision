import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';
import 'field_detail_page.dart';

class CropHealthDetailPage extends StatelessWidget {
  final RemoteCrop crop;
  const CropHealthDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.share_outlined,
                        size: 22, color: AppColors.textSecondary)),
                const Spacer(),
                Text('تفاصيل صحة المحصول', style: AppTextStyles.titleLarge),
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
                            size: 15, color: AppColors.textSecondary))),
              ]),
              const SizedBox(height: 20),

              // NDVI satellite card
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StatusBadge(
                              label: 'عرض مباشر',
                              color: AppColors.primaryDark,
                              bg: AppColors.primaryLight),
                          Text('حيوية الحقل (NDVI)',
                              style: AppTextStyles.headlineMedium),
                        ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                            'lib/compenent/images/Satellite view of agricultural fields from above.png',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                height: 160,
                                color: const Color(0xFF2D6A4F),
                                child: const Center(
                                    child: Icon(Icons.map_outlined,
                                        size: 60, color: Colors.white54))))),
                    const SizedBox(height: 10),
                    Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('صحة جيدة', style: AppTextStyles.caption),
                      const SizedBox(width: 16),
                      Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('يتطلب انتباه', style: AppTextStyles.caption),
                    ]),
                  ])),
              const SizedBox(height: 14),

              // Health ring
              CardShell(
                  child: Column(children: [
                HealthRing(
                    progress: crop.health,
                    size: 130,
                    strokeWidth: 12,
                    color: crop.statusKey == 'healthy'
                        ? AppColors.primary
                        : crop.statusKey == 'warning'
                            ? AppColors.warning
                            : AppColors.error,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${(crop.health * 100).toInt()}%',
                          style: AppTextStyles.headlineLarge
                              .copyWith(fontSize: 26)),
                      Text('صحي', style: AppTextStyles.caption),
                    ])),
                const SizedBox(height: 12),
                StatusBadge(
                    label: crop.statusLabel,
                    color: _statusColor(),
                    bg: _statusBg()),
              ])),
              const SizedBox(height: 14),

              // Vitals row
              Row(children: [
                Expanded(
                    child: CardShell(
                        padding: const EdgeInsets.all(14),
                        child: Column(children: [
                          const Icon(Icons.water_drop_outlined,
                              size: 22, color: AppColors.info),
                          const SizedBox(height: 6),
                          Text('${crop.humidity.toInt()}%',
                              style: AppTextStyles.headlineMedium),
                          Text('الرطوبة', style: AppTextStyles.caption),
                          Text('NDVI: ${crop.ndvi.toStringAsFixed(2)}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary)),
                        ]))),
                const SizedBox(width: 12),
                Expanded(
                    child: CardShell(
                        padding: const EdgeInsets.all(14),
                        child: Column(children: [
                          const Icon(Icons.thermostat_rounded,
                              size: 22, color: AppColors.orange),
                          const SizedBox(height: 6),
                          Text('${crop.temp.toInt()}°م',
                              style: AppTextStyles.headlineMedium),
                          Text('درجة الحرارة', style: AppTextStyles.caption),
                          Text('اليوم ${crop.growthDay}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.orange)),
                        ]))),
              ]),
              const SizedBox(height: 14),

              // Growth stage
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text('مرحلة النمو', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 6),
                    Text('النمو الخضري — اليوم ${crop.growthDay}',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 10),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: (crop.growthDay / 120).clamp(0.0, 1.0),
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 8)),
                  ])),
              const SizedBox(height: 14),

              // Navigate to full analysis
              GreenButton(
                label: 'عرض التحليل الكامل',
                icon: Icons.analytics_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FieldDetailPage(crop: crop))),
              ),
              const SizedBox(height: 40),
            ]),
          )),
        ),
      );

  Color _statusColor() => crop.statusKey == 'healthy'
      ? AppColors.primaryDark
      : crop.statusKey == 'warning'
          ? AppColors.orange
          : AppColors.error;
  Color _statusBg() => crop.statusKey == 'healthy'
      ? AppColors.primaryLight
      : crop.statusKey == 'warning'
          ? AppColors.orangeLight
          : const Color(0xFFFEF2F2);
}
