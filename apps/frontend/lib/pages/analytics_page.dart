import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/analytics_provider.dart';
import '../providers/settings_provider.dart';
import '../services/report_service.dart';
import '../services/api_client.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selPeriod = 0;
  final _periods = const ['أسبوع', 'شهر', '3 أشهر', 'سنة'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AnalyticsProvider>();
      if (p.state == LoadState.idle) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Consumer<AnalyticsProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(provider),
                    const SizedBox(height: 18),
                    _periodSelector(),
                    const SizedBox(height: 18),
                    _statsSection(provider),
                    const SizedBox(height: 18),
                    _irrigationCard(provider),
                    const SizedBox(height: 18),
                    _cropHealthCard(provider),
                    const SizedBox(height: 18),
                    _alertsCard(provider),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(AnalyticsProvider provider) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => provider.load(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.surfAlt(context),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.refresh_rounded,
                  size: 22, color: AppColors.txtSec(context)),
            ),
          ),
          Text('التحليلات',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.txt(context))),
          GestureDetector(
            onTap: () => _showExportSheet(context, provider),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: const Icon(Icons.download_rounded,
                  size: 20, color: AppColors.primary),
            ),
          ),
        ],
      );

  void _showExportSheet(BuildContext context, AnalyticsProvider provider) {
    final isFr = context.read<SettingsProvider>().settings.language == 'fr';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.bord(context),
                  borderRadius: BorderRadius.circular(2))),
          Text(isFr ? 'Exporter les données' : 'تصدير البيانات',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 20),
          _exportTile(
            context,
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.error,
            bg: const Color(0xFFFEF2F2),
            title: isFr ? 'Rapport PDF de saison' : 'تقرير PDF للموسم',
            sub: isFr
                ? 'Résumé complet de la saison'
                : 'ملخص شامل للموسم الزراعي',
            onTap: () async {
              Navigator.pop(context);
              final sp = context.read<SettingsProvider>().settings;
              await ReportService.exportSeasonPDF(
                farmName: sp.farmName ?? 'مزرعتي',
                totalCrops: provider.summary?.totalCrops ?? 0,
                totalActivities: 0,
                avgHealth: provider.summary?.averageCropHealth ?? 0,
                totalIrrigations: provider.summary?.totalIrrigationEvents ?? 0,
                alertCount: provider.summary?.unreadAlerts ?? 0,
                lowStockCount: provider.summary?.lowStockItems ?? 0,
                context: context,
              );
            },
          ),
          SizedBox(height: 12),
          _exportTile(
            context,
            icon: Icons.table_chart_rounded,
            color: AppColors.primary,
            bg: AppColors.primLight(context),
            title: isFr ? 'Export CSV des activités' : 'تصدير CSV الأنشطة',
            sub: isFr
                ? 'Toutes les activités en tableau'
                : 'جميع الأنشطة بصيغة جدول',
            onTap: () async {
              Navigator.pop(context);
              try {
                final api = context.read<ApiClient>();
                final res = await api.get('/activities?limit=200');
                final list = res is Map
                    ? (res['items'] ?? res['data'] ?? [])
                    : res as List;
                await ReportService.exportActivitiesCSV(
                    List<Map<String, dynamic>>.from(list as List));
              } catch (_) {
                ReportService.exportActivitiesCSV(const []);
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget _exportTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bord(context))),
          child: Row(children: [
            Icon(Icons.chevron_left_rounded,
                size: 18, color: AppColors.txtMuted(context)),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.txt(context))),
              Text(sub,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.txtMuted(context))),
            ]),
            const SizedBox(width: 12),
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: color)),
          ]),
        ),
      );

  Widget _periodSelector() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.surfAlt(context),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
            children: List.generate(_periods.length, (i) {
          final sel = i == _selPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.surf(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: sel
                      ? const [
                          BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ]
                      : null,
                ),
                child: Text(_periods[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: sel
                          ? AppColors.txt(context)
                          : AppColors.txtMuted(context),
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
            ),
          );
        })),
      );

  Widget _statsSection(AnalyticsProvider provider) {
    if (provider.isLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (provider.state == LoadState.error) {
      return CardShell(
          child: Center(
              child: Column(children: [
        Icon(Icons.cloud_off_rounded,
            color: AppColors.txtMuted(context), size: 36),
        const SizedBox(height: 8),
        Text(provider.errorMessage ?? 'خطأ في التحميل',
            style: AppTextStyles.bodySmall),
        TextButton(
            onPressed: () => provider.load(),
            child: const Text('إعادة المحاولة')),
      ])));
    }
    final s = provider.summary;
    if (s == null) return const SizedBox.shrink();

    final stats = [
      {
        'label': 'إجمالي المحاصيل',
        'value': '${s.totalCrops}',
        'icon': Icons.eco_rounded,
        'color': AppColors.primary,
        'bg': AppColors.primaryLight
      },
      {
        'label': 'أحداث الري',
        'value': '${s.totalIrrigationEvents}',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.info,
        'bg': AppColors.blueLight
      },
      {
        'label': 'تنبيهات غير مقروءة',
        'value': '${s.unreadAlerts}',
        'icon': Icons.notifications_rounded,
        'color': AppColors.warning,
        'bg': AppColors.orangeLight
      },
      {
        'label': 'مخزون منخفض',
        'value': '${s.lowStockItems}',
        'icon': Icons.inventory_2_rounded,
        'color': AppColors.error,
        'bg': const Color(0xFFFEF2F2)
      },
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'ملخص المزرعة'),
      SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.45,
        children: stats
            .map((s) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.surf(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bord(context))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                      color: s['bg'] as Color,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(s['icon'] as IconData,
                                      size: 18, color: s['color'] as Color)),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['value'] as String,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      fontSize: 22,
                                      color: s['color'] as Color)),
                              Text(s['label'] as String,
                                  style: AppTextStyles.caption),
                            ]),
                      ]),
                ))
            .toList(),
      ),
      const SizedBox(height: 10),
      // Average health bar
      CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${s.averageCropHealth.toStringAsFixed(1)}%',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.primary)),
          Text('متوسط صحة المحاصيل', style: AppTextStyles.bodyMedium),
        ]),
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: s.averageCropHealth / 100,
            backgroundColor: AppColors.surfAlt(context),
            valueColor: AlwaysStoppedAnimation<Color>(s.averageCropHealth > 70
                ? AppColors.primary
                : s.averageCropHealth > 40
                    ? AppColors.warning
                    : AppColors.error),
            minHeight: 10,
          ),
        ),
      ])),
    ]);
  }

  Widget _irrigationCard(AnalyticsProvider provider) {
    if (provider.state != LoadState.loaded) return const SizedBox.shrink();
    final irr = provider.irrigation;
    if (irr == null) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'إحصائيات الري'),
      const SizedBox(height: 10),
      CardShell(
          child: Column(children: [
        Row(children: [
          _IrrigationStat(
              label: 'أحداث الري',
              value: '${irr.totalEvents}',
              icon: Icons.water_drop_outlined,
              color: AppColors.info),
          const SizedBox(width: 12),
          _IrrigationStat(
              label: 'إجمالي المياه (ل)',
              value: irr.totalWaterLiters.toStringAsFixed(0),
              icon: Icons.opacity_rounded,
              color: AppColors.primary),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _IrrigationStat(
              label: 'المدة (دقيقة)',
              value: irr.totalDurationMinutes.toStringAsFixed(0),
              icon: Icons.timer_outlined,
              color: AppColors.warning),
          const SizedBox(width: 12),
          _IrrigationStat(
              label: 'متوسط/حدث (ل)',
              value: irr.averageWaterPerEvent.toStringAsFixed(1),
              icon: Icons.bar_chart_rounded,
              color: AppColors.orange),
        ]),
      ])),
    ]);
  }

  Widget _cropHealthCard(AnalyticsProvider provider) {
    if (provider.state != LoadState.loaded) return const SizedBox.shrink();
    final crops = provider.cropHealth;
    if (crops.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'صحة المحاصيل'),
      const SizedBox(height: 10),
      CardShell(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          HealthRing(
            progress: crops.isNotEmpty
                ? (crops.map((c) => c.healthScore).reduce((a, b) => a + b) /
                        crops.length) /
                    100
                : 0,
            size: 110,
            strokeWidth: 10,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  crops.isNotEmpty
                      ? '${(crops.map((c) => c.healthScore).reduce((a, b) => a + b) / crops.length).toStringAsFixed(0)}%'
                      : '--',
                  style: AppTextStyles.headlineLarge.copyWith(fontSize: 22)),
              Text('صحي', style: AppTextStyles.caption),
            ]),
          ),
          SizedBox(height: 14),
          ...crops.take(5).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.healthScore / 100,
                      backgroundColor: AppColors.surfAlt(context),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(c.healthScore > 70
                              ? AppColors.primary
                              : c.healthScore > 40
                                  ? AppColors.warning
                                  : AppColors.error),
                      minHeight: 7,
                    ),
                  )),
                  SizedBox(width: 12),
                  SizedBox(
                      width: 100,
                      child: Text(c.name,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.txt(context)),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis)),
                ]),
              )),
        ],
      )),
    ]);
  }

  Widget _alertsCard(AnalyticsProvider provider) {
    if (provider.state != LoadState.loaded) return const SizedBox.shrink();
    final alerts = provider.alerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    // Summarize by severity
    final bySeverity = <String, int>{};
    for (final a in alerts) {
      bySeverity[a.severity] = (bySeverity[a.severity] ?? 0) + a.count;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'ملخص التنبيهات'),
      const SizedBox(height: 10),
      CardShell(
          child: Column(children: [
        ...bySeverity.entries.map((e) {
          final color = e.key == 'critical'
              ? AppColors.error
              : e.key == 'high'
                  ? AppColors.warning
                  : AppColors.info;
          final label = e.key == 'critical'
              ? 'حرجة'
              : e.key == 'high'
                  ? 'عالية'
                  : e.key == 'medium'
                      ? 'متوسطة'
                      : 'منخفضة';
          return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Text('${e.value}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: color, fontWeight: FontWeight.w700)),
                SizedBox(width: 12),
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:
                        (e.value / (bySeverity.values.reduce((a, b) => a + b))),
                    backgroundColor: AppColors.surfAlt(context),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 7,
                  ),
                )),
                SizedBox(width: 12),
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txt(context))),
              ]));
        }),
      ])),
    ]);
  }
}

class _IrrigationStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _IrrigationStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surfAlt(context),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
          ]),
        ]),
      ));
}
