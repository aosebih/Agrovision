import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/crop_model.dart';
import 'add_crop_page.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});
  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.crops.isEmpty) p.load();
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final added = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddCropPage()));
              if (added == true && context.mounted) {
                context.read<DashboardProvider>().load();
              }
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          body: Consumer<DashboardProvider>(
            builder: (context, provider, _) => SafeArea(
                child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border)),
                            child: const Icon(Icons.eco_rounded,
                                size: 20, color: AppColors.primary)),
                        Text('محاصيلي', style: AppTextStyles.titleLarge),
                      ])),
              Expanded(child: _body(context, provider)),
            ])),
          ),
        ),
      );

  Widget _body(BuildContext context, DashboardProvider provider) {
    if (provider.isLoading && provider.crops.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.crops.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded,
            color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'تعذر التحميل',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(label: 'إعادة المحاولة', onTap: () => provider.load()),
      ]));
    }
    final crops = provider.crops;
    if (crops.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.grass_rounded, color: AppColors.textMuted, size: 52),
        const SizedBox(height: 12),
        Text('لا توجد محاصيل بعد', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(
            label: 'إضافة محصول',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddCropPage()))),
      ]));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _cropCard(context, crops[i]),
      ),
    );
  }

  Widget _cropCard(BuildContext context, RemoteCrop crop) {
    final statusColor = crop.statusKey == 'healthy'
        ? AppColors.primary
        : crop.statusKey == 'warning'
            ? AppColors.warning
            : AppColors.error;
    final statusBg = crop.statusKey == 'healthy'
        ? AppColors.primaryLight
        : crop.statusKey == 'warning'
            ? AppColors.orangeLight
            : const Color(0xFFFEF2F2);

    return CardShell(
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (crop.plantedDate != null)
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(crop.plantedDate!.split('T').first,
                  style: AppTextStyles.caption),
            ]),
          const SizedBox(height: 4),
          if (crop.growthStage != null)
            Row(children: [
              const Icon(Icons.energy_savings_leaf_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(crop.growthStage!, style: AppTextStyles.caption),
            ]),
        ]),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(
              label: crop.statusLabel, color: statusColor, bg: statusBg),
          const SizedBox(height: 4),
          Text(crop.name,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
          if (crop.variety != null)
            Text(crop.variety!, style: AppTextStyles.caption),
          if (crop.fieldName != '-')
            Text('الحقل: ${crop.fieldName}',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ])),
        const SizedBox(width: 12),
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child:
                const Icon(Icons.grass_rounded, size: 32, color: AppColors.primary)),
      ]),
    );
  }
}