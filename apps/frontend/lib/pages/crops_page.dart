import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/crop_model.dart';
import 'add_crop_page.dart';
import 'crop_health_detail_page.dart';
import '../services/api_client.dart';
import '../providers/settings_provider.dart';
// Feature 3: disease history
import '../providers/analysis_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});
  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  String _searchQuery = '';
  String _lang = 'ar';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.crops.isEmpty) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final dashboard = context.read<DashboardProvider>();
            final added = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddCropPage()));
            if (added == true) {
              await dashboard.load();
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Consumer<DashboardProvider>(
          builder: (context, provider, _) => SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.surf(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.bord(context))),
                      child: const Icon(Icons.eco_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                    Text(_t(_lang, 'محاصيلي', 'Mes cultures'),
                        style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.surf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bord(context))),
                  child: TextField(
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.txt(context)),
                    decoration: InputDecoration(
                      hintText:
                          _t(_lang, 'بحث عن محصول...', 'Rechercher...'),
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.txtMuted(context)),
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 18, color: AppColors.txtMuted(context)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.trim().toLowerCase()),
                  ),
                ),
              ),
              Expanded(child: _body(context, provider)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DashboardProvider provider) {
    if (provider.isLoading && provider.crops.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.crops.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_rounded,
            color: AppColors.txtMuted(context), size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? _t(_lang, 'تعذر التحميل', 'Erreur'),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(
            label: _t(_lang, 'إعادة المحاولة', 'Réessayer'),
            onTap: () => provider.load()),
      ]));
    }
    final crops = _searchQuery.isEmpty
        ? provider.crops
        : provider.crops
            .where((c) => RemoteCrop.localizedName(c.name, _lang)
                .toLowerCase()
                .contains(_searchQuery))
            .toList();
    if (crops.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.grass_rounded,
            color: AppColors.txtMuted(context), size: 52),
        const SizedBox(height: 12),
        Text(_t(_lang, 'لا توجد محاصيل بعد', 'Aucune culture'),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(
            label: _t(_lang, 'إضافة محصول', 'Ajouter une culture'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddCropPage()))),
      ]));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _cropCard(context, crops[i]),
      ),
    );
  }

  Widget _cropCard(BuildContext context, RemoteCrop crop) {
    final statusColor = crop.statusKey == 'healthy'
        ? AppColors.primary
        : crop.statusKey == 'warning'
            ? AppColors.warning
            : AppColors.error;
    final statusBg = crop.statusKey == 'healthy'
        ? AppColors.primaryLight
        : crop.statusKey == 'warning'
            ? AppColors.orangeLight
            : const Color(0xFFFEF2F2);

    // Feature 3: disease history count for this crop
    final history = context
        .read<AnalysisProvider>()
        .history
        .where((r) => !r.isHealthy)
        .toList();
    final diseaseCount = history.length;

    return CardShell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CropHealthDetailPage(crop: crop)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (crop.plantedDate != null)
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.txtMuted(context)),
                const SizedBox(width: 4),
                Text(crop.plantedDate!.split('T').first,
                    style: AppTextStyles.caption),
              ]),
            const SizedBox(height: 4),
            if (crop.growthStage != null)
              Row(children: [
                const Icon(Icons.energy_savings_leaf_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(crop.growthStage!, style: AppTextStyles.caption),
              ]),
            // Feature 3: disease badge
            if (diseaseCount > 0) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.bug_report_outlined,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _t(_lang, '$diseaseCount تشخيص مرض',
                      '$diseaseCount maladie(s)'),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error),
                ),
              ]),
            ],
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
              StatusBadge(
                  label: crop.statusLabel,
                  color: statusColor,
                  bg: statusBg),
              const SizedBox(height: 4),
              Text(RemoteCrop.localizedName(crop.name, _lang),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.txt(context))),
              if (crop.variety != null)
                Text(crop.variety!, style: AppTextStyles.caption),
              if (crop.fieldName != '-')
                Text(
                  _t(_lang, 'الحقل: ${crop.fieldName}',
                      'Champ: ${crop.fieldName}'),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.txtMuted(context)),
                ),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: AppColors.primLight(context),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.grass_rounded,
                size: 32, color: AppColors.primary),
          ),
        ]),
        const SizedBox(height: 10),
        // Action row: timeline + delete
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // Feature 1: growth timeline shortcut
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      CropHealthDetailPage(crop: crop)),
            ),
            child: Row(children: [
              const Icon(Icons.timeline_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                _t(_lang, 'مراحل النمو', 'Stades de croissance'),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primary),
              ),
            ]),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context, crop),
            child: Row(children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(_t(_lang, 'حذف المحصول', 'Supprimer'),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error)),
            ]),
          ),
        ]),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, RemoteCrop crop) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('${_t(_lang, 'حذف', 'Supprimer')} ${RemoteCrop.localizedName(crop.name, _lang)}؟',
              style: AppTextStyles.headlineMedium),
          content: Text('سيتم حذف هذا المحصول نهائياً',
              style: AppTextStyles.bodySmall),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_t(_lang, 'إلغاء', 'Annuler'))),
            TextButton(
              onPressed: () async {
                // Capture everything before Navigator.pop invalidates context
                final api = context.read<ApiClient>();
                final dashboard = context.read<DashboardProvider>();
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await api.delete('/crops/${crop.id}');
                  await dashboard.load();
                } catch (_) {
                  messenger.showSnackBar(SnackBar(
                      content: Text(_t(_lang, 'فشل حذف المحصول',
                          'Échec de la suppression'))));
                }
              },
              child: Text(_t(_lang, 'حذف', 'Supprimer'),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}