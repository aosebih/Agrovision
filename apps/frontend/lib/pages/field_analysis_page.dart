import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';

class FieldAnalysisPage extends StatelessWidget {
  final RemoteCrop crop;
  const FieldAnalysisPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: GreenButton(label: '+ تسجيل ملاحظة', onTap: () {}),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              // Header
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
                  Text(crop.fieldName, style: AppTextStyles.caption),
                  Row(children: [
                    if (crop.health > 0.85)
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(crop.name, style: AppTextStyles.titleLarge),
                  ]),
                ]),
              ]),
              const SizedBox(height: 6),
              Text(
                  'تحليل يوم ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 18),

              // Health score
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text('مؤشر الصحة',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                              label:
                                  '+${(crop.health * 2.4).toStringAsFixed(1)}%م',
                              color: AppColors.primary,
                              bg: AppColors.primaryLight),
                          Text('${(crop.health * 100).toInt()} %',
                              style: AppTextStyles.headlineLarge.copyWith(
                                  fontSize: 40, color: AppColors.primary)),
                        ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: crop.health,
                            backgroundColor: AppColors.primaryLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 6)),
                    const SizedBox(height: 8),
                    Text(
                        crop.statusKey == 'healthy'
                            ? 'الظروف ممتازة للنمو الخضري. لم يتم اكتشاف أي تنبيهات.'
                            : 'الحالة تحتاج مراقبة. راجع التنبيهات.',
                        style: AppTextStyles.bodySmall),
                  ])),
              const SizedBox(height: 14),

              // Environment
              Row(children: [
                Expanded(
                    child: CardShell(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('متوسط الرطوبة',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 10),
                              HealthRing(
                                  progress: crop.humidity / 100,
                                  size: 80,
                                  strokeWidth: 8,
                                  child: Text('${crop.humidity.toInt()}%',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(height: 6),
                              Text('الهدف: 40-60%',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textMuted)),
                            ]))),
                const SizedBox(width: 12),
                Expanded(
                    child: CardShell(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('البيئة', style: AppTextStyles.caption),
                              const SizedBox(height: 10),
                              _envRow(
                                  Icons.thermostat_rounded,
                                  AppColors.orange,
                                  '${crop.temp.toInt()}°م',
                                  'درجة الحرارة'),
                              const SizedBox(height: 8),
                              _envRow(Icons.grid_3x3_rounded, AppColors.info,
                                  crop.ndvi.toStringAsFixed(2), 'مؤشر NDVI'),
                            ]))),
              ]),
              const SizedBox(height: 14),

              // Growth timeline
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                              label: 'اليوم ${crop.growthDay}',
                              color: AppColors.primaryDark,
                              bg: AppColors.primaryLight),
                          Text('مرحلة النمو',
                              style: AppTextStyles.headlineMedium),
                        ]),
                    const SizedBox(height: 16),
                    _growthTimeline(),
                  ])),
              const SizedBox(height: 14),

              // Trend chart
              CardShell(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.fullscreen_rounded,
                                  size: 18, color: AppColors.textMuted)),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('اتجاهات الصحة — 30 يوماً',
                                    style: AppTextStyles.headlineMedium),
                                Text('نظرة عامة على أداء المحصول',
                                    style: AppTextStyles.caption),
                              ]),
                        ]),
                    const SizedBox(height: 14),
                    SizedBox(
                        height: 120,
                        child: CustomPaint(
                            size: const Size(double.infinity, 120),
                            painter: _LinePainter(health: crop.health))),
                    const SizedBox(height: 6),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          '1 أكتوبر',
                          '8 أكتوبر',
                          '15 أكتوبر',
                          '22 أكتوبر',
                          'اليوم'
                        ]
                            .map((l) => Text(l, style: AppTextStyles.caption))
                            .toList()),
                  ])),
              const SizedBox(height: 80),
            ]),
          )),
        ),
      );

  Widget _envRow(IconData icon, Color color, String val, String label) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(val,
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        Row(children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(width: 6),
          Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: color))
        ]),
      ]);

  Widget _growthTimeline() {
    const stages = ['الإنبات', 'النمو الخضري', 'التزهير', 'الحصاد'];
    const current = 1;
    return Row(
        children: List.generate(stages.length, (i) {
      final done = i < current;
      final active = i == current;
      return Expanded(
          child: Row(children: [
        Expanded(
            child: Column(children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color:
                      done || active ? AppColors.primary : AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: 2)),
              child: active
                  ? const Icon(Icons.circle, size: 10, color: Colors.white)
                  : done
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null),
          const SizedBox(height: 4),
          Text(stages[i],
              style: AppTextStyles.caption.copyWith(
                  color: active ? AppColors.primary : AppColors.textMuted,
                  fontSize: 10),
              textAlign: TextAlign.center),
        ])),
        if (i < stages.length - 1)
          Expanded(
              child: Container(
                  height: 2,
                  color: i < current ? AppColors.primary : AppColors.border)),
      ]));
    }));
  }
}

class _LinePainter extends CustomPainter {
  final double health;
  _LinePainter({required this.health});
  @override
  void paint(Canvas canvas, Size size) {
    // Simulate trend curve ending at current health value
    final pts = [0.8, 0.7, 0.75, 0.6, 0.5, 0.65, 0.55, 0.4, 0.45, health];
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i / (pts.length - 1) * size.width;
      final y = (1 - pts[i]) * (size.height - 4);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(colors: [
            AppColors.primary.withOpacity(0.25),
            Colors.transparent
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    for (int i = 0; i < pts.length; i++) {
      final x = i / (pts.length - 1) * size.width;
      final y = (1 - pts[i]) * (size.height - 4);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.primary);
      canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.health != health;
}
