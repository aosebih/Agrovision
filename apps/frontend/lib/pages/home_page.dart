import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';
import '../providers/alerts_provider.dart' hide LoadState;
import '../providers/settings_provider.dart';
import 'inventory_page.dart';
import 'fields_page.dart';
import 'alerts_page.dart';
import '../providers/weather_provider.dart';
import 'weather_page.dart';
import 'npk_calculator_page.dart';
import '../providers/inventory_provider.dart';
import 'crop_recommendation_home.dart';
import 'chatbot_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
      context.read<AlertsProvider>().load();
      context.read<WeatherProvider>().load();
    });
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.data == null) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (provider.state == LoadState.error && provider.data == null) {
              return _errorView(provider, lang);
            }
            final data = provider.data;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(lang),
                    const SizedBox(height: 24),

                    // ── Overview stats ───────────────────────────────────────
                    _sectionLabel(_t(lang, 'نظرة عامة', "Vue d'ensemble"), context),
                    const SizedBox(height: 10),
                    if (data != null) _statsGrid(data, lang),
                    const SizedBox(height: 16),

                    // ── Low stock alert (conditional) ────────────────────────
                    _LowStockBanner(lang: lang),
                    const SizedBox(height: 16),

                    // ── Quick navigation ─────────────────────────────────────
                    _sectionLabel(_t(lang, 'الأقسام', 'Navigation'), context),
                    const SizedBox(height: 10),
                    _navRow(context, lang),
                    const SizedBox(height: 16),

                    // ── Weather ──────────────────────────────────────────────
                    _sectionLabel(_t(lang, 'الطقس', 'Météo'), context),
                    const SizedBox(height: 10),
                    _weatherMiniCard(context, lang),
                    const SizedBox(height: 16),

                    // ── Tools ────────────────────────────────────────────────
                    _sectionLabel(_t(lang, 'الأدوات', 'Outils'), context),
                    const SizedBox(height: 10),
                    _quickActions(context, lang),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _errorView(DashboardProvider provider, String lang) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.txtMuted(context)),
            const SizedBox(height: 16),
            Text(
                _t(lang, 'تعذّر تحميل البيانات',
                    'Impossible de charger les données'),
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(provider.errorMessage ?? '',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GreenButton(
                label: _t(lang, 'إعادة المحاولة', 'Réessayer'),
                icon: Icons.refresh_rounded,
                onTap: () => provider.load()),
          ]),
        ),
      );

  Widget _header(String lang) => Consumer<AlertsProvider>(
        builder: (context, alertsProvider, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AlertsPage())),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _iconBtn(Icons.notifications_outlined),
                  if (alertsProvider.unreadCount > 0)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                        child: Text(
                          '${alertsProvider.unreadCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_todayLabel(lang), style: AppTextStyles.caption),
              Text(_t(lang, 'مرحباً بك', 'Bienvenue'),
                  style: AppTextStyles.headlineMedium),
            ]),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.surfAlt(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bord(context))),
              child: Icon(Icons.person_rounded,
                  size: 28, color: AppColors.txtMuted(context)),
            ),
          ],
        ),
      );

  String _todayLabel(String lang) {
    final now = DateTime.now();
    if (lang == 'fr') {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      const months = [
        'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
        'juil', 'août', 'sep', 'oct', 'nov', 'déc'
      ];
      return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
    }
    const days = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]}';
  }

  Widget _iconBtn(IconData icon) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bord(context))),
        child: Center(
            child: Icon(icon, size: 22, color: AppColors.txtSec(context))),
      );

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, BuildContext context) => Row(children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.txtSec(context),
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ]);

  // ── Stats Grid — 2 × 2 ────────────────────────────────────────────────────
  Widget _statsGrid(DashboardData data, String lang) => Column(children: [
        Row(children: [
          Expanded(
            child: _StatTile(
              icon: Icons.eco_rounded,
              label: _t(lang, 'المحاصيل', 'Cultures'),
              value: '${data.totalCrops}',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              icon: Icons.water_drop_rounded,
              label: _t(lang, 'أحداث الري', 'Irrigations'),
              value: '${data.totalIrrigationEvents}',
              color: AppColors.info,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _StatTile(
              icon: Icons.notifications_rounded,
              label: _t(lang, 'تنبيهات', 'Alertes'),
              value: '${data.unreadAlerts}',
              color: data.unreadAlerts > 0 ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              icon: Icons.inventory_2_rounded,
              label: _t(lang, 'مخزون منخفض', 'Stock bas'),
              value: '${data.lowStockItems}',
              color: AppColors.orange,
            ),
          ),
        ]),
      ]);

  // ── Nav Row (inventory + fields side by side) ─────────────────────────────
  Widget _navRow(BuildContext context, String lang) => Row(children: [
        Expanded(child: _navCard(
          context: context,
          icon: Icons.inventory_2_rounded,
          title: _t(lang, 'المخزون', 'Stock'),
          subtitle: _t(lang, 'إدارة المستلزمات', 'Fournitures'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InventoryPage())),
        )),
        const SizedBox(width: 12),
        Expanded(child: _navCard(
          context: context,
          icon: Icons.landscape_rounded,
          title: _t(lang, 'الحقول', 'Champs'),
          subtitle: _t(lang, 'إدارة الحقول', 'Vos champs'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FieldsPage())),
        )),
      ]);

  Widget _navCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bord(context)),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2))
            ],
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.txt(context),
                        fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.caption),
              ]),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.txtMuted(context), size: 18),
          ]),
        ),
      );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bord(context)),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))
            ]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.headlineLarge
                  .copyWith(color: color, fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

Widget _weatherMiniCard(BuildContext context, String lang) =>
    Consumer<WeatherProvider>(builder: (context, wp, _) {
      final w = wp.weather;
      if (w == null) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const WeatherPage())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blLight(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.wb_cloudy_outlined, color: AppColors.info),
              const SizedBox(width: 12),
              Text(
                  _t(lang, 'اضغط لتحميل بيانات الطقس',
                      'Appuyer pour charger la météo'),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.info)),
            ]),
          ),
        );
      }

      String emoji(String cond) {
        switch (cond) {
          case 'clear': return '☀️';
          case 'rain':
          case 'drizzle': return '🌧️';
          case 'thunderstorm': return '⛈️';
          case 'snow': return '❄️';
          default: return '⛅';
        }
      }

      List<Color> grad(String cond) {
        switch (cond) {
          case 'clear':
            return [const Color(0xFF1E88E5), const Color(0xFF42A5F5)];
          case 'rain':
            return [const Color(0xFF455A64), const Color(0xFF78909C)];
          default:
            return [const Color(0xFF1976D2), const Color(0xFF42A5F5)];
        }
      }

      String miniDay(String date) {
        try {
          if (lang == 'fr') {
            const d = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
            return d[DateTime.parse(date).weekday - 1];
          }
          const d = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
          return d[DateTime.parse(date).weekday - 1];
        } catch (_) {
          return '';
        }
      }

      return GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WeatherPage())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: grad(w.condition),
                begin: Alignment.topRight,
                end: Alignment.bottomLeft),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: w.forecast
                  .take(4)
                  .map((f) => Column(children: [
                        Text(miniDay(f.date),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10)),
                        Text(emoji(f.condition),
                            style: const TextStyle(fontSize: 16)),
                        Text('${f.tempMax.toInt()}°',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]))
                  .toList(),
            )),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(w.city,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Row(children: [
                Text(emoji(w.condition),
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 6),
                Text('${w.temperature}°',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800)),
              ]),
              Text(w.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        ),
      );
    });

Widget _quickActions(BuildContext context, String lang) => Column(children: [
      Row(children: [
        Expanded(
            child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WeatherPage())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.info.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Icon(Icons.wb_sunny_rounded, color: AppColors.info, size: 24),
              const SizedBox(height: 8),
              Text(_t(lang, 'الطقس', 'Météo'),
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info, fontWeight: FontWeight.w600)),
            ]),
          ),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NpkCalculatorPage())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Icon(Icons.science_rounded,
                  color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(_t(lang, 'حاسبة NPK', 'Calculateur NPK'),
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        )),
      ]),
      const SizedBox(height: 12),
      // ── Crop Recommendation ──────────────────────────────────────────────
      GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CropRecommendationHome())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primLight(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _t(lang, 'توصية المحصول', 'Recommandation de culture'),
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                Text(
                  _t(lang, 'مدعوم بالذكاء الاصطناعي • تحليل متقدم',
                      'IA avancée • Analyse détaillée'),
                  style: AppTextStyles.caption,
                ),
              ]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.primary, size: 18),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      // ── AI Chatbot ───────────────────────────────────────────────────────
      GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ChatbotPage())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), AppColors.primary],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _t(lang, 'المساعد الزراعي', 'Assistant agricole'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  _t(lang, 'اسأل الذكاء الاصطناعي عن محاصيلك',
                      "Posez vos questions à l’IA"),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white70, size: 18),
          ]),
        ),
      ),
    ]);


// ── Low Stock Banner ─────────────────────────────────────────────────────────
class _LowStockBanner extends StatelessWidget {
  final String lang;
  const _LowStockBanner({required this.lang});

  String _t(String ar, String fr) => lang == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<InventoryProvider>().items;
    final lowStock = items
        .where((i) => i.minStockLevel != null && i.quantity <= i.minStockLevel!)
        .toList();

    if (lowStock.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.orange.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: AppColors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _t('مخزون منخفض — ${lowStock.length} صنف',
                  'Stock faible — ${lowStock.length} article(s)'),
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.orange, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ...lowStock.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.orange, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(item.name, style: AppTextStyles.bodySmall),
                    ]),
                    Text(
                      '${item.quantity.toStringAsFixed(1)} / ${item.minStockLevel!.toStringAsFixed(1)} ${item.unit}',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.orange, fontWeight: FontWeight.w600),
                    ),
                  ]),
            )),
        if (lowStock.length > 3)
          Text(
            _t('+ ${lowStock.length - 3} أصناف أخرى',
                '+ ${lowStock.length - 3} autres'),
            style: AppTextStyles.caption.copyWith(color: AppColors.orange),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InventoryPage())),
          child: Text(
            _t('عرض المخزون ←', 'Voir le stock →'),
            style: AppTextStyles.caption.copyWith(
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline),
          ),
        ),
      ]),
    );
  }
}