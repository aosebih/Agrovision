import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';
import 'inventory_detail_page.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _selDay = 0;
  double _lastHealth = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = Tween<double>(begin: 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Load dashboard on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  void _animateTo(double target) {
    if ((target - _lastHealth).abs() < 0.01) return;
    _lastHealth = target;
    _anim = Tween<double>(begin: 0.0, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.data == null) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (provider.state == LoadState.error && provider.data == null) {
              return _errorView(provider);
            }
            final data = provider.data;
            if (data != null) {
              _animateTo(data.cropHealth.overallHealthPercent / 100.0);
            }
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
                    _header(data),
                    const SizedBox(height: 20),
                    _healthCard(data),
                    const SizedBox(height: 14),
                    if (data != null) _weatherCard(data.weather),
                    const SizedBox(height: 14),
                    if (data != null) _storageCard(context, data.storage),
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

  Widget _errorView(DashboardProvider provider) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('تعذّر تحميل البيانات',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(provider.errorMessage ?? '',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GreenButton(
                label: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onTap: () => provider.load()),
          ]),
        ),
      );

  Widget _header(DashboardData? data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBtn(Icons.notifications_outlined, badge: true),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('الإثنين، 24 أكتوبر', style: AppTextStyles.caption),
            Text(
              data != null
                  ? 'صباح الخير، ${data.cropHealth.statusLabel}'
                  : 'صباح الخير',
              style: AppTextStyles.headlineMedium,
            ),
          ]),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.person_rounded,
                size: 28, color: AppColors.textMuted),
          ),
        ],
      );

  Widget _iconBtn(IconData icon, {bool badge = false}) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Stack(children: [
          Center(child: Icon(icon, size: 22, color: AppColors.textSecondary)),
          if (badge)
            Positioned(
                top: 9,
                right: 9,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle))),
        ]),
      );

  Widget _healthCard(DashboardData? data) => CardShell(
        child: Column(children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _RingPainter(progress: _anim.value),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      '${(_anim.value * 100).toInt()}%',
                      style: AppTextStyles.bigPercent,
                    ),
                    Text('سليم', style: AppTextStyles.bodySmall),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            StatusBadge(
              label: data?.cropHealth.statusLabel ?? '—',
              color: AppColors.primaryDark,
              bg: AppColors.primaryLight,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('صحة المحاصيل العامة', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 2),
              Text(
                data != null
                    ? 'حقول صحية: ${data.cropHealth.healthyCount} من ${data.cropHealth.totalFields}'
                    : 'جاري التحميل...',
                style: AppTextStyles.bodySmall,
              ),
            ]),
          ]),
        ]),
      );

  Widget _weatherCard(WeatherData weather) {
    final conditionIcons = {
      'sunny': Icons.wb_sunny_rounded,
      'cloudy': Icons.cloud_rounded,
      'partly_cloudy': Icons.wb_cloudy_rounded,
      'rainy': Icons.grain_rounded,
    };
    final conditionColors = {
      'sunny': const Color(0xFFF59E0B),
      'cloudy': const Color(0xFF94A3B8),
      'partly_cloudy': const Color(0xFF94A3B8),
      'rainy': AppColors.info,
    };

    return CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.location_on_rounded,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(weather.location, style: AppTextStyles.bodySmall),
          ]),
          Text('توقعات الطقس', style: AppTextStyles.headlineMedium),
        ]),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weather.days.length, (i) {
            final d = weather.days[i];
            final sel = i == _selDay;
            return GestureDetector(
              onTap: () => setState(() => _selDay = i),
              child: Column(children: [
                Text(d.label,
                    style: AppTextStyles.labelSmall.copyWith(
                        color:
                            sel ? AppColors.textPrimary : AppColors.textMuted,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                const SizedBox(height: 5),
                Icon(
                  conditionIcons[d.condition] ?? Icons.wb_sunny_rounded,
                  size: 22,
                  color:
                      conditionColors[d.condition] ?? const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: sel ? 18 : 0,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ]),
            );
          }),
        ),
        const SizedBox(height: 14),
        Row(
            children: weather.todayHours.map((h) {
          final first = weather.todayHours.first == h;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: first ? AppColors.primaryLight : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: first
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3))
                    : null,
              ),
              child: Column(children: [
                Text('${h.temp}°م',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          first ? AppColors.primaryDark : AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(h.time, style: AppTextStyles.caption),
              ]),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _storageCard(BuildContext context, List<RemoteStorageItem> storage) {
    return CardShell(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // ignore: prefer_const_constructors
          StatusBadge(
            label: 'تنبيهات المخزون',
            color: AppColors.orange,
            bg: AppColors.orangeLight,
          ),
          Row(children: [
            Text('حالة المخزون', style: AppTextStyles.headlineMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 17, color: AppColors.orange),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        ...storage.take(2).map((item) {
          final isLow = item.status == 'low';
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => InventoryDetailPage(item: item)),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: isLow ? 'مخزون منخفض' : 'متوفر',
                      color: isLow ? AppColors.error : AppColors.primaryDark,
                      bg: isLow
                          ? const Color(0xFFFEF2F2)
                          : AppColors.primaryLight,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(item.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(item.lastUpdatedLabel,
                              style: AppTextStyles.caption),
                        ]),
                  ]),
            ),
          );
        }),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 14) / 2;
    final p = Paint()
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    p.color = AppColors.primaryLight;
    canvas.drawCircle(c, r, p);
    p.color = AppColors.primary;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2,
        2 * math.pi * progress, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}
