import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';
import 'disease_history_page.dart';
import 'growth_timeline_page.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class CropHealthDetailPage extends StatelessWidget {
  final RemoteCrop crop;
  const CropHealthDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.share_outlined,
                      size: 22, color: AppColors.txtSec(context))),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(lang, 'تفاصيل صحة المحصول', 'Santé de la culture'),
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppColors.surfAlt(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.bord(context))),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: 15, color: AppColors.txtSec(context)))),
            ]),
            const SizedBox(height: 12),

            // Feature 1: Growth timeline quick-access chip
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => GrowthTimelinePage(crop: crop))),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.timeline_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _t(lang, 'مراحل النمو', 'Stades de croissance'),
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // NDVI heatmap card — dynamic, driven by the crop's computed NDVI value
            CardShell(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                StatusBadge(
                    label: _t(lang, 'تقدير بالموقع', 'Estimé par position'),
                    color: AppColors.primaryDark,
                    bg: AppColors.primaryLight),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                      _t(lang, 'حيوية الحقل (NDVI)',
                          'Vitalité du champ (NDVI)'),
                      style: AppTextStyles.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end),
                ),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _NdviHeatmap(ndvi: crop.ndvi, height: 160)),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _NdviHeatmap.colorForNdvi(crop.ndvi).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _NdviHeatmap.colorForNdvi(crop.ndvi).withOpacity(0.4)),
                  ),
                  child: Text(
                    'NDVI: ${crop.ndvi.toStringAsFixed(3)}',
                    style: AppTextStyles.caption.copyWith(
                      color: _NdviHeatmap.colorForNdvi(crop.ndvi),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                _legendDot(const Color(0xFFD73027),
                    _t(lang, 'جرداء', 'Faible'), context),
                const SizedBox(width: 8),
                _legendDot(const Color(0xFFFFD700),
                    _t(lang, 'متوسطة', 'Moyen'), context),
                const SizedBox(width: 8),
                _legendDot(const Color(0xFF1A9641),
                    _t(lang, 'كثيفة', 'Dense'), context),
              ]),
            ])),
            const SizedBox(height: 14),

            // Vitals row
            Row(children: [
              Expanded(
                  child: CardShell(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        const Icon(Icons.water_drop_outlined,
                            size: 22, color: AppColors.info),
                        const SizedBox(height: 6),
                        Text('${crop.humidity.toInt()}%',
                            style: AppTextStyles.headlineMedium),
                        Text(_t(lang, 'الرطوبة', 'Humidité'),
                            style: AppTextStyles.caption),
                        Text('NDVI: ${crop.ndvi.toStringAsFixed(2)}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary)),
                      ]))),
              const SizedBox(width: 12),
              Expanded(
                  child: CardShell(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        const Icon(Icons.thermostat_rounded,
                            size: 22, color: AppColors.orange),
                        const SizedBox(height: 6),
                        Text('${crop.temp.toInt()}°م',
                            style: AppTextStyles.headlineMedium),
                        Text(_t(lang, 'درجة الحرارة', 'Température'),
                            style: AppTextStyles.caption),
                        Text('اليوم ${crop.growthDay}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.orange)),
                      ]))),
            ]),
            const SizedBox(height: 14),

            // Growth stage bar
            CardShell(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
              Text(_t(lang, 'مرحلة النمو', 'Stade de croissance'),
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 6),
              Text('النمو الخضري — اليوم ${crop.growthDay}',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 10),
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: (crop.growthDay / 120).clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfAlt(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 8)),
            ])),
            const SizedBox(height: 14),

            // Feature 3: Disease history button
            GreenButton(
              label: _t(lang, 'سجل الأمراض', 'Historique des maladies'),
              icon: Icons.history_rounded,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const DiseaseHistoryPage())),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  /// Small coloured dot + label for the NDVI legend.
  Widget _legendDot(Color color, String label, BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.txtMuted(context))),
      ]);

}

// ── NDVI Heatmap ─────────────────────────────────────────────────────────────
/// Renders a procedural field-like NDVI colour map driven by the actual value.
/// The canvas is divided into a grid of cells; each cell's colour is the NDVI
/// colour with small seeded variation so it looks like a real vegetation map.
class _NdviHeatmap extends StatelessWidget {
  final double ndvi;   // 0.0 – 1.0
  final double height;

  const _NdviHeatmap({required this.ndvi, this.height = 160});

  /// Maps an NDVI value to the standard red–yellow–green colour scale.
  static Color colorForNdvi(double v) {
    final t = v.clamp(0.0, 1.0);
    if (t < 0.2) {
      // Deep red → red
      return Color.lerp(const Color(0xFFA50026), const Color(0xFFD73027), t / 0.2)!;
    } else if (t < 0.4) {
      // Red → orange
      return Color.lerp(const Color(0xFFD73027), const Color(0xFFF46D43), (t - 0.2) / 0.2)!;
    } else if (t < 0.55) {
      // Orange → yellow
      return Color.lerp(const Color(0xFFF46D43), const Color(0xFFFFD700), (t - 0.4) / 0.15)!;
    } else if (t < 0.70) {
      // Yellow → light green
      return Color.lerp(const Color(0xFFFFD700), const Color(0xFFA6D96A), (t - 0.55) / 0.15)!;
    } else if (t < 0.85) {
      // Light green → green
      return Color.lerp(const Color(0xFFA6D96A), const Color(0xFF1A9641), (t - 0.70) / 0.15)!;
    } else {
      // Green → deep green
      return Color.lerp(const Color(0xFF1A9641), const Color(0xFF006837), (t - 0.85) / 0.15)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _NdviPainter(ndvi: ndvi),
      ),
    );
  }
}

class _NdviPainter extends CustomPainter {
  final double ndvi;
  _NdviPainter({required this.ndvi});

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 22;
    const rows = 14;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Deterministic per-cell variation based on grid position
        final seed = (r * 31 + c * 17).toDouble();
        final noise = (((seed * 127.1 + 311.7).remainder(1.0) + 1) % 1.0) - 0.5;
        // Scale variation: ±12 % of the NDVI range
        final cellNdvi = (ndvi + noise * 0.24).clamp(0.0, 1.0);

        final color = _NdviHeatmap.colorForNdvi(cellNdvi);

        // Slight gap between cells for a field-parcel look
        final rect = Rect.fromLTWH(
          c * cellW + 0.8,
          r * cellH + 0.8,
          cellW - 1.6,
          cellH - 1.6,
        );

        canvas.drawRect(rect, Paint()..color = color);
      }
    }

    // Overlay: gradient vignette to give depth
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [Colors.transparent, Colors.black.withOpacity(0.18)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);

    // NDVI value label centred on the map
    final label = 'NDVI  ${ndvi.toStringAsFixed(2)}';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_NdviPainter old) => old.ndvi != ndvi;
}