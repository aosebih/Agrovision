import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class FarmMapPage extends StatefulWidget {
  const FarmMapPage({super.key});
  @override
  State<FarmMapPage> createState() => _FarmMapPageState();
}

class _FarmMapPageState extends State<FarmMapPage> {
  int _selLayer = 0;

  List<String> _layers(String lang) => ['NDVI', _t(lang, 'الرطوبة', 'Humidité'), _t(lang, 'تربة', 'Sol')];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Stack(children: [
          ClipRect(
            child: Image.asset(
              'lib/compenent/images/Satellite view of agricultural fields from above.png',
              width: double.infinity, height: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2D6A4F)),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, height: 120,
            child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCC000000), Colors.transparent]))),
          ),
          Positioned(top: 0, left: 0, right: 0, child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.menu_rounded, size: 20, color: Colors.white)),
              Text(_t(lang, 'خريطة المزرعة التفاعلية', 'Carte interactive de la ferme'), style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search_rounded, size: 20, color: Colors.white)),
            ]),
          )),
          Positioned(top: 70, left: 0, right: 0, child: Center(child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10)]),
            child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(_layers(lang).length, (i) {
              final sel = i == _selLayer;
              return GestureDetector(
                onTap: () => setState(() => _selLayer = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(26)),
                  child: Text(_layers(lang)[i], style: AppTextStyles.bodySmall.copyWith(color: sel ? Colors.white : AppColors.txtSec(context), fontWeight: FontWeight.w600)),
                ),
              );
            })),
          ))),
          Positioned.fill(child: CustomPaint(painter: _FieldPainter())),
          Positioned(bottom: 120, left: 20, child: Column(children: [
            _mapBtn(Icons.add_rounded, () {}),
            const SizedBox(height: 8),
            _mapBtn(Icons.remove_rounded, () {}),
            const SizedBox(height: 8),
            _mapBtn(Icons.my_location_rounded, () {}),
          ])),
          Positioned(bottom: 20, left: 20, right: 20, child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12)]),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _legendItem(AppColors.primary, _t(lang, 'حالة ممتازة', 'Excellent')),
              _legendItem(AppColors.warning, _t(lang, 'يحتاج انتباه', 'Attention requise')),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6)]),
      child: Icon(icon, size: 20, color: AppColors.txtSec(context)),
    ),
  );

  Widget _legendItem(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: AppTextStyles.bodySmall),
  ]);
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.25)..style = PaintingStyle.fill;
    final greenBorder = Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final yellowPaint = Paint()..color = AppColors.warning.withValues(alpha: 0.2)..style = PaintingStyle.fill;
    final yellowBorder = Paint()..color = AppColors.warning..style = PaintingStyle.stroke..strokeWidth = 2.5;

    final f1 = Path()
      ..moveTo(size.width * 0.12, size.height * 0.22)
      ..lineTo(size.width * 0.42, size.height * 0.18)
      ..lineTo(size.width * 0.45, size.height * 0.52)
      ..lineTo(size.width * 0.12, size.height * 0.55)
      ..close();
    canvas.drawPath(f1, greenPaint);
    canvas.drawPath(f1, greenBorder);

    final f2 = Path()
      ..moveTo(size.width * 0.38, size.height * 0.16)
      ..lineTo(size.width * 0.72, size.height * 0.20)
      ..lineTo(size.width * 0.68, size.height * 0.50)
      ..lineTo(size.width * 0.40, size.height * 0.46)
      ..close();
    canvas.drawPath(f2, yellowPaint);
    canvas.drawPath(f2, yellowBorder);

    final f3 = Path()
      ..moveTo(size.width * 0.10, size.height * 0.57)
      ..lineTo(size.width * 0.45, size.height * 0.55)
      ..lineTo(size.width * 0.44, size.height * 0.80)
      ..lineTo(size.width * 0.10, size.height * 0.78)
      ..close();
    canvas.drawPath(f3, greenPaint);
    canvas.drawPath(f3, greenBorder);

    _drawLabel(canvas, 'قطاع 1', size.width * 0.24, size.height * 0.36);
    _drawLabel(canvas, 'قطاع 2', size.width * 0.54, size.height * 0.33);
    _drawLabel(canvas, 'قطاع 3', size.width * 0.25, size.height * 0.67);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 4)])),
      textDirection: TextDirection.rtl,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(_FieldPainter o) => false;
}
