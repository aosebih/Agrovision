import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../services/api_client.dart';
import '../providers/settings_provider.dart';

class FertilizerHistoryPage extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  const FertilizerHistoryPage({super.key, required this.fieldId, required this.fieldName});
  @override
  State<FertilizerHistoryPage> createState() => _FertilizerHistoryPageState();
}

class _FertilizerHistoryPageState extends State<FertilizerHistoryPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await context.read<ApiClient>()
          .get('/fertilizers/applications/list?fieldId=${widget.fieldId}&limit=50');
      final list = res is Map ? (res['items'] ?? res['data'] ?? []) : res as List;
      setState(() { _items = List<Map<String, dynamic>>.from(list as List); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _t(String ar, String fr) =>
      context.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: context.watch<SettingsProvider>().settings.language == 'fr'
        ? TextDirection.ltr : TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(children: [
          PageHeader(title: _t('تاريخ التسميد', 'Historique des engrais'), subtitle: widget.fieldName),
          Expanded(child: _body(context)),
        ]),
      ),
    ),
  );

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, color: AppColors.txtMuted(context), size: 48),
      SizedBox(height: 12),
      Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtSec(context))),
      const SizedBox(height: 12),
      GreenButton(label: _t('إعادة المحاولة', 'Réessayer'), onTap: _load),
    ]));
    if (_items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.science_outlined, color: AppColors.txtMuted(context), size: 52),
      SizedBox(height: 12),
      Text(_t('لا توجد سجلات تسميد', "Aucune application d'engrais"),
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txtMuted(context))),
    ]));

    double totalKg = _items.fold(0, (s, e) => s + ((e['quantityUsed'] as num?) ?? 0).toDouble());

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          CardShell(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _stat(context, '${_items.length}', _t('تطبيق', 'Applications'), AppColors.primary),
            _stat(context, '${totalKg.toStringAsFixed(0)} kg', _t('إجمالي', 'Total'), AppColors.info),
            _stat(context,
                _items.isNotEmpty
                    ? (_items.first['appliedAt'] as String?)?.split('T').first ?? '--'
                    : '--',
                _t('آخر تطبيق', 'Dernier'), AppColors.warning),
          ])),
          SizedBox(height: 16),
          Text(_t('السجل الكامل', 'Historique complet'),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 10),
          ..._items.map((app) {
            final name = (app['fertilizer'] as Map?)?['name'] ?? _t('سماد', 'Engrais');
            final qty  = (app['quantityUsed'] as num?)?.toDouble() ?? 0;
            final unit = (app['fertilizer'] as Map?)?['unit'] ?? 'kg';
            final date = (app['appliedAt'] as String?)?.split('T').first ?? '';
            final note = app['notes'] as String?;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardShell(child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
                  const SizedBox(height: 4),
                  Text('${qty.toStringAsFixed(0)} $unit',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                  if (note != null && note.isNotEmpty)
                    Text(note, style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
                ]),
                const Spacer(),
                Text(name.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.txt(context))),
                SizedBox(width: 12),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primLight(context), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.science_rounded, color: AppColors.primary, size: 20),
                ),
              ])),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String v, String l, Color c) => Column(children: [
    Text(v, style: AppTextStyles.headlineMedium.copyWith(color: c, fontSize: 18)),
    Text(l, style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
  ]);
}
