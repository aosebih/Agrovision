import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selFilter = 0;
  final _filters = const ['الكل', 'الري', 'المعالجات', 'التنبيهات'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.data == null) p.load();
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) => SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.mark_as_unread_outlined, size: 22, color: AppColors.textSecondary),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('التنبيهات', style: AppTextStyles.titleLarge),
              Text('حالة المزرعة: مراقبة', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ]),
          ])),
          SizedBox(height: 44, child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filters.length,
            itemBuilder: (_, i) { final sel = i == _selFilter;
              return GestureDetector(onTap: () => setState(() => _selFilter = i), child: Container(
                margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
                child: Text(_filters[i], style: AppTextStyles.bodySmall.copyWith(color: sel ? Colors.white : AppColors.textSecondary))));
            },
          )),
          Expanded(child: _body(provider)),
        ])),
      ),
    ),
  );

  Widget _body(DashboardProvider provider) {
    if (provider.isLoading && provider.data == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final data = provider.data;
    // Build alerts from storage low-stock items + crop warnings
    final alerts = _buildAlerts(data);
    if (alerts.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 56),
        const SizedBox(height: 12),
        Text('لا توجد تنبيهات نشطة', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text('كل شيء على ما يرام!', style: AppTextStyles.bodySmall),
      ]));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Text('اليوم', style: AppTextStyles.labelSmall),
        const SizedBox(height: 10),
        ...alerts.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _alertCard(a))),
      ]),
    );
  }

  List<Map<String, dynamic>> _buildAlerts(DashboardData? data) {
    final alerts = <Map<String, dynamic>>[];
    if (data == null) return alerts;

    // Low-stock storage items
    for (final item in data.storage.where((s) => s.status == 'low')) {
      alerts.add({
        'title': 'انخفاض المخزون',
        'desc': '${item.name}: ${item.currentKg.toInt()}/${item.capacityKg.toInt()} ${item.unit} متبقي. يلزم إعادة التعبئة.',
        'type': 'تحذير',
        'time': item.lastUpdatedLabel,
        'icon': Icons.inventory_2_outlined,
        'critical': false,
      });
    }

    // Crop health warnings
    if (data.cropHealth.warningCount > 0) {
      alerts.add({
        'title': 'محاصيل تحتاج مراقبة',
        'desc': '${data.cropHealth.warningCount} حقول تحتاج انتباهاً. تحقق من التفاصيل.',
        'type': 'تحذير',
        'time': 'الآن',
        'icon': Icons.warning_amber_rounded,
        'critical': false,
      });
    }
    if (data.cropHealth.criticalCount > 0) {
      alerts.add({
        'title': 'تنبيه حرج',
        'desc': '${data.cropHealth.criticalCount} حقول في حالة حرجة تستوجب تدخلاً فورياً.',
        'type': 'حرجة',
        'time': 'الآن',
        'icon': Icons.emergency_rounded,
        'critical': true,
      });
    }
    return alerts;
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final isCritical = alert['critical'] as bool;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCritical ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Text(alert['time'] as String, style: AppTextStyles.caption.copyWith(color: isCritical ? AppColors.error : AppColors.textMuted)),
          if (isCritical) ...[const SizedBox(width: 6), Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))],
          const Spacer(),
          Text(alert['title'] as String, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Container(width: 38, height: 38, decoration: BoxDecoration(color: isCritical ? const Color(0xFFFEF2F2) : AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(alert['icon'] as IconData, size: 18, color: isCritical ? AppColors.error : AppColors.warning)),
        ]),
        const SizedBox(height: 8),
        Text(alert['desc'] as String, style: AppTextStyles.bodySmall),
      ]),
    );
  }
}
