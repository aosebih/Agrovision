import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../models/remote/crop_model.dart';
import '../providers/settings_provider.dart';

// ── Per-crop default stage profiles ──────────────────────────────────────────
// Each entry is the day (from planting) at which that stage BEGINS.
// The last value acts as the default total cycle length for that crop.
// Stage order: germination, seedling, vegetative, flowering, fruiting, maturity
const Map<String, List<int>> _cropStageDays = {
  // Cereals
  'قمح':          [3,  14,  35,  65,  85, 120],
  'شعير':         [3,  12,  30,  60,  80, 110],
  'ذرة':          [5,  18,  40,  65,  90, 130],
  'أرز':          [5,  20,  45,  75, 100, 140],
  // Legumes
  'فول الصويا':   [5,  15,  35,  60,  85, 120],
  // Vegetables – short cycle
  'طماطم':        [7,  21,  45,  65,  85, 110],
  'خيار':         [4,  14,  28,  45,  60,  80],
  'كوسة':         [4,  14,  28,  45,  60,  75],
  'فلفل':         [7,  25,  50,  75, 100, 130],
  'باذنجان':      [7,  25,  50,  75, 100, 130],
  'بطاطس':        [7,  21,  45,  65,  85, 110],
  'بصل':          [7,  21,  50,  80, 100, 130],
  'ثوم':          [10, 30,  60,  90, 120, 160],
  'جزر':          [7,  21,  45,  65,  85, 110],
  // Melons
  'بطيخ':         [5,  18,  35,  55,  75,  95],
  // Fruits / perennials (season cycle)
  'عنب':          [14, 40,  80, 110, 140, 180],
  'زيتون':        [14, 45,  90, 130, 170, 210],
  'تمر':          [14, 45,  90, 140, 190, 240],
  'ليمون':        [10, 35,  70, 110, 150, 180],
  'برتقال':       [10, 35,  70, 110, 150, 180],
};

// Fallback used when crop name is not in the map
const List<int> _defaultStageDays = [7, 21, 45, 60, 85, 120];

class GrowthTimelinePage extends StatelessWidget {
  final RemoteCrop crop;
  const GrowthTimelinePage({super.key, required this.crop});

  static const _stagesMeta = [
    {'key': 'germination', 'ar': 'الإنبات',      'fr': 'Germination',      'icon': '🌱'},
    {'key': 'seedling',    'ar': 'الشتلة',        'fr': 'Plantule',         'icon': '🌿'},
    {'key': 'vegetative',  'ar': 'النمو الخضري',  'fr': 'Végétatif',        'icon': '🍃'},
    {'key': 'flowering',   'ar': 'الإزهار',       'fr': 'Floraison',        'icon': '🌸'},
    {'key': 'fruiting',    'ar': 'الإثمار',       'fr': 'Fructification',   'icon': '🍅'},
    {'key': 'maturity',    'ar': 'النضج',         'fr': 'Maturité',         'icon': '🌾'},
  ];

  // ── Resolve stage days ───────────────────────────────────────────────────
  // 1. Start from the crop-type defaults (or global fallback).
  // 2. If the user set both plantedDate and expectedHarvestDate, scale every
  //    stage day proportionally so the last stage lands exactly on their
  //    harvest date.
  List<int> get _stageDays {
    final base = _cropStageDays[crop.name] ?? _defaultStageDays;

    // Try to read user-set harvest date
    if (crop.plantedDate != null && crop.expectedHarvestDate != null) {
      try {
        final planted  = DateTime.parse(crop.plantedDate!);
        final harvest  = DateTime.parse(crop.expectedHarvestDate!);
        final userTotal = harvest.difference(planted).inDays;
        if (userTotal > 0) {
          final defaultTotal = base.last.toDouble();
          return base
              .map((d) => ((d / defaultTotal) * userTotal).round())
              .toList();
        }
      } catch (_) {}
    }
    return base;
  }

  int get _totalCycleDays => _stageDays.last;

  int get _elapsed {
    if (crop.plantedDate == null) return 0;
    try {
      return DateTime.now()
          .difference(DateTime.parse(crop.plantedDate!))
          .inDays;
    } catch (_) {
      return 0;
    }
  }

  int get _currentStage {
    final d   = _elapsed;
    final days = _stageDays;
    for (int i = days.length - 1; i >= 0; i--) {
      if (d >= days[i]) return i;
    }
    return 0;
  }

  int get _daysToHarvest {
    // 1. User provided an explicit harvest date — use it directly.
    if (crop.expectedHarvestDate != null) {
      try {
        return DateTime.parse(crop.expectedHarvestDate!)
            .difference(DateTime.now())
            .inDays;
      } catch (_) {}
    }
    // 2. Fall back: plantedDate + default cycle length for this crop type.
    if (crop.plantedDate != null) {
      try {
        final planted     = DateTime.parse(crop.plantedDate!);
        final harvestDate = planted.add(Duration(days: _totalCycleDays));
        return harvestDate.difference(DateTime.now()).inDays;
      } catch (_) {}
    }
    // 3. No date info at all — derive from cycle minus elapsed.
    return (_totalCycleDays - _elapsed).clamp(0, _totalCycleDays);
  }

  /// True when the user explicitly set a harvest date (so we show "linked" badge)
  bool get _isUserLinked =>
      crop.plantedDate != null && crop.expectedHarvestDate != null;

  String _t(BuildContext ctx, String ar, String fr) =>
      ctx.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection:
            context.watch<SettingsProvider>().settings.language == 'fr'
                ? TextDirection.ltr
                : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.bg(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                PageHeader(
                    title: _t(context, 'مراحل النمو', 'Stades de croissance'),
                    subtitle: crop.name),
                const SizedBox(height: 20),

                // ── Stat bubbles ────────────────────────────────────────────
                CardShell(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      _bubble(
                          context,
                          '$_elapsed',
                          _t(context, 'يوم مضى', 'Jours écoulés'),
                          AppColors.primary),
                      _bubble(
                          context,
                          '$_daysToHarvest',
                          _t(context, 'للحصاد', 'Avant récolte'),
                          AppColors.warning),
                      _bubble(
                          context,
                          '${_currentStage + 1}/${_stagesMeta.length}',
                          _t(context, 'المرحلة', 'Étape'),
                          AppColors.info),
                    ])),
                const SizedBox(height: 20),

                // ── "Linked to user dates" info banner ───────────────────────
                if (_isUserLinked)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primLight(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.link_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _t(
                            context,
                            'المراحل مُعايَرة على الفترة التي حددتها (${_totalCycleDays} يوم)',
                            'Stades ajustés à votre période définie ($_totalCycleDays j)',
                          ),
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                  ),

                // ── Progress bar ─────────────────────────────────────────────
                CardShell(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      Text(
                          _t(context, 'تقدم دورة النمو',
                              'Progression du cycle'),
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.txt(context),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_elapsed / _totalCycleDays).clamp(0.0, 1.0),
                            backgroundColor: AppColors.surfAlt(context),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                            minHeight: 12,
                          )),
                      const SizedBox(height: 6),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${((_elapsed / _totalCycleDays) * 100).toInt()}%',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                            Text(
                                _t(context, 'من الدورة الكاملة',
                                    'du cycle complet'),
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.txtMuted(context))),
                          ]),
                    ])),
                const SizedBox(height: 20),

                Text(
                    _t(context, 'جدول المراحل', 'Calendrier des stades'),
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.txt(context))),
                const SizedBox(height: 12),

                // ── Timeline list ────────────────────────────────────────────
                ...List.generate(_stagesMeta.length, (i) {
                  final s      = _stagesMeta[i];
                  final day    = _stageDays[i];
                  final isDone = i < _currentStage;
                  final isCur  = i == _currentStage;
                  final color  = isDone
                      ? AppColors.primary
                      : isCur
                          ? AppColors.warning
                          : AppColors.txtMuted(context);
                  final bg = isDone
                      ? AppColors.primLight(context)
                      : isCur
                          ? AppColors.orgLight(context)
                          : AppColors.surfAlt(context);
                  final stLabel =
                      context.read<SettingsProvider>().settings.language == 'fr'
                          ? s['fr'] as String
                          : s['ar'] as String;

                  // Compute calendar date for this stage if plantedDate is known
                  String? stageDate;
                  if (crop.plantedDate != null) {
                    try {
                      final d = DateTime.parse(crop.plantedDate!)
                          .add(Duration(days: day));
                      stageDate =
                          '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
                    } catch (_) {}
                  }

                  return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: bg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: color,
                                    width: isCur ? 2.5 : 1.5)),
                            child: Center(
                                child: Text(s['icon'] as String,
                                    style:
                                        const TextStyle(fontSize: 20))),
                          ),
                          if (i < _stagesMeta.length - 1)
                            Container(
                                width: 2,
                                height: 48,
                                color: isDone
                                    ? AppColors.primary
                                    : AppColors.bord(context)),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 28),
                          child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t(context, 'اليوم $day',
                                            'Jour $day'),
                                        style: AppTextStyles.caption
                                            .copyWith(color: color),
                                      ),
                                      if (stageDate != null)
                                        Text(
                                          stageDate,
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                  color: AppColors
                                                      .txtMuted(context),
                                                  fontSize: 10),
                                        ),
                                      if (isDone)
                                        Icon(Icons.check_circle_rounded,
                                            color: AppColors.primary,
                                            size: 16),
                                      if (isCur)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: AppColors.warning,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(
                                              _t(context, 'الحالية',
                                                  'En cours'),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                    ]),
                                Text(stLabel,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                            color: i > _currentStage
                                                ? AppColors.txtMuted(
                                                    context)
                                                : AppColors.txt(context),
                                            fontWeight: isCur
                                                ? FontWeight.w700
                                                : FontWeight.w500)),
                              ]),
                        )),
                      ]);
                }),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ),
      );

  Widget _bubble(
          BuildContext context, String val, String label, Color color) =>
      Column(children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border:
                  Border.all(color: color.withOpacity(0.3), width: 2)),
          child: Center(
              child: Text(val,
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800))),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.txtSec(context))),
      ]);
}