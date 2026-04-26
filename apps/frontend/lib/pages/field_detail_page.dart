import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';
import 'field_analysis_page.dart';

class FieldDetailPage extends StatelessWidget {
  final RemoteCrop crop;
  const FieldDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: GreenButton(
                label: '< مشاركة تقرير النجاح',
                icon: Icons.share_outlined,
                onTap: () {}),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.notifications_outlined,
                        size: 20, color: AppColors.textSecondary)),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(crop.field, style: AppTextStyles.caption),
                  Row(children: [
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FieldAnalysisPage(crop: crop))),
                        child: const Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Text(crop.name, style: AppTextStyles.titleLarge),
                    const SizedBox(width: 6),
                    if (crop.health > 0.85)
                      const Icon(Icons.verified_rounded,
                          size: 16, color: AppColors.primary),
                  ]),
                ]),
              ]),
              const SizedBox(height: 20),

              // Health ring card
              CardShell(
                  child: Column(children: [
                HealthRing(
                    progress: crop.health,
                    size: 160,
                    strokeWidth: 14,
                    color: crop.statusKey == 'healthy'
                        ? AppColors.primary
                        : AppColors.warning,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${(crop.health * 100).toInt()}%',
                          style: AppTextStyles.bigPercent),
                      Text('صحي', style: AppTextStyles.bodySmall),
                    ])),
                const SizedBox(height: 14),
                StatusBadge(
                    label: '🌿 ${crop.statusLabel}',
                    color: AppColors.primaryDark,
                    bg: AppColors.primaryLight),
                const SizedBox(height: 8),
                Text(
                    'بناءاً على مسح اليوم. اليوم ${crop.growthDay} من دورة النمو.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center),
              ])),
              const SizedBox(height: 14),

              // Drone feed
              SectionHeader(
                  title: 'مشاهدة الحقل', action: 'عرض الكل', onAction: () {}),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                            'lib/compenent/images/Wheat field.png',
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                height: 90, color: const Color(0xFF2D6A4F))))),
                const SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: Stack(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                              'lib/compenent/images/Satellite view of agricultural fields from above.png',
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  height: 90, color: const Color(0xFF1B4332)))),
                      const Positioned(
                          top: 8,
                          right: 8,
                          child: StatusBadge(
                              label: '● مباشر',
                              color: Colors.white,
                              bg: AppColors.error)),
                      Positioned(
                          bottom: 8,
                          left: 8,
                          child: Text(crop.field,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                    ])),
              ]),
              const SizedBox(height: 14),

              // Bio markers
              const SectionHeader(title: 'العلامات الحيوية'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _vitalCard(
                      Icons.water_drop_outlined,
                      AppColors.info,
                      'الرطوبة',
                      '${crop.humidity.toInt()}%',
                      '+2%',
                      'نطاق مثالي',
                      AppColors.blueLight),
                  _vitalCard(
                      Icons.eco_rounded,
                      AppColors.primary,
                      'معدل النمو',
                      crop.health > 0.8 ? 'سريع' : 'متوسط',
                      '+5%',
                      'مقارنة بالمتوسط',
                      AppColors.primaryLight),
                  _vitalCard(
                      Icons.bug_report_outlined,
                      AppColors.error,
                      'مخاطر الآفات',
                      crop.statusKey == 'healthy' ? 'منخفض' : 'مرتفع',
                      '0%',
                      'منطقة آمنة',
                      const Color(0xFFFEF2F2)),
                  _vitalCard(
                      Icons.grid_3x3_rounded,
                      AppColors.warning,
                      'مؤشر NDVI',
                      crop.ndvi.toStringAsFixed(2),
                      '0%',
                      'كثافة عالية',
                      AppColors.orangeLight),
                ],
              ),
              const SizedBox(height: 80),
            ]),
          )),
        ),
      );

  Widget _vitalCard(IconData icon, Color color, String label, String val,
          String change, String sub, Color bg) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(change,
                style: AppTextStyles.caption
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 15, color: color)),
          ]),
          const SizedBox(height: 4),
          Text(val, style: AppTextStyles.headlineMedium),
          Text(label, style: AppTextStyles.caption),
          Text(sub, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ]),
      );
}
