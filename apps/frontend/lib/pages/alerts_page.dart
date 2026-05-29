import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/alerts_provider.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selFilter = 0;

  List<Map<String, String?>> _filters(String lang) => [
    {'label': _t(lang, 'الكل', 'Tout'), 'type': null},
    {'label': _t(lang, 'الطقس', 'Météo'), 'type': 'weather'},
    {'label': _t(lang, 'صحة المحاصيل', 'Santé cultures'), 'type': 'crop_health'},
    {'label': _t(lang, 'الري', 'Irrigation'), 'type': 'irrigation'},
    {'label': _t(lang, 'المخزون', 'Stock'), 'type': 'inventory'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(null));
  }

  void _load(String? type) {
    context.read<AlertsProvider>().load(type: type);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    final filters = _filters(lang);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Consumer<AlertsProvider>(
        builder: (context, provider, _) => SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: provider.alerts.isNotEmpty
                          ? () => _confirmDeleteAll(context, provider, lang)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.surf(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.bord(context))),
                        child: Icon(Icons.delete_sweep_rounded,
                            size: 20,
                            color: provider.alerts.isNotEmpty
                                ? AppColors.error
                                : AppColors.txtMuted(context)),
                      ),
                    ),
                    GestureDetector(
                      onTap: provider.unreadCount > 0
                          ? () => provider.markAllRead()
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.surf(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.bord(context))),
                        child: Icon(Icons.done_all_rounded,
                            size: 20,
                            color: provider.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.txtMuted(context)),
                      ),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_t(lang, 'التنبيهات', 'Alertes'),
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.txt(context))),
                          if (provider.unreadCount > 0)
                            Text('${provider.unreadCount} ${_t(lang, 'غير مقروء', 'non lu(s)')}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.error))
                          else
                            Text(_t(lang, 'كل شيء على ما يرام', 'Tout va bien'),
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primary)),
                        ]),
                  ]),
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                itemBuilder: (_, i) {
                  final sel = i == _selFilter;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selFilter = i);
                      _load(filters[i]['type']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surf(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? AppColors.primary : AppColors.bord(context)),
                      ),
                      child: Text(filters[i]['label']!,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: sel ? Colors.white : AppColors.txtSec(context))),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: _body(context, provider, lang)),
          ]),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AlertsProvider provider, String lang) {
    if (provider.isLoading && provider.alerts.isEmpty)
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    if (provider.state == LoadState.error && provider.alerts.isEmpty)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_rounded,
            color: AppColors.txtMuted(context), size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? _t(lang, 'تعذر التحميل', 'Erreur de chargement'),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _load(null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: Text(_t(lang, 'إعادة المحاولة', 'Réessayer'),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
          ),
        ),
      ]));
    if (provider.alerts.isEmpty)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_outline_rounded,
            color: AppColors.primary, size: 56),
        const SizedBox(height: 12),
        Text(_t(lang, 'لا توجد تنبيهات', 'Aucune alerte'),
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.txt(context))),
      ]));

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: provider.alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final alert = provider.alerts[i];
          return Dismissible(
            key: Key(alert.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) => provider.deleteAlert(alert.id),
            background: Container(
              decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete_rounded,
                  color: Colors.white, size: 24),
            ),
            child: _AlertCard(alert: alert, provider: provider, lang: lang),
          );
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, AlertsProvider provider, String lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t(lang, 'حذف كل التنبيهات؟', 'Supprimer toutes les alertes ?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t(lang, 'إلغاء', 'Annuler'))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteAll();
            },
            child: Text(_t(lang, 'حذف', 'Supprimer'),
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final RemoteAlert alert;
  final AlertsProvider provider;
  final String lang;
  const _AlertCard({required this.alert, required this.provider, required this.lang});

  IconData get _icon {
    switch (alert.type) {
      case 'weather': return Icons.wb_cloudy_rounded;
      case 'crop_health': return Icons.eco_rounded;
      case 'irrigation': return Icons.water_drop_rounded;
      case 'inventory': return Icons.inventory_2_outlined;
      case 'fertilizer': return Icons.science_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get _color => alert.isCritical
      ? AppColors.error
      : alert.isWarning ? AppColors.warning : AppColors.info;
  Color get _bgColor => alert.isCritical
      ? const Color(0xFFFEF2F2)
      : alert.isWarning ? AppColors.orangeLight : AppColors.blueLight;

  String _timeAgo() {
    if (alert.createdAt.isEmpty) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(alert.createdAt));
      if (lang == 'fr') {
        if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
        if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
        return 'il y a ${diff.inDays}j';
      }
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () { if (!alert.isRead) provider.markRead(alert.id); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alert.isRead ? AppColors.bord(context) : _color.withOpacity(0.4),
              width: alert.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shad(context),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              Row(children: [
                if (!alert.isRead)
                  Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
                Text(_timeAgo(),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txtMuted(context))),
              ]),
              const Spacer(),
              Text(alert.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.txt(context),
                      fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.w700)),
              SizedBox(width: 10),
              Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: _bgColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(_icon, size: 18, color: _color)),
            ]),
            const SizedBox(height: 8),
            Text(alert.message,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.txtSec(context))),
            if (!alert.isAcknowledged) ...[
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => provider.acknowledge(alert.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _color.withOpacity(0.3)),
                    ),
                    child: Text(_t(lang, 'تم الاعتراف', 'Acquitter'),
                        style: AppTextStyles.caption.copyWith(
                            color: _color, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      );
}