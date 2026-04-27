import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_page.dart';
import 'alerts_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Consumer<SettingsProvider>(
            builder: (context, sp, _) {
              final s = sp.settings;
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          child: Text('الإعدادات',
                              style: AppTextStyles.titleLarge)),
                      _profileCard(s.userName),
                      if (sp.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(sp.errorMessage!,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.error))),
                      ],
                      const SizedBox(height: 20),
                      Text('الإشعارات',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _toggle(
                          context,
                          Icons.notifications_outlined,
                          AppColors.primary,
                          AppColors.primaryLight,
                          'تفعيل الإشعارات',
                          'استقبال جميع الإشعارات',
                          s.notificationsEnabled,
                          (v) => sp.toggleNotifications(v)),
                      const SizedBox(height: 8),
                      _toggle(
                          context,
                          Icons.wb_cloudy_outlined,
                          AppColors.info,
                          AppColors.blueLight,
                          'تنبيهات الطقس',
                          'إشعار عند تغير الطقس',
                          s.weatherAlerts,
                          (v) => sp.toggleWeatherAlerts(v)),
                      const SizedBox(height: 8),
                      _toggle(
                          context,
                          Icons.inventory_2_outlined,
                          AppColors.orange,
                          AppColors.orangeLight,
                          'تنبيهات المخزون',
                          'إشعار عند انخفاض المخزون',
                          s.storageAlerts,
                          (v) => sp.toggleStorageAlerts(v)),
                      const SizedBox(height: 20),
                      Text('التطبيق',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _toggle(
                          context,
                          Icons.dark_mode_outlined,
                          AppColors.textSecondary,
                          AppColors.surfaceAlt,
                          'الوضع الداكن',
                          'تغيير مظهر التطبيق',
                          s.darkMode,
                          (v) => sp.toggleDarkMode(v)),
                      const SizedBox(height: 8),
                      _navTile(Icons.language_rounded, AppColors.info,
                          AppColors.blueLight, 'اللغة',
                          trail: s.language == 'ar' ? 'العربية' : s.language),
                      const SizedBox(height: 8),
                      _navTile(Icons.location_on_outlined, AppColors.primary,
                          AppColors.primaryLight, 'الموقع',
                          trail: s.location),
                      const SizedBox(height: 20),
                      Text('الحساب',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _navTile(
                          Icons.person_outline_rounded,
                          AppColors.textSecondary,
                          AppColors.surfaceAlt,
                          'الملف الشخصي',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfilePage()))),
                      const SizedBox(height: 8),
                      _navTile(Icons.notifications_outlined, AppColors.error,
                          const Color(0xFFFEF2F2), 'التنبيهات',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AlertsPage()))),
                      const SizedBox(height: 8),
                      _navTile(Icons.logout_rounded, AppColors.error,
                          const Color(0xFFFEF2F2), 'تسجيل الخروج',
                          titleColor: AppColors.error,
                          onTap: () => context.read<AuthProvider>().logout()),
                      const SizedBox(height: 100),
                    ]),
              );
            },
          ),
        ),
      );

  Widget _profileCard(String name) => CardShell(
          child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 2),
          Text('john.smith@farm.com', style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          const StatusBadge(
              label: 'مزارع محترف',
              color: AppColors.primaryDark,
              bg: AppColors.primaryLight),
        ]),
        const Spacer(),
        Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.person_rounded,
                size: 36, color: AppColors.textMuted)),
      ]));

  Widget _toggle(BuildContext context, IconData icon, Color iColor, Color iBg,
          String title, String sub, bool val, ValueChanged<bool> onChange) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          // ignore: deprecated_member_use
          Switch.adaptive(
              // ignore: deprecated_member_use
              value: val,
              onChanged: onChange,
              // ignore: deprecated_member_use
              activeColor: AppColors.primary),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary)),
            Text(sub, style: AppTextStyles.caption),
          ]),
          const SizedBox(width: 12),
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 17, color: iColor)),
        ]),
      );

  Widget _navTile(IconData icon, Color iColor, Color iBg, String title,
          {String? trail, Color? titleColor, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.chevron_left_rounded,
                size: 18, color: AppColors.textMuted),
            const Spacer(),
            if (trail != null) ...[
              Text(trail,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 8)
            ],
            Text(title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: titleColor ?? AppColors.textPrimary)),
            const SizedBox(width: 12),
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 17, color: iColor)),
          ]),
        ),
      );
}
