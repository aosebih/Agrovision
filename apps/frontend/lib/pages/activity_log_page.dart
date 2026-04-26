import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/analysis_provider.dart';
import '../models/remote/analysis_result.dart';
import 'disease_diagnosis_page.dart';


class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});
  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  int _selFilter = 0;
  final _filters = const ['الكل', 'تحليلات', 'سليم', 'أمراض'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, _) => SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary)),
            Text('سجل التحليلات', style: AppTextStyles.titleLarge),
          ])),
          SizedBox(height: 44, child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filters.length,
            itemBuilder: (_, i) { final sel = i == _selFilter;
              return GestureDetector(onTap: () => setState(() => _selFilter = i), child: Container(
                margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
                child: Text(_filters[i], style: AppTextStyles.bodySmall.copyWith(color: sel ? Colors.white : AppColors.textSecondary))));
            },
          )),
          Expanded(child: _body(provider)),
        ])),
      ),
    ),
  );

  List<AnalysisResult> _filtered(List<AnalysisResult> all) {
    switch (_selFilter) {
      case 1: return all; // all analyses
      case 2: return all.where((r) => r.prediction == PredictionLabel.healthy).toList();
      case 3: return all.where((r) => r.prediction == PredictionLabel.diseased).toList();
      default: return all;
    }
  }

  Widget _body(AnalysisProvider provider) {
    final items = _filtered(provider.history);
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.image_search_rounded, color: AppColors.textMuted, size: 56),
        const SizedBox(height: 12),
        Text('لا توجد تحليلات سابقة', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text('استخدم الكاميرا لتحليل محاصيلك', style: AppTextStyles.bodySmall),
      ]));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.loadHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _resultCard(items[i]),
      ),
    );
  }

  Widget _resultCard(AnalysisResult r) {
    final isHealthy = r.isHealthy;
    final color = isHealthy ? AppColors.primary : AppColors.error;
    final bg = isHealthy ? AppColors.primaryLight : const Color(0xFFFEF2F2);
    final label = isHealthy ? 'سليم' : (r.disease ?? 'مرض مكتشف');
    final dt = DateTime.tryParse(r.timestamp);
    final timeLabel = dt != null ? '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}' : r.timestamp;

    return CardShell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDiagnosisPage(result: r))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(timeLabel, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text('${(r.confidence * 100).toInt()}%', style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          if (r.cropType != null) Text(r.cropType!, style: AppTextStyles.caption),
        ]),
        const SizedBox(width: 10),
        Container(width: 42, height: 42, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
          child: Icon(isHealthy ? Icons.eco_rounded : Icons.bug_report_outlined, size: 20, color: color)),
      ]),
    );
  }
}
