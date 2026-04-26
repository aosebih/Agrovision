import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/dashboard_response.dart';

class FertilizerDetailPage extends StatelessWidget {
  final RemoteStorageItem item;
  const FertilizerDetailPage({super.key, required this.item});

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
              const PageHeader(title: 'تفاصيل السماد'),
              const SizedBox(height: 20),

              // Hero card
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.eco_rounded,
                            size: 44, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    Text(item.name,
                        style: AppTextStyles.titleLarge,
                        textAlign: TextAlign.center),
                    Text(item.lastUpdatedLabel, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 10),
                    StatusBadge(
                      label:
                          '✓ المخزون: ${item.status == 'available' ? 'متوفر' : item.status == 'low' ? 'منخفض' : 'متوسط'}',
                      color: item.status == 'available'
                          ? AppColors.primaryDark
                          : AppColors.error,
                      bg: item.status == 'available'
                          ? AppColors.primaryLight
                          : const Color(0xFFFEF2F2),
                    ),
                  ])),
              const SizedBox(height: 16),

              // Stock level
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text('مستوى المخزون', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 14),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.currentKg.toInt()} ${item.unit}',
                              style: AppTextStyles.valueLarge
                                  .copyWith(color: AppColors.primary)),
                          Text('من ${item.capacityKg.toInt()} ${item.unit}',
                              style: AppTextStyles.bodySmall),
                        ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: item.percentage,
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                item.status == 'low'
                                    ? AppColors.error
                                    : AppColors.primary),
                            minHeight: 10)),
                    const SizedBox(height: 6),
                    Text('${(item.percentage * 100).toInt()}% من الطاقة القصوى',
                        style: AppTextStyles.caption),
                  ])),
              const SizedBox(height: 16),

              // NPK bars (representative for fertilizers)
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {},
                              child: Text('عرض التحليل',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600))),
                          Text('التركيبة (N-P-K)',
                              style: AppTextStyles.headlineMedium),
                        ]),
                    const SizedBox(height: 16),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _npkBar(
                              '19%', 'K', 'بوتاسيوم', const Color(0xFFF59E0B)),
                          _npkBar('19%', 'P', 'فسفور', AppColors.primary),
                          _npkBar('19%', 'N', 'نيتروجين', AppColors.info),
                        ]),
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  'تركيبة متوازنة مثالية لمراحل النمو العامة.',
                                  style: AppTextStyles.caption)),
                        ])),
                  ])),
              const SizedBox(height: 80),
            ]),
          )),
        ),
      );

  Widget _npkBar(String pct, String symbol, String label, Color color) =>
      Column(children: [
        Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(pct,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)))),
        const SizedBox(height: 6),
        Text(symbol,
            style: AppTextStyles.bodyMedium
                .copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.caption),
      ]);
}
