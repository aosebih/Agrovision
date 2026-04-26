import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/dashboard_response.dart';

class InventoryDetailPage extends StatelessWidget {
  final RemoteStorageItem item;
  const InventoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: GreenButton(
                label: 'جدولة الاستخدام',
                icon: Icons.calendar_today_outlined,
                onTap: () {}),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              PageHeader(title: 'التفاصيل', subtitle: item.name),
              const SizedBox(height: 16),
              // Header card
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 8),
                          StatusBadge(
                              label: 'سماد',
                              color: AppColors.primary,
                              bg: AppColors.primaryLight),
                        ]),
                    const SizedBox(height: 8),
                    Text(item.name, style: AppTextStyles.titleLarge),
                    Text(item.lastUpdatedLabel, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 12),
                    Row(children: [
                      GreenButton(label: '+ إعادة تعبئة', onTap: () {}),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {},
                        child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.history_rounded,
                                      size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text('السجل',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary)),
                                ])),
                      )),
                    ]),
                  ])),
              const SizedBox(height: 14),
              // Quantity card
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                            label: item.status == 'available'
                                ? '● متوفر بالمخزن'
                                : item.status == 'low'
                                    ? '⚠ مخزون منخفض'
                                    : '● مستوى متوسط',
                            color: item.status == 'available'
                                ? AppColors.primary
                                : item.status == 'low'
                                    ? AppColors.error
                                    : AppColors.warning,
                            bg: item.status == 'available'
                                ? AppColors.primaryLight
                                : item.status == 'low'
                                    ? const Color(0xFFFEF2F2)
                                    : AppColors.orangeLight,
                          ),
                          Text('الكمية المتبقية',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textMuted)),
                        ]),
                    const SizedBox(height: 6),
                    Text('${item.currentKg.toInt()} ${item.unit}',
                        style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                            value: item.percentage,
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                item.status == 'available'
                                    ? AppColors.primary
                                    : item.status == 'low'
                                        ? AppColors.error
                                        : AppColors.warning),
                            minHeight: 10)),
                    const SizedBox(height: 6),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'السعة القصوى: ${item.capacityKg.toInt()} ${item.unit}',
                              style: AppTextStyles.caption),
                          Text('${(item.percentage * 100).toInt()}%',
                              style: AppTextStyles.caption),
                        ]),
                  ])),
              const SizedBox(height: 14),
              SectionHeader(
                  title: 'توافق الحقول',
                  action: 'عرض الخريطة',
                  onAction: () {}),
              const SizedBox(height: 8),
              CardShell(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text('مطلوب 120 كجم/هـ',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('حقل (أ) - قمح',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textPrimary)),
                          const StatusBadge(
                              label: 'يحتاج اهتمام',
                              color: AppColors.orange,
                              bg: AppColors.orangeLight),
                        ]),
                    Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                            child: Text('أ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)))),
                  ])),
              const SizedBox(height: 80),
            ]),
          )),
        ),
      );
}
