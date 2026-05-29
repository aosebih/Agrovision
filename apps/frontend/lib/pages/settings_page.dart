import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Required packages (add to pubspec.yaml if not present):
//   geolocator: ^12.0.0
//   geocoding: ^3.0.0
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/remote/settings_model.dart';
import 'profile_page.dart';
import 'alerts_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg(context),
    body: SafeArea(
      child: Consumer<SettingsProvider>(
        builder: (context, sp, _) {
          final s = sp.settings;
          final lang = s.language;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Text(_t(lang, 'الإعدادات', 'Paramètres'),
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.txt(context))),
              ),
              _profileCard(context, s),
              if (sp.errorMessage != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                  child: Text(sp.errorMessage!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                ),
              ],
              const SizedBox(height: 20),
              _sectionTitle(context, _t(lang, 'الإشعارات', 'Notifications')),
              const SizedBox(height: 10),
              _toggle(context, Icons.notifications_outlined, AppColors.primary, AppColors.primLight(context),
                  _t(lang, 'تفعيل الإشعارات', 'Activer les notifications'),
                  _t(lang, 'استقبال جميع الإشعارات', 'Recevoir toutes les notifications'),
                  s.notificationsEnabled, (v) => sp.toggleNotifications(v)),
              SizedBox(height: 8),
              _toggle(context, Icons.wb_cloudy_outlined, AppColors.info, AppColors.blLight(context),
                  _t(lang, 'تنبيهات الطقس', 'Alertes météo'),
                  _t(lang, 'إشعار عند تغير الطقس', 'Notif. changement météo'),
                  s.weatherAlerts, (v) => sp.toggleWeatherAlerts(v)),
              SizedBox(height: 8),
              _toggle(context, Icons.inventory_2_outlined, AppColors.orange, AppColors.orgLight(context),
                  _t(lang, 'تنبيهات المخزون', 'Alertes de stock'),
                  _t(lang, 'إشعار عند انخفاض المخزون', 'Notif. stock bas'),
                  s.storageAlerts, (v) => sp.toggleStorageAlerts(v)),
              SizedBox(height: 20),
              _sectionTitle(context, _t(lang, 'التطبيق', 'Application')),
              const SizedBox(height: 10),
              // Dark mode
              _toggle(context, Icons.dark_mode_outlined, AppColors.txtSec(context), AppColors.surfAlt(context),
                  _t(lang, 'الوضع الداكن', 'Mode sombre'),
                  _t(lang, 'تغيير مظهر التطبيق', "Changer l'apparence"),
                  s.darkMode, (v) => sp.toggleDarkMode(v)),
              SizedBox(height: 8),
              // Language selector
              _langTile(context, s, sp),
              const SizedBox(height: 8),
              _LocationTile(lang: lang),
              SizedBox(height: 20),
              _sectionTitle(context, _t(lang, 'الحساب', 'Compte')),
              const SizedBox(height: 10),
              _navTile(context, Icons.person_outline_rounded, AppColors.txtSec(context), AppColors.surfAlt(context),
                  _t(lang, 'الملف الشخصي', 'Profil'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
              const SizedBox(height: 8),
              _navTile(context, Icons.notifications_outlined, AppColors.error, const Color(0xFFFEF2F2),
                  _t(lang, 'التنبيهات', 'Alertes'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsPage()))),
              const SizedBox(height: 8),
              _navTile(context, Icons.logout_rounded, AppColors.error, const Color(0xFFFEF2F2),
                  _t(lang, 'تسجيل الخروج', 'Se déconnecter'),
                  titleColor: AppColors.error,
                  onTap: () => context.read<AuthProvider>().logout()),
              const SizedBox(height: 100),
            ]),
          );
        },
      ),
    ),
  );

  Widget _sectionTitle(BuildContext context, String title) =>
      Text(title, style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.txtMuted(context), fontWeight: FontWeight.w600));

  Widget _langTile(BuildContext context, RemoteSettings s, SettingsProvider sp) {
    final langs = [
      {'code': 'ar', 'label': 'العربية', 'flag': '🇩🇿'},
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
    ];
    final cur = langs.firstWhere((l) => l['code'] == s.language, orElse: () => langs[0]);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surf(context),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.bord(context), borderRadius: BorderRadius.circular(2))),
            Text(s.language == 'fr' ? 'Choisir la langue' : 'اختر اللغة',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
            const SizedBox(height: 20),
            ...langs.map((l) {
              final sel = l['code'] == s.language;
              return GestureDetector(
                onTap: () { sp.changeLanguage(l['code']!); Navigator.pop(context); },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primLight(context) : AppColors.surfAlt(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.bord(context)),
                  ),
                  child: Row(children: [
                    if (sel)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                    else
                      const SizedBox(width: 20),
                    const Spacer(),
                    Text('${l['flag']}  ${l['label']}',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: sel ? AppColors.primary : AppColors.txt(context),
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bord(context))),
        child: Row(children: [
          Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.txtMuted(context)),
          const Spacer(),
          Text('${cur['flag']}  ${cur['label']}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
          SizedBox(width: 8),
          Text(s.language == 'fr' ? 'Langue' : 'اللغة',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.txt(context))),
          SizedBox(width: 12),
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.blLight(context), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language_rounded, size: 17, color: AppColors.info)),
        ]),
      ),
    );
  }

  Widget _profileCard(BuildContext context, RemoteSettings s) => CardShell(
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(s.userName.isNotEmpty ? s.userName : '—',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
        SizedBox(height: 2),
        Text(s.email.isNotEmpty ? s.email : '—',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtSec(context))),
        if (s.farmName != null && s.farmName!.isNotEmpty) ...[
          SizedBox(height: 6),
          StatusBadge(label: s.farmName!, color: AppColors.primaryDark, bg: AppColors.primaryLight),
        ],
      ]),
      const Spacer(),
      Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
            color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bord(context))),
        child: Icon(Icons.person_rounded, size: 36, color: AppColors.txtMuted(context)),
      ),
    ]),
  );

  Widget _toggle(BuildContext context, IconData icon, Color iColor, Color iBg,
      String title, String sub, bool val, ValueChanged<bool> onChange) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.surf(context), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bord(context))),
        child: Row(children: [
          Switch.adaptive(value: val, onChanged: onChange, activeColor: AppColors.primary),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.txt(context))),
            Text(sub, style: AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
          ]),
          const SizedBox(width: 12),
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: iBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 17, color: iColor)),
        ]),
      );

  Widget _navTile(BuildContext context, IconData icon, Color iColor, Color iBg, String title,
      {String? trail, Color? titleColor, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.surf(context), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bord(context))),
          child: Row(children: [
            Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.txtMuted(context)),
            const Spacer(),
            if (trail != null && trail.isNotEmpty) ...[
              Text(trail, style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
              SizedBox(width: 8),
            ],
            Text(title, style: AppTextStyles.bodyMedium.copyWith(
                color: titleColor ?? AppColors.txt(context))),
            const SizedBox(width: 12),
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: iBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 17, color: iColor)),
          ]),
        ),
      );
}

// ── Location tile ─────────────────────────────────────────────────────────────
/// Tapping this tile requests the device location, reverse-geocodes it to a
/// city/locality name, and saves it via SettingsProvider.
class _LocationTile extends StatefulWidget {
  final String lang;
  const _LocationTile({required this.lang});

  @override
  State<_LocationTile> createState() => _LocationTileState();
}

class _LocationTileState extends State<_LocationTile> {
  bool _busy = false;

  String _t(String ar, String fr) => widget.lang == 'fr' ? fr : ar;

  Future<void> _detectLocation() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      // 1. Check / request permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_t(
              'لم يتم منح إذن الموقع',
              'Permission de localisation refusée',
            )),
          ));
        }
        return;
      }

      // 2. Get position (balanced accuracy keeps it fast)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      // 3. Reverse-geocode to a human-readable name
      String locationLabel;
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        final p = placemarks.isNotEmpty ? placemarks.first : null;
        // Build "City, Country" from whatever fields are available
        final parts = <String>[
          if (p?.locality != null && p!.locality!.isNotEmpty) p.locality!,
          if (p?.administrativeArea != null &&
              p!.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
          if (p?.country != null && p!.country!.isNotEmpty) p.country!,
        ];
        locationLabel = parts.isNotEmpty
            ? parts.take(2).join(', ')
            : '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      } catch (_) {
        // Reverse-geocoding failed — fall back to raw coordinates
        locationLabel =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      }

      // 4. Persist via provider
      if (mounted) {
        await context.read<SettingsProvider>().updateLocation(locationLabel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t(
            'تعذر تحديد الموقع',
            'Impossible de déterminer la localisation',
          )),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final location = sp.settings.location;

    return GestureDetector(
      onTap: _detectLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bord(context)),
        ),
        child: Row(children: [
          // Left: loading spinner or chevron
          _busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(Icons.chevron_left_rounded,
                  size: 18, color: AppColors.txtMuted(context)),
          const Spacer(),
          // Current location value (if any)
          if (location.isNotEmpty) ...[
            Text(
              location,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.txtMuted(context)),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _t('الموقع', 'Localisation'),
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.txt(context)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primLight(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _busy
                ? const SizedBox.shrink()
                : const Icon(Icons.location_on_outlined,
                    size: 17, color: AppColors.primary),
          ),
        ]),
      ),
    );
  }
}