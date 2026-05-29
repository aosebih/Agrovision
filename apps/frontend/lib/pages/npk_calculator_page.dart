import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/settings_provider.dart';

class NpkCalculatorPage extends StatefulWidget {
  const NpkCalculatorPage({super.key});
  @override
  State<NpkCalculatorPage> createState() => _NpkCalculatorPageState();
}

class _NpkCalculatorPageState extends State<NpkCalculatorPage> {
  String _selectedCrop = 'قمح';
  final _areaCtrl = TextEditingController(text: '1');
  Map<String, double>? _result;

  static const _crops = [
    'قمح','ذرة','فول الصويا','أرز','شعير',
    'طماطم','بطاطس','بصل','ثوم','فلفل','خيار','باذنجان',
  ];

  static const Map<String, Map<String, double>> _npkRates = {
    'قمح':        {'N': 120, 'P': 60,  'K': 40},
    'ذرة':        {'N': 180, 'P': 80,  'K': 80},
    'فول الصويا': {'N': 30,  'P': 60,  'K': 60},
    'أرز':        {'N': 100, 'P': 50,  'K': 40},
    'شعير':       {'N': 100, 'P': 50,  'K': 30},
    'طماطم':      {'N': 150, 'P': 100, 'K': 200},
    'بطاطس':      {'N': 200, 'P': 100, 'K': 300},
    'بصل':        {'N': 120, 'P': 60,  'K': 80},
    'ثوم':        {'N': 80,  'P': 60,  'K': 80},
    'فلفل':       {'N': 120, 'P': 60,  'K': 150},
    'خيار':       {'N': 120, 'P': 80,  'K': 150},
    'باذنجان':    {'N': 140, 'P': 80,  'K': 160},
  };

  String _t(String ar, String fr) =>
      context.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text.trim()) ?? 1.0;
    final rates = _npkRates[_selectedCrop] ?? {'N': 100.0, 'P': 60.0, 'K': 60.0};
    setState(() => _result = {
      'N': rates['N']! * area,
      'P': rates['P']! * area,
      'K': rates['K']! * area,
    });
  }

  @override
  void dispose() { _areaCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: context.watch<SettingsProvider>().settings.language == 'fr'
        ? TextDirection.ltr : TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.bord(context))),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.txtSec(context)),
                ),
              ),
              Text(_t('حاسبة NPK', 'Calculateur NPK'),
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.txt(context))),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.primLight(context), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.science_rounded, size: 20, color: AppColors.primary),
              ),
            ]),
            const SizedBox(height: 20),
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.blLight(context), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withOpacity(0.3))),
              child: Row(children: [
                Expanded(child: Text(
                  _t('أدخل نوع المحصول والمساحة لحساب كميات N-P-K المثالية',
                     'Entrez le type de culture et la superficie pour calculer les quantités N-P-K'),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.info))),
                SizedBox(width: 8),
                const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
              ]),
            ),
            const SizedBox(height: 20),
            // Crop dropdown
            Text(_t('نوع المحصول', 'Type de culture'),
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: AppColors.surf(context),
                  borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.bord(context))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCrop, isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: AppColors.surf(context),
                  items: _crops.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.txt(context))),
                  )).toList(),
                  onChanged: (v) { if (v != null) setState(() { _selectedCrop = v; _result = null; }); },
                ),
              ),
            ),
            SizedBox(height: 16),
            // Area input
            Text(_t('المساحة (هكتار)', 'Superficie (hectares)'),
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: AppColors.surf(context),
                  borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.bord(context))),
              child: TextField(
                controller: _areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.txt(context)),
                decoration: InputDecoration(
                  hintText: '1.0',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context)),
                  prefixIcon: Icon(Icons.crop_square_rounded, size: 18, color: AppColors.txtMuted(context)),
                  suffixText: _t('هكتار', 'ha'),
                  suffixStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                ),
                onChanged: (_) => setState(() => _result = null),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(width: double.infinity,
                child: GreenButton(label: _t('احسب الكميات', 'Calculer les quantités'), onTap: _calculate)),
            const SizedBox(height: 24),
            // Results
            if (_result != null) ...[
              Text(_t('الكميات الموصى بها', 'Quantités recommandées'),
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
              SizedBox(height: 12),
              Row(children: [
                _npkBubble(context, 'N', _t('نيتروجين', 'Azote'),     _result!['N']!, AppColors.info,    AppColors.blLight(context)),
                SizedBox(width: 10),
                _npkBubble(context, 'P', _t('فسفور', 'Phosphore'),     _result!['P']!, AppColors.primary, AppColors.primLight(context)),
                SizedBox(width: 10),
                _npkBubble(context, 'K', _t('بوتاسيوم', 'Potassium'), _result!['K']!, AppColors.warning, AppColors.orgLight(context)),
              ]),
              SizedBox(height: 16),
              CardShell(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_t('توصيات التطبيق', "Recommandations d'application"),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.txt(context), fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _rec(context, _t('مرحلة الإنبات', 'Germination'),   '30% N + 50% P + 50% K'),
                _rec(context, _t('مرحلة النمو',   'Croissance'),    '50% N + 50% P + 50% K'),
                _rec(context, _t('مرحلة الإزهار', 'Floraison'),     '20% N + 0% P + 0% K'),
              ])),
            ],
            const SizedBox(height: 80),
          ]),
        ),
      ),
    ),
  );

  Widget _npkBubble(BuildContext context, String sym, String name,
      double qty, Color color, Color bg) =>
      Expanded(child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(children: [
          Text(sym, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 6),
          Text('${qty.toStringAsFixed(0)} kg',
              style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(name, style: AppTextStyles.caption.copyWith(color: AppColors.txtSec(context)),
              textAlign: TextAlign.center),
        ]),
      ));

  Widget _rec(BuildContext context, String stage, String doses) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(doses, style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
          Text(stage, style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtSec(context))),
        ],
      ));
}
