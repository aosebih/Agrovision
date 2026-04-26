import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/crop_model.dart';
import 'crop_health_detail_page.dart';
import 'add_crop_page.dart';

class CropsPage extends StatelessWidget {
  const CropsPage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropPage())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) => SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                _iconBtn(Icons.calendar_today_outlined),
                const SizedBox(width: 8),
                _iconBtn(Icons.notifications_outlined),
              ]),
              Text('محاصيلي', style: AppTextStyles.titleLarge),
            ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(height: 46, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.tune_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text('البحث عن الحقول أو أنواع المحاصيل', style: AppTextStyles.bodySmall),
                const Spacer(),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 14),
              ]))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _filterChip('الكل', true),
              const SizedBox(width: 8),
              _filterChip('سليمة', false, color: AppColors.primary),
              const SizedBox(width: 8),
              _filterChip('تحذير', false, color: AppColors.warning),
              const SizedBox(width: 8),
              _filterChip('حرجة', false, color: AppColors.error),
            ])),
          Expanded(child: _body(context, provider)),
        ])),
      ),
    ),
  );

  Widget _iconBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Icon(icon, size: 20, color: AppColors.textSecondary),
  );

  Widget _filterChip(String label, bool sel, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (color != null && !sel) ...[Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5)],
      Text(label, style: AppTextStyles.bodySmall.copyWith(color: sel ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _body(BuildContext context, DashboardProvider provider) {
    if (provider.isLoading && provider.crops.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.crops.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'تعذر التحميل', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(label: 'إعادة المحاولة', onTap: () => provider.load()),
      ]));
    }
    final crops = provider.crops;
    if (crops.isEmpty) return Center(child: Text('لا توجد محاصيل', style: AppTextStyles.bodySmall));
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _cropCard(context, crops[i]),
      ),
    );
  }

  Widget _cropCard(BuildContext context, RemoteCrop crop) {
    final statusColor = crop.statusKey == 'healthy' ? AppColors.primary : crop.statusKey == 'warning' ? AppColors.warning : AppColors.error;
    final statusBg    = crop.statusKey == 'healthy' ? AppColors.primaryLight : crop.statusKey == 'warning' ? AppColors.orangeLight : const Color(0xFFFEF2F2);
    return CardShell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropHealthDetailPage(crop: crop))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.water_drop_outlined, size: 14, color: AppColors.info),
            const SizedBox(width: 4),
            Text('رطوبة ${crop.humidity.toInt()}%', style: AppTextStyles.caption),
            const SizedBox(width: 10),
            const Icon(Icons.thermostat_rounded, size: 14, color: AppColors.orange),
            const SizedBox(width: 4),
            Text('${crop.temp.toInt()}°م', style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 4),
          if (crop.statusKey != 'healthy') Row(children: [
            Icon(Icons.warning_amber_rounded, size: 14, color: statusColor),
            const SizedBox(width: 4),
            Text(crop.statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor)),
          ]),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(label: crop.statusLabel, color: statusColor, bg: statusBg),
          const SizedBox(height: 4),
          Text(crop.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          Text('${crop.variety} • اليوم ${crop.growthDay}', style: AppTextStyles.caption),
        ])),
        const SizedBox(width: 12),
        Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.grass_rounded, size: 32, color: AppColors.primary)),
      ]),
    );
  }
}
