import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _locCtrl = TextEditingController();

  String _t(String ar, String fr) =>
      context.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = context.read<SettingsProvider>();
      context.read<WeatherProvider>().load(
          location: sp.settings.location.isNotEmpty ? sp.settings.location : 'Oran,DZ');
    });
  }

  @override
  void dispose() { _locCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg(context),
    body: SafeArea(
      child: Consumer<WeatherProvider>(
        builder: (context, wp, _) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => wp.load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _header(context),
              SizedBox(height: 16),
              _locationBar(context, wp),
              const SizedBox(height: 16),
              if (wp.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary)))
              else if (wp.weather != null) ...[
                _currentCard(context, wp.weather!),
                const SizedBox(height: 16),
                _forecastCard(context, wp.weather!),
                const SizedBox(height: 16),
                _adviceCard(context, wp.weather!),
              ] else if (wp.error != null)
                CardShell(child: Column(children: [
                  Icon(Icons.cloud_off_rounded, color: AppColors.txtMuted(context), size: 40),
                  SizedBox(height: 8),
                  Text(wp.error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtSec(context))),
                  const SizedBox(height: 12),
                  GreenButton(label: _t('إعادة المحاولة', 'Réessayer'), onTap: () => wp.load()),
                ])),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ),
    ),
  );

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.surfAlt(context),
              borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.bord(context))),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.txtSec(context)),
        ),
      ),
      Text(_t('الطقس الزراعي', 'Météo Agricole'),
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.txt(context))),
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: AppColors.blLight(context), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.wb_sunny_rounded, size: 20, color: AppColors.info),
      ),
    ],
  );

  Widget _locationBar(BuildContext context, WeatherProvider wp) => Row(children: [
    Expanded(child: Container(
      height: 46,
      decoration: BoxDecoration(color: AppColors.surf(context),
          borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bord(context))),
      child: TextField(
        controller: _locCtrl,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.txt(context)),
        decoration: InputDecoration(
          hintText: _t('المدينة (مثال: وهران)', 'Ville (ex: Oran)'),
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context)),
          prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: AppColors.txtMuted(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (v) { if (v.isNotEmpty) wp.load(location: v); },
      ),
    )),
    const SizedBox(width: 10),
    GestureDetector(
      onTap: () { if (_locCtrl.text.isNotEmpty) wp.load(location: _locCtrl.text); },
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
      ),
    ),
  ]);

  Widget _currentCard(BuildContext context, WeatherData w) {
    final grad = _grad(w.condition);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: grad, begin: Alignment.topRight, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${w.windSpeed} km/h\n💨',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${w.city}, ${w.country}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${w.temperature}°م',
                style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w800)),
            Text(w.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ]),
          Text(_emoji(w.condition), style: const TextStyle(fontSize: 52)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat('💧', '${w.humidity}%', _t('رطوبة', 'Humidité')),
          _stat('🌡', '${w.feelsLike}°', _t('يبدو', 'Ressenti')),
          _stat('💨', '${w.windSpeed}', _t('ريح km/h', 'Vent km/h')),
        ]),
      ]),
    );
  }

  Widget _stat(String em, String val, String label) => Column(children: [
    Text(em, style: const TextStyle(fontSize: 18)),
    Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
  ]);

  Widget _forecastCard(BuildContext context, WeatherData w) => CardShell(
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(_t('توقعات 5 أيام', 'Prévisions 5 jours'),
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: w.forecast.map((day) {
          final lang = context.read<SettingsProvider>().settings.language;
          return Expanded(child: Column(children: [
            Text(lang == 'fr' ? day.dayFr : day.dayAr,
                style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
            const SizedBox(height: 4),
            Text(_emoji(day.condition), style: const TextStyle(fontSize: 22)),
            if (day.rainProbability > 20)
              Text('${day.rainProbability}%',
                  style: AppTextStyles.caption.copyWith(color: AppColors.info)),
            Text('${day.tempMax.toInt()}°',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.txt(context), fontWeight: FontWeight.w700)),
            Text('${day.tempMin.toInt()}°',
                style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
          ]));
        }).toList(),
      ),
    ]),
  );

  Widget _adviceCard(BuildContext context, WeatherData w) => CardShell(
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(_t('نصائح زراعية', 'Conseils agricoles'),
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
      const SizedBox(height: 12),
      _advice(context, Icons.water_drop_rounded, AppColors.info,
          _t('الري اليوم', "Irrigation aujourd'hui"), _irrigAdvice(w)),
      const SizedBox(height: 8),
      _advice(context, Icons.thermostat_rounded, AppColors.orange,
          _t('درجة الحرارة', 'Température'), _tempAdvice(w.temperature)),
      if (w.forecast.any((f) => f.rainProbability > 60)) ...[
        const SizedBox(height: 8),
        _advice(context, Icons.umbrella_rounded, AppColors.primary,
            _t('تنبيه الأمطار', 'Alerte pluie'),
            _t('أمطار متوقعة — لا تسمد قبل المطر', 'Pluies prévues — ne pas fertiliser')),
      ],
    ]),
  );

  Widget _advice(BuildContext context, IconData icon, Color color, String title, String body) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.txt(context), fontWeight: FontWeight.w600)),
            Text(body, style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtSec(context))),
          ])),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
        ]),
      );

  String _emoji(String c) {
    switch (c) {
      case 'clear': return '☀️';
      case 'rain': case 'drizzle': return '🌧️';
      case 'thunderstorm': return '⛈️';
      case 'snow': return '❄️';
      default: return '⛅';
    }
  }

  List<Color> _grad(String c) {
    switch (c) {
      case 'clear': return [const Color(0xFF1E88E5), const Color(0xFF42A5F5)];
      case 'rain': case 'drizzle': return [const Color(0xFF455A64), const Color(0xFF78909C)];
      case 'thunderstorm': return [const Color(0xFF37474F), const Color(0xFF546E7A)];
      default: return [const Color(0xFF1976D2), const Color(0xFF42A5F5)];
    }
  }

  String _irrigAdvice(WeatherData w) {
    if (w.humidity > 80) return _t('رطوبة عالية — قلل الري', 'Humidité élevée — réduire');
    if (w.temperature > 35) return _t('حر شديد — اسقِ مبكراً أو مساءً', 'Chaleur — irriguer tôt');
    if (w.forecast.isNotEmpty && w.forecast.first.rainProbability > 60)
      return _t('أمطار متوقعة — أوقف الري', 'Pluie prévue — arrêter');
    return _t('الوضع طبيعي — يمكن الري', 'Conditions normales');
  }

  String _tempAdvice(double temp) {
    if (temp < 5)  return _t('خطر الصقيع — احمِ النباتات', 'Risque de gel — protéger');
    if (temp > 38) return _t('حرارة شديدة — احمِ المحاصيل', 'Chaleur excessive — protéger');
    if (temp > 30) return _t('الري الصباحي أفضل', 'Irriguer le matin');
    return _t('درجة حرارة مثالية للنمو', 'Température idéale');
  }
}
