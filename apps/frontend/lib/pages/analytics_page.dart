import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';

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
  final _chartData = const [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.85];
  final _chartLabels = const ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.data == null) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<DashboardProvider>(
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
                    _header(),
                    const SizedBox(height: 18),
                    _periodSelector(),
                    const SizedBox(height: 18),
                    _statsSection(provider),
                    const SizedBox(height: 18),
                    _chartCard(),
                    const SizedBox(height: 18),
                    const SectionHeader(title: 'ملخص صحة المحاصيل'),
                    const SizedBox(height: 10),
                    _healthSummaryCard(provider),
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

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.download_outlined,
              size: 22, color: AppColors.textSecondary),
          Text('التحليلات', style: AppTextStyles.titleLarge),
        ],
      );

  Widget _periodSelector() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
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
                    color: sel ? AppColors.surface : Colors.transparent,
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
                          color:
                              sel ? AppColors.textPrimary : AppColors.textMuted,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              ),
            );
          }),
        ),
      );

  Widget _statsSection(DashboardProvider provider) {
    if (provider.isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: AppColors.primary),
      ));
    }
    if (provider.state == LoadState.error) {
      return CardShell(
          child: Center(
              child: Column(children: [
        const Icon(Icons.cloud_off_rounded,
            color: AppColors.textMuted, size: 36),
        const SizedBox(height: 8),
        Text(provider.errorMessage ?? 'خطأ في التحميل',
            style: AppTextStyles.bodySmall),
        TextButton(
            onPressed: () => provider.load(),
            child: const Text('إعادة المحاولة')),
      ])));
    }
    final data = provider.data;
    if (data == null) return const SizedBox.shrink();
    return _statsGrid(data.cropHealth);
  }

  Widget _statsGrid(CropHealthSummary? h) {
    final stats = [
      {
        'label': 'الحقول السليمة',
        'value': h != null ? '${h.healthyCount}/${h.totalFields}' : '--',
        'change': '+0',
        'pos': true,
        'icon': Icons.eco_rounded,
        'color': AppColors.primary,
        'bg': AppColors.primaryLight
      },
      {
        'label': 'تحت المراقبة',
        'value': h != null ? '${h.warningCount}' : '--',
        'change': '0',
        'pos': true,
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.warning,
        'bg': AppColors.orangeLight
      },
      {
        'label': 'صحة عامة',
        'value': h != null ? '${h.overallHealthPercent}%' : '--',
        'change': '+2%',
        'pos': true,
        'icon': Icons.favorite_border_rounded,
        'color': AppColors.info,
        'bg': AppColors.blueLight
      },
      {
        'label': 'حرجة',
        'value': h != null ? '${h.criticalCount}' : '--',
        'change': '0',
        'pos': false,
        'icon': Icons.emergency_rounded,
        'color': AppColors.error,
        'bg': const Color(0xFFFEF2F2)
      },
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: stats
          .map((s) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: (s['pos'] as bool)
                                        ? AppColors.primaryLight
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(s['change'] as String,
                                    style: AppTextStyles.caption.copyWith(
                                        color: (s['pos'] as bool)
                                            ? AppColors.primaryDark
                                            : AppColors.error,
                                        fontWeight: FontWeight.w700))),
                            Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: s['bg'] as Color,
                                    borderRadius: BorderRadius.circular(9)),
                                child: Icon(s['icon'] as IconData,
                                    size: 16, color: s['color'] as Color)),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['value'] as String,
                                style: AppTextStyles.headlineMedium),
                            Text(s['label'] as String,
                                style: AppTextStyles.caption),
                          ]),
                    ]),
              ))
          .toList(),
    );
  }

  Widget _chartCard() => CardShell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('صحة المحاصيل الأسبوعية', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text('متوسط 85% هذا الأسبوع', style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          SizedBox(
              height: 110,
              child: CustomPaint(
                  size: const Size(double.infinity, 110),
                  painter: _BarChart(data: _chartData, labels: _chartLabels))),
        ]),
      );

  Widget _healthSummaryCard(DashboardProvider provider) {
    final data = provider.data;
    if (data == null) return const SizedBox.shrink();
    final h = data.cropHealth;
    return CardShell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        StatusBadge(
            label: h.statusLabel,
            color: AppColors.primaryDark,
            bg: AppColors.primaryLight),
        Text('الحالة العامة', style: AppTextStyles.headlineMedium),
      ]),
      const SizedBox(height: 14),
      HealthRing(
          progress: h.overallHealthPercent / 100.0,
          size: 120,
          strokeWidth: 11,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${h.overallHealthPercent}%',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 24)),
            Text('صحي', style: AppTextStyles.caption),
          ])),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _miniStat('${h.healthyCount}', 'سليمة', AppColors.primary),
        _miniStat('${h.warningCount}', 'تحذير', AppColors.warning),
        _miniStat('${h.criticalCount}', 'حرجة', AppColors.error),
      ]),
    ]));
  }

  Widget _miniStat(String val, String label, Color color) => Column(children: [
        Text(val, style: AppTextStyles.headlineMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ]);
}

class _BarChart extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  _BarChart({required this.data, required this.labels});
  @override
  void paint(Canvas canvas, Size size) {
    final bw = size.width / (data.length * 2);
    final maxH = size.height - 22;
    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / data.length) + bw / 2;
      final h = data[i] * maxH;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, maxH - h, bw, h), const Radius.circular(5)),
          Paint()
            ..color = i == 6
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.25));
      final tp = TextPainter(
          text: TextSpan(
              text: labels[i],
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          textDirection: TextDirection.rtl);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2 + bw / 2, maxH + 4));
    }
  }

  @override
  bool shouldRepaint(_BarChart o) => false;
}
