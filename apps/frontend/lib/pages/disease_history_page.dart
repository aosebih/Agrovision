/// Feature 3 — Disease History Page
/// Shows all persisted diagnosis results, filterable by crop.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/analysis_provider.dart';
import '../providers/settings_provider.dart';
import '../models/remote/analysis_result.dart';
import 'disease_diagnosis_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class DiseaseHistoryPage extends StatefulWidget {
  /// If provided, filters history to this crop key only.
  final String? cropKey;
  const DiseaseHistoryPage({super.key, this.cropKey});

  @override
  State<DiseaseHistoryPage> createState() => _DiseaseHistoryPageState();
}

class _DiseaseHistoryPageState extends State<DiseaseHistoryPage> {
  String _lang = 'ar';

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    final provider = context.watch<AnalysisProvider>();

    List<AnalysisResult> history = provider.history;
    if (widget.cropKey != null) {
      history =
          history.where((r) => r.cropKey == widget.cropKey).toList();
    }

    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.surfAlt(context),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.bord(context))),
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
                    _t(_lang, 'سجل التشخيصات', 'Historique des diagnostics'),
                    style: AppTextStyles.titleLarge,
                  ),
                ),
                if (history.isNotEmpty)
                  GestureDetector(
                    onTap: () => _confirmClear(context, provider),
                    child: Icon(Icons.delete_sweep_outlined,
                        size: 22, color: AppColors.txtMuted(context)),
                  ),
              ]),
            ),
            // Summary strip
            if (history.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: CardShell(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                    _bubble(context, '${history.length}',
                        _t(_lang, 'إجمالي', 'Total'),
                        AppColors.primary),
                    _bubble(
                        context,
                        '${history.where((r) => !r.isHealthy).length}',
                        _t(_lang, 'أمراض', 'Maladies'),
                        AppColors.error),
                    _bubble(
                        context,
                        '${history.where((r) => r.isHealthy).length}',
                        _t(_lang, 'سليم', 'Sain'),
                        AppColors.primary),
                  ]),
                ),
              ),
            Expanded(child: _body(context, history)),
          ]),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, List<AnalysisResult> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_rounded,
              size: 52, color: AppColors.txtMuted(context)),
          const SizedBox(height: 12),
          Text(
            _t(_lang, 'لا يوجد سجل تشخيص بعد',
                'Aucun diagnostic enregistré'),
            style: AppTextStyles.bodySmall,
          ),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _historyCard(context, history[i]),
    );
  }

  Widget _historyCard(BuildContext context, AnalysisResult result) {
    final color = result.isHealthy ? AppColors.primary : AppColors.error;
    final bg = result.isHealthy
        ? AppColors.primLight(context)
        : const Color(0xFFFEF2F2);
    final date = result.timestamp.split('T').first;
    final time = result.timestamp.contains('T')
        ? result.timestamp.split('T')[1].substring(0, 5)
        : '';

    return CardShell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                DiseaseDiagnosisPage(result: result, lang: _lang)),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(
            result.isHealthy
                ? Icons.check_circle_outline_rounded
                : Icons.bug_report_outlined,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              result.nameForLang(_lang),
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.txt(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(children: [
              Text(result.cropKey,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.txtMuted(context))),
              const SizedBox(width: 8),
              Text('${result.confidencePercent}%',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
              if (result.fieldName != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.landscape_outlined,
                    size: 11, color: AppColors.txtMuted(context)),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    result.fieldName!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txtMuted(context)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(
            label: result.isHealthy
                ? _t(_lang, 'سليم', 'Sain')
                : _t(_lang, 'مرض', 'Maladie'),
            color: color,
            bg: bg,
          ),
          const SizedBox(height: 4),
          Text('$date  $time',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.txtMuted(context))),
        ]),
      ]),
    );
  }

  void _confirmClear(BuildContext context, AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection:
            _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
        child: AlertDialog(
          title: Text(_t(_lang, 'مسح السجل؟', 'Effacer l\'historique?'),
              style: AppTextStyles.headlineMedium),
          content: Text(
            _t(_lang, 'سيتم حذف جميع التشخيصات المحفوظة.',
                'Tous les diagnostics seront supprimés.'),
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_t(_lang, 'إلغاء', 'Annuler'))),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.clearHistory();
              },
              child: Text(_t(_lang, 'مسح', 'Effacer'),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(
          BuildContext context, String val, String label, Color color) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(val,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.txtSec(context))),
      ]);
}
