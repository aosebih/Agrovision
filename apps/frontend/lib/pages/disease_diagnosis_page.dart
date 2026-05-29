import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/analysis_result.dart';
import '../providers/analysis_provider.dart';
import '../providers/fields_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class DiseaseDiagnosisPage extends StatefulWidget {
  final AnalysisResult result;
  final String lang;

  const DiseaseDiagnosisPage(
      {super.key, required this.result, this.lang = 'ar'});

  @override
  State<DiseaseDiagnosisPage> createState() => _DiseaseDiagnosisPageState();
}

class _DiseaseDiagnosisPageState extends State<DiseaseDiagnosisPage> {
  late AnalysisResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    // Pre-load fields in background so the picker is instant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fp = context.read<FieldsProvider>();
      if (fp.fields.isEmpty && !fp.isLoading) fp.load();
    });
  }

  String get _lang => widget.lang;

  // ── Save: show field picker, then persist and pop ─────────────────────────
  Future<void> _onSave(BuildContext context) async {
    final fp = context.read<FieldsProvider>();
    if (fp.isLoading) {
      // wait briefly
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!context.mounted) return;

    final picked = await showModalBottomSheet<_FieldChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FieldPickerSheet(
        fields: fp.fields,
        lang: _lang,
        currentFieldId: _result.fieldId,
      ),
    );

    if (!context.mounted) return;

    // null → dismissed (do nothing, keep existing attribution)
    if (picked != null) {
      await context.read<AnalysisProvider>().updateFieldAttribution(
            _result.id,
            picked.fieldId,
            picked.fieldName,
          );
      setState(() {
        _result = _result.copyWith(
          fieldId: picked.fieldId,
          fieldName: picked.fieldName,
        );
      });
    }

    if (context.mounted) Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.bg(context),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(children: [
              Expanded(
                child: GreenButton(
                  label: _t(_lang,
                    _result.isHealthy ? 'حفظ التقرير' : '✓ تطابق المعالجة',
                    _result.isHealthy ? 'Enregistrer' : '✓ Confirmer'),
                  icon: _result.isHealthy
                      ? Icons.save_outlined
                      : Icons.check_rounded,
                  onTap: () => _onSave(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GreenButton(
                  label: _t(_lang, 'تحليل جديد', 'Nouvelle analyse'),
                  onTap: () => Navigator.pop(context),
                  outlined: true,
                ),
              ),
            ]),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // Header
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfAlt(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.bord(context)),
                      ),
                      child: Icon(
                        _lang == 'fr'
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: AppColors.txtSec(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _t(_lang, 'نتيجة التشخيص', 'Résultat du diagnostic'),
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.share_outlined,
                        size: 22, color: AppColors.txtSec(context)),
                  ),
                ]),
                const SizedBox(height: 20),

                _heroCard(context),
                const SizedBox(height: 16),
                _metaCard(context),
                const SizedBox(height: 14),

                if (!_result.isHealthy &&
                    _result.descForLang(_lang) != null) ...[
                  _descCard(context),
                  const SizedBox(height: 14),
                ],
                if (!_result.isHealthy &&
                    _result.treatForLang(_lang) != null) ...[
                  _treatmentCard(context),
                  const SizedBox(height: 14),
                ],
                if (_result.isHealthy) _healthyCard(context),

                const SizedBox(height: 14),
                _probabilitiesCard(context),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ),
      );

  // ── Cards ─────────────────────────────────────────────────────────────────

  Widget _heroCard(BuildContext context) {
    final color =
        _result.isHealthy ? AppColors.primary : AppColors.error;
    final bg = _result.isHealthy
        ? AppColors.primaryLight
        : const Color(0xFFFEF2F2);
    final icon =
        _result.isHealthy ? Icons.eco_rounded : Icons.bug_report_outlined;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bord(context)),
      ),
      child: Column(children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 14),
        Text(
          _result.isHealthy
              ? _t(_lang, 'النبات سليم', 'Plante saine')
              : _result.nameForLang(_lang),
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        if (!_result.isHealthy && _result.severity != 'none')
          StatusBadge(
            label: _t(_lang,
                'الشدة: ${_severityLabel(_result.severity)}',
                'Sévérité: ${_severityLabelFr(_result.severity)}'),
            color: _severityColor(_result.severity),
            bg: _severityBg(_result.severity),
          ),
        if (_result.isHealthy)
          StatusBadge(
            label:
                _t(_lang, '✓ لم يتم اكتشاف أمراض', '✓ Aucune maladie détectée'),
            color: AppColors.primaryDark,
            bg: AppColors.primaryLight,
          ),
      ]),
    );
  }

  Widget _metaCard(BuildContext context) => CardShell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_t(_lang, 'تفاصيل التحليل', 'Détails de l\'analyse'),
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 14),
          _metaRow(context, _t(_lang, 'الثقة', 'Confiance'),
              '${_result.confidencePercent}%'),
          const Divider(height: 20),
          _metaRow(context, _t(_lang, 'المحصول', 'Culture'),
              _result.cropKey[0].toUpperCase() + _result.cropKey.substring(1)),
          const Divider(height: 20),
          // ── Field attribution row ──────────────────────────────────────────
          _fieldAttributionRow(context),
          const Divider(height: 20),
          _metaRow(context, _t(_lang, 'معرف التحليل', 'ID analyse'),
              _result.id.substring(0, 8).toUpperCase()),
          const Divider(height: 20),
          _metaRow(context, _t(_lang, 'التوقيت', 'Horodatage'),
              _formatTimestamp(_result.timestamp)),
          const SizedBox(height: 14),
          Text(_t(_lang, 'مستوى الثقة', 'Niveau de confiance'),
              style: AppTextStyles.caption),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _result.confidence,
              backgroundColor: AppColors.surfAlt(context),
              valueColor: AlwaysStoppedAnimation<Color>(_result.isHealthy
                  ? AppColors.primary
                  : AppColors.error),
              minHeight: 8,
            ),
          ),
        ]),
      );

  /// The field attribution row — shows current field or a prompt to assign one.
  Widget _fieldAttributionRow(BuildContext context) {
    final hasField = _result.fieldId != null && _result.fieldName != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _t(_lang, 'الحقل', 'Parcelle'),
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.txtMuted(context)),
        ),
        GestureDetector(
          onTap: () => _pickField(context),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (hasField) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result.fieldName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              Text(
                _t(_lang, 'تعيين حقل', 'Assigner'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
          ]),
        ),
      ],
    );
  }

  /// Opens the field picker without closing the page afterward.
  Future<void> _pickField(BuildContext context) async {
    final fp = context.read<FieldsProvider>();
    if (fp.fields.isEmpty && !fp.isLoading) await fp.load();
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<_FieldChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FieldPickerSheet(
        fields: fp.fields,
        lang: _lang,
        currentFieldId: _result.fieldId,
      ),
    );

    if (picked != null && context.mounted) {
      await context.read<AnalysisProvider>().updateFieldAttribution(
            _result.id,
            picked.fieldId,
            picked.fieldName,
          );
      setState(() {
        _result = _result.copyWith(
          fieldId: picked.fieldId,
          fieldName: picked.fieldName,
        );
      });
    }
  }

  Widget _metaRow(BuildContext context, String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.txtMuted(context))),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.txt(context), fontWeight: FontWeight.w600)),
      ]);

  Widget _descCard(BuildContext context) => CardShell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.description_outlined,
                size: 18, color: AppColors.txtMuted(context)),
            const SizedBox(width: 8),
            Text(_t(_lang, 'الوصف', 'Description'),
                style: AppTextStyles.headlineMedium),
          ]),
          const SizedBox(height: 10),
          Text(_result.descForLang(_lang)!, style: AppTextStyles.bodySmall),
        ]),
      );

  Widget _treatmentCard(BuildContext context) => CardShell(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.medical_services_outlined,
                size: 18, color: AppColors.txtMuted(context)),
            const SizedBox(width: 8),
            Text(_t(_lang, 'المعالجة الموصى بها', 'Traitement recommandé'),
                style: AppTextStyles.headlineMedium),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfAlt(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(_result.treatForLang(_lang)!,
                      style: AppTextStyles.bodySmall)),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_pharmacy_outlined,
                    size: 18, color: AppColors.primaryDark),
              ),
            ]),
          ),
          if (_result.severity == 'severe') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t(_lang,
                        '⚠ يطلب إجراء فوري لمنع الانتشار',
                        '⚠ Intervention immédiate requise'),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          ],
        ]),
      );

  Widget _healthyCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primLight(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                _t(_lang, 'النبات في حالة صحية ممتازة',
                    'La plante est en excellente santé'),
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                _t(_lang,
                    'استمر في برنامج العناية الحالي. راجع كل أسبوع.',
                    'Continuez le programme d\'entretien actuel.'),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primaryDark),
              ),
            ]),
          ),
        ]),
      );

  Widget _probabilitiesCard(BuildContext context) {
    final probs = _result.probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
            _t(_lang, 'توزيع الاحتمالات',
                'Distribution des probabilités'),
            style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        ...probs.map((e) {
          final pct = (e.value * 100).toStringAsFixed(1);
          final isTop = e.key == _result.label;
          final nameFr = _classDisplayNameLang(e.key, 'fr');
          final nameAr = _classDisplayNameLang(e.key, 'ar');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$pct%',
                    style: AppTextStyles.caption.copyWith(
                        fontWeight:
                            isTop ? FontWeight.w700 : FontWeight.normal,
                        color: isTop
                            ? AppColors.txt(context)
                            : AppColors.txtMuted(context))),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(nameFr,
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: isTop
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isTop
                                  ? AppColors.txt(context)
                                  : AppColors.txtMuted(context)),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis),
                      Text(nameAr,
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: isTop
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isTop
                                  ? AppColors.txt(context).withOpacity(0.75)
                                  : AppColors.txtMuted(context)
                                      .withOpacity(0.6),
                              fontSize: 10),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: e.value,
                  backgroundColor: AppColors.surfAlt(context),
                  valueColor: AlwaysStoppedAnimation<Color>(isTop
                      ? (_result.isHealthy
                          ? AppColors.primary
                          : AppColors.error)
                      : AppColors.txtMuted(context).withOpacity(0.4)),
                  minHeight: 6,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _classDisplayNameLang(String key, String lang) {
    const Map<String, Map<String, String>> names = {
      'angular_leaf_spot':       {'ar': 'تبقع الأوراق الزاوي',       'fr': 'Tache angulaire'},
      'bean_rust':               {'ar': 'صدأ الفاصولياء',             'fr': 'Rouille du haricot'},
      'Apple___Apple_scab':      {'ar': 'جرب التفاح',                 'fr': 'Tavelure du pommier'},
      'Apple___Black_rot':       {'ar': 'العفن الأسود للتفاح',        'fr': 'Pourriture noire'},
      'Apple___Cedar_apple_rust':{'ar': 'صدأ أرز التفاح',             'fr': 'Rouille cèdre-pommier'},
      'Cherry___Powdery_mildew': {'ar': 'البياض الدقيقي للكرز',       'fr': 'Oïdium du cerisier'},
      'Corn___Cercospora_leaf_spot_Gray_leaf_spot': {'ar': 'تبقع الأوراق الرمادي', 'fr': 'Tache grise du maïs'},
      'Corn___Common_rust':      {'ar': 'الصدأ الشائع للذرة',         'fr': 'Rouille commune du maïs'},
      'Corn___Northern_Leaf_Blight': {'ar': 'اللفحة الشمالية للذرة', 'fr': 'Brûlure nordique du maïs'},
      'Grape___Black_rot':       {'ar': 'العفن الأسود للعنب',         'fr': 'Black rot de la vigne'},
      'Grape___Esca_(Black_Measles)': {'ar': 'الإسكا (الحصبة السوداء)', 'fr': 'Esca (black measles)'},
      'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': {'ar': 'لفحة أوراق العنب', 'fr': 'Brûlure foliaire de la vigne'},
      'Ascochyta_blight':        {'ar': 'لفحة الأسكوكيتا',            'fr': 'Anthracnose à Ascochyta'},
      'rust':                    {'ar': 'الصدأ',                      'fr': 'Rouille'},
      'Peach___Bacterial_spot':  {'ar': 'التبقع البكتيري للخوخ',      'fr': 'Tache bactérienne du pêcher'},
      'Pepper___Bacterial_spot': {'ar': 'التبقع البكتيري للفلفل',     'fr': 'Tache bactérienne du poivron'},
      'Potato___Early_blight':   {'ar': 'اللفحة المبكرة للبطاطا',     'fr': 'Alternariose de la pomme de terre'},
      'Potato___Late_blight':    {'ar': 'اللفحة المتأخرة للبطاطا',    'fr': 'Mildiou de la pomme de terre'},
      'Strawberry___Leaf_scorch':{'ar': 'احتراق أوراق الفراولة',      'fr': 'Brûlure foliaire du fraisier'},
      'Tomato___Bacterial_spot': {'ar': 'التبقع البكتيري للطماطم',    'fr': 'Tache bactérienne de la tomate'},
      'Tomato___Early_blight':   {'ar': 'اللفحة المبكرة للطماطم',     'fr': 'Alternariose de la tomate'},
      'Tomato___Late_blight':    {'ar': 'اللفحة المتأخرة للطماطم',    'fr': 'Mildiou de la tomate'},
      'Tomato___Leaf_Mold':      {'ar': 'عفن أوراق الطماطم',          'fr': 'Moisissure foliaire de la tomate'},
      'Tomato___Septoria_leaf_spot': {'ar': 'تبقع سبتوريا',           'fr': 'Septoriose de la tomate'},
      'Tomato___Spider_mites_Two-spotted_spider_mite': {'ar': 'عناكب الطماطم', 'fr': 'Acariens à deux points'},
      'Tomato___Target_Spot':    {'ar': 'تبقع الهدف',                 'fr': 'Tache cible de la tomate'},
      'Tomato___Tomato_Yellow_Leaf_Curl_Virus': {'ar': 'فيروس تجعد الأوراق الأصفر', 'fr': 'TYLCV'},
      'Tomato___Tomato_mosaic_virus': {'ar': 'فيروس فسيفساء الطماطم', 'fr': 'Virus de la mosaïque'},
      'healthy':                 {'ar': 'سليم',                       'fr': 'Sain'},
    };
    final entry = names[key];
    if (entry == null) {
      return key.replaceAll('___', ' – ').replaceAll('_', ' ');
    }
    return entry[lang] ?? entry['ar']!;
  }

  String _severityLabel(String s) => switch (s) {
        'severe' => 'عالية',
        'moderate' => 'متوسطة',
        'low' => 'منخفضة',
        _ => 'لا شيء',
      };

  String _severityLabelFr(String s) => switch (s) {
        'severe' => 'Élevée',
        'moderate' => 'Modérée',
        'low' => 'Faible',
        _ => 'Aucune',
      };

  Color _severityColor(String s) => switch (s) {
        'severe' => AppColors.error,
        'moderate' => AppColors.orange,
        'low' => AppColors.warning,
        _ => AppColors.primary,
      };

  Color _severityBg(String s) => switch (s) {
        'severe' => const Color(0xFFFEF2F2),
        'moderate' => AppColors.orangeLight,
        'low' => const Color(0xFFFFFBEB),
        _ => AppColors.primaryLight,
      };

  String _formatTimestamp(String ts) {
    final dt = DateTime.tryParse(ts);
    if (dt == null) return ts;
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field choice data class
// ─────────────────────────────────────────────────────────────────────────────

class _FieldChoice {
  final String? fieldId;
  final String? fieldName;
  const _FieldChoice({this.fieldId, this.fieldName});
}

// ─────────────────────────────────────────────────────────────────────────────
// Field picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FieldPickerSheet extends StatelessWidget {
  final List<Field> fields;
  final String lang;
  final String? currentFieldId;

  const _FieldPickerSheet({
    required this.fields,
    required this.lang,
    this.currentFieldId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.bord(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(children: [
              Icon(Icons.landscape_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                lang == 'fr'
                    ? 'Attribuer à une parcelle'
                    : 'نسب التحليل إلى حقل',
                style: AppTextStyles.headlineMedium,
              ),
            ]),
          ),

          const Divider(height: 20),

          // No field option
          _fieldTile(
            context,
            icon: Icons.close_rounded,
            iconColor: AppColors.txtMuted(context),
            name: lang == 'fr' ? 'Aucune parcelle' : 'بدون حقل',
            subtitle: lang == 'fr'
                ? 'Retirer l\'attribution'
                : 'إزالة التعيين الحالي',
            isSelected: currentFieldId == null,
            onTap: () => Navigator.pop(
                context, const _FieldChoice(fieldId: null, fieldName: null)),
          ),

          if (fields.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                lang == 'fr'
                    ? 'Aucune parcelle trouvée. Créez-en une depuis l\'écran Parcelles.'
                    : 'لم يتم العثور على حقول. أنشئ حقلاً من شاشة الحقول.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          else
            ...fields.map((f) => _fieldTile(
                  context,
                  icon: Icons.crop_square_rounded,
                  iconColor: AppColors.primary,
                  name: f.name,
                  subtitle: [
                    if (f.location != null && f.location!.isNotEmpty)
                      f.location!,
                    if (f.areaHectares != null)
                      '${f.areaHectares!.toStringAsFixed(1)} ha',
                  ].join(' · '),
                  isSelected: currentFieldId == f.id,
                  onTap: () => Navigator.pop(
                      context,
                      _FieldChoice(fieldId: f.id, fieldName: f.name)),
                )),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ]),
      ),
    );
  }

  Widget _fieldTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String name,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.surfAlt(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 20,
                  color: isSelected ? AppColors.primaryDark : iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.txt(context),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    )),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.txtMuted(context))),
              ]),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  size: 20, color: AppColors.primary),
          ]),
        ),
      );
}
