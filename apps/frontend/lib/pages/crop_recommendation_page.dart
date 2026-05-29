import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tflite_service.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

// ═══════════════════════════════════════════════════════════
//  CropRecommendationPage — Offline TFLite inference UI
// ═══════════════════════════════════════════════════════════

class CropRecommendationPage extends StatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  State<CropRecommendationPage> createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage>
    with SingleTickerProviderStateMixin {
  // ── Service ──────────────────────────────────────────────────
  final _service = TfliteService();
  bool _modelReady = false;
  bool _loading = false;
  String? _result;
  String? _error;

  // ── Input controllers ────────────────────────────────────────
  final _tempCtrl  = TextEditingController();
  final _humCtrl   = TextEditingController();
  final _phCtrl    = TextEditingController();
  final _waterCtrl = TextEditingController();

  // ── Animation ────────────────────────────────────────────────
  late final AnimationController _resultAnim;
  late final Animation<double>   _fadeIn;
  late final Animation<Offset>   _slideIn;

  // ── Crop metadata ─────────────────────────────────────────────
  // Icons used instead of emoji for reliable rendering on all Android devices
  static const _cropMeta = <String, _CropMeta>{
    'blackgram':   _CropMeta('الحبة السوداء',     'Haricot noir',      Icons.grain_rounded,           Color(0xFF4A2C6E)),
    'chickpea':    _CropMeta('الحمص',             'Pois chiche',       Icons.circle_rounded,          Color(0xFFC8860A)),
    'cotton':      _CropMeta('القطن',             'Coton',             Icons.filter_vintage_rounded,  Color(0xFF3B6B47)),
    'jute':        _CropMeta('الجوت',             'Jute',              Icons.grass_rounded,           Color(0xFF6B5B35)),
    'kidneybeans': _CropMeta('الفاصوليا',         'Haricot rouge',     Icons.grain_rounded,           Color(0xFF8B2020)),
    'lentil':      _CropMeta('العدس',             'Lentille',          Icons.grain_rounded,           Color(0xFFA0522D)),
    'maize':       _CropMeta('الذرة',             'Maïs',              Icons.agriculture_rounded,     Color(0xFFB8860B)),
    'mothbeans':   _CropMeta('حبوب الموث',        'Haricot Moth',      Icons.grain_rounded,           Color(0xFF8B7355)),
    'mungbean':    _CropMeta('الفاصوليا الخضراء', 'Haricot mungo',     Icons.eco_rounded,             Color(0xFF2E7D32)),
    'muskmelon':   _CropMeta('الشمام',            'Melon',             Icons.spa_rounded,             Color(0xFFE8A020)),
    'pigeonpeas':  _CropMeta('البازلاء',          "Pois d'Angole",     Icons.energy_savings_leaf_rounded, Color(0xFF5D8A3C)),
    'rice':        _CropMeta('الأرز',             'Riz',               Icons.grass_rounded,           Color(0xFF7D9B6A)),
    'watermelon':  _CropMeta('البطيخ',            'Pastèque',          Icons.circle_rounded,          Color(0xFFD32F2F)),
  };

  @override
  void initState() {
    super.initState();
    _resultAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn  = CurvedAnimation(parent: _resultAnim, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _resultAnim, curve: Curves.easeOutCubic));

    _service.loadModel('crop_recommendation')
        .then((_) => setState(() => _modelReady = true))
        .catchError((e) => setState(() => _error = e.toString()));
  }

  @override
  void dispose() {
    // TfliteService is a singleton — do NOT call _service.dispose() here
    // as it would unload the model for the whole app.
    _resultAnim.dispose();
    _tempCtrl.dispose();
    _humCtrl.dispose();
    _phCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  // ── Inference ─────────────────────────────────────────────────
  Future<void> _predict() async {
    final lang = context.read<SettingsProvider>().settings.language;
    final t = double.tryParse(_tempCtrl.text);
    final h = double.tryParse(_humCtrl.text);
    final p = double.tryParse(_phCtrl.text);
    final w = double.tryParse(_waterCtrl.text);

    if (t == null || h == null || p == null || w == null) {
      setState(() => _error = _t(lang,
          'يرجى إدخال قيم صحيحة في جميع الحقول',
          'Veuillez entrer des valeurs valides dans tous les champs'));
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final crop = _service.predictFromValues(t, h, p, w);
      setState(() { _result = crop; _loading = false; });
      _resultAnim.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = _t(lang, 'حدث خطأ أثناء المعالجة', 'Erreur lors du traitement');
        _loading = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, lang),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _service.loadModel('crop_recommendation')
                      .then((_) => setState(() => _modelReady = true)),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusBanner(ready: _modelReady, lang: lang),
                        const SizedBox(height: 20),
                        _sectionLabel(
                            _t(lang, 'المعطيات البيئية', 'Données environnementales'),
                            context),
                        const SizedBox(height: 12),
                        _InputGrid(
                          tempCtrl:  _tempCtrl,
                          humCtrl:   _humCtrl,
                          phCtrl:    _phCtrl,
                          waterCtrl: _waterCtrl,
                          lang:      lang,
                        ),
                        const SizedBox(height: 24),
                        _PredictButton(
                          ready:   _modelReady,
                          loading: _loading,
                          lang:    lang,
                          onTap:   _predict,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          _ErrorCard(message: _error!),
                        ],
                        if (_result != null) ...[
                          const SizedBox(height: 24),
                          SlideTransition(
                            position: _slideIn,
                            child: FadeTransition(
                              opacity: _fadeIn,
                              child: _ResultCard(
                                cropKey: _result!,
                                lang:    lang,
                                meta: _cropMeta[_result!] ??
                                    _CropMeta(_result!, _result!, Icons.eco_rounded, AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header — matches app's existing page headers ───────────────
  Widget _buildHeader(BuildContext context, String lang) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          border: Border(bottom: BorderSide(color: AppColors.bord(context))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfAlt(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bord(context)),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 20, color: AppColors.txtSec(context)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(lang, 'توصية المحصول', 'Recommandation de culture'),
                    style: AppTextStyles.headlineMedium,
                  ),
                  Text(
                    _t(lang, 'نموذج محلي • بدون إنترنت', 'Modèle local • Sans connexion'),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primLight(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.offline_bolt_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  _t(lang, 'أوفلاين', 'Hors ligne'),
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ]),
            ),
          ],
        ),
      );

  Widget _sectionLabel(String text, BuildContext context) => Row(children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.txtSec(context),
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ]);
}

// ══════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ══════════════════════════════════════════════════════════════

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.ready, required this.lang});
  final bool ready;
  final String lang;

  @override
  Widget build(BuildContext context) {
    String _t(String ar, String fr) => lang == 'fr' ? fr : ar;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ready ? AppColors.primLight(context) : AppColors.surfAlt(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ready
              ? AppColors.primary.withOpacity(0.35)
              : AppColors.bord(context),
        ),
      ),
      child: Row(children: [
        Icon(
          ready ? Icons.offline_bolt_rounded : Icons.hourglass_bottom_rounded,
          size: 18,
          color: ready ? AppColors.primary : AppColors.txtMuted(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ready
                ? _t('النموذج جاهز • العمل بدون إنترنت',
                    'Modèle prêt • Fonctionne sans connexion')
                : _t('جاري تحميل النموذج...', 'Chargement du modèle...'),
            style: AppTextStyles.bodySmall.copyWith(
              color: ready ? AppColors.primary : AppColors.txtMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!ready)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _InputGrid extends StatelessWidget {
  const _InputGrid({
    required this.tempCtrl,
    required this.humCtrl,
    required this.phCtrl,
    required this.waterCtrl,
    required this.lang,
  });

  final TextEditingController tempCtrl;
  final TextEditingController humCtrl;
  final TextEditingController phCtrl;
  final TextEditingController waterCtrl;
  final String lang;

  String _t(String ar, String fr) => lang == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: _InputCard(
            controller: tempCtrl,
            label:      _t('الحرارة', 'Température'),
            unit:       '°C',
            hint:       '15–45',
            icon:       Icons.thermostat_rounded,
            iconColor:  const Color(0xFFE05A2B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InputCard(
            controller: humCtrl,
            label:      _t('الرطوبة', 'Humidité'),
            unit:       '%',
            hint:       '0–100',
            icon:       Icons.water_drop_rounded,
            iconColor:  AppColors.info,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: _InputCard(
            controller: phCtrl,
            label:      _t('الحموضة', 'pH'),
            unit:       'pH',
            hint:       '0–14',
            icon:       Icons.science_rounded,
            iconColor:  const Color(0xFF8E44AD),
            decimal:    true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InputCard(
            controller: waterCtrl,
            label:      _t('الري', 'Précipitations'),
            unit:       'mm',
            hint:       '50–500',
            icon:       Icons.water_rounded,
            iconColor:  const Color(0xFF1ABC9C),
          ),
        ),
      ]),
    ]);
  }
}

// ──────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.label,
    required this.unit,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bord(context)),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: decimal),
                  inputFormatters: [
                    decimal
                        ? FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                        : FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTextStyles.headlineLarge.copyWith(fontSize: 22),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: AppTextStyles.caption,
                  ),
                ),
              ),
              Text(unit,
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _PredictButton extends StatelessWidget {
  const _PredictButton({
    required this.ready,
    required this.loading,
    required this.lang,
    required this.onTap,
  });

  final bool ready;
  final bool loading;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (ready && !loading) ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          disabledForegroundColor: Colors.white.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.eco_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  lang == 'fr'
                      ? 'Recommander une culture'
                      : 'توصية المحصول المناسب',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ]),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard(
      {required this.cropKey, required this.lang, required this.meta});
  final String cropKey;
  final String lang;
  final _CropMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: meta.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: meta.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: meta.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_rounded, size: 14, color: meta.color),
            const SizedBox(width: 4),
            Text(
              lang == 'fr' ? 'Culture recommandée' : 'المحصول الموصى به',
              style: AppTextStyles.caption.copyWith(
                  color: meta.color, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Crop icon — uses Material Icons for reliable rendering on all devices
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: meta.color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(meta.icon, size: 40, color: meta.color),
        ),
        const SizedBox(height: 12),
        Text(
          lang == 'fr' ? meta.nameFr : meta.nameAr,
          style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.txt(context), fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          cropKey.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
              color: meta.color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 1),
        ),
        const SizedBox(height: 20),

        // Privacy note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primLight(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_rounded,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              lang == 'fr'
                  ? 'Analyse locale • Données non transmises'
                  : 'تم التحليل محلياً • لم تُرسل بياناتك',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.error, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════

class _CropMeta {
  const _CropMeta(this.nameAr, this.nameFr, this.icon, this.color);
  final String   nameAr;
  final String   nameFr;
  final IconData icon;
  final Color    color;
}