import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';
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
              _animateTo((data.averageCropHealth / 100.0).clamp(0.0, 1.0));
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
                    _header(),
                    const SizedBox(height: 20),
                    _healthCard(data),
                    const SizedBox(height: 14),
                    if (data != null) _statsCard(data),
                    const SizedBox(height: 14),
                    if (data != null) _alertsInventoryCard(data),
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

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBtn(Icons.notifications_outlined),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              _todayLabel(),
              style: AppTextStyles.caption,
            ),
            Text(
              'مرحباً بك',
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

  String _todayLabel() {
    final now = DateTime.now();
    const days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد'
    ];
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]}';
  }

  Widget _iconBtn(IconData icon) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Center(
            child: Icon(icon, size: 22, color: AppColors.textSecondary)),
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
              label: data != null
                  ? (data.averageCropHealth >= 70
                      ? 'ممتاز'
                      : data.averageCropHealth >= 40
                          ? 'متوسط'
                          : 'يحتاج عناية')
                  : '—',
              color: AppColors.primaryDark,
              bg: AppColors.primaryLight,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('صحة المحاصيل العامة', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 2),
              Text(
                data != null
                    ? 'إجمالي المحاصيل: ${data.totalCrops}'
                    : 'جاري التحميل...',
                style: AppTextStyles.bodySmall,
              ),
            ]),
          ]),
        ]),
      );

  Widget _statsCard(DashboardData data) => CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('ملخص المزرعة', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _StatTile(
                icon: Icons.eco_rounded,
                label: 'المحاصيل',
                value: '${data.totalCrops}',
                color: AppColors.primary,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                icon: Icons.water_drop_rounded,
                label: 'أحداث الري',
                value: '${data.totalIrrigationEvents}',
                color: AppColors.info,
              )),
            ]),
          ],
        ),
      );

  Widget _alertsInventoryCard(DashboardData data) => CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              StatusBadge(
                label: data.unreadAlerts > 0 ? 'تنبيهات جديدة' : 'لا تنبيهات',
                color: data.unreadAlerts > 0
                    ? AppColors.error
                    : AppColors.primaryDark,
                bg: data.unreadAlerts > 0
                    ? const Color(0xFFFEF2F2)
                    : AppColors.primaryLight,
              ),
              Text('التنبيهات والمخزون',
                  style: AppTextStyles.headlineMedium),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _StatTile(
                icon: Icons.notifications_rounded,
                label: 'تنبيهات غير مقروءة',
                value: '${data.unreadAlerts}',
                color: AppColors.error,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                icon: Icons.inventory_2_rounded,
                label: 'مخزون منخفض',
                value: '${data.lowStockItems}',
                color: AppColors.orange,
              )),
            ]),
          ],
        ),
      );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: color),
            ),
            Text(value,
                style: AppTextStyles.headlineLarge
                    .copyWith(color: color, fontSize: 22)),
          ]),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption),
        ]),
      );
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