import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(onTap: () {}, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: const Icon(Icons.settings_outlined, size: 20, color: AppColors.textSecondary))),
            Text('الملف الشخصي', style: AppTextStyles.titleLarge),
          ]),
          const SizedBox(height: 24),
          // Avatar
          Stack(alignment: Alignment.bottomLeft, children: [
            Container(width: 90, height: 90, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 2)),
              child: const Icon(Icons.person_rounded, size: 54, color: AppColors.primary)),
            Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white)),
          ]),
          const SizedBox(height: 14),
          Text('أحمد المنصور', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text('مزرعة النور', style: AppTextStyles.bodySmall),
          ]),
          const SizedBox(height: 20),
          // Stats row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              _stat('12.5', 'إجمالي المساحة', 'هكتار', AppColors.primary),
              _divider(),
              _stat('8', 'المحاصيل النشطة', 'أنواع', AppColors.info),
              _divider(),
              _stat('92%', 'توقع المحصول', 'دقة التوقع', AppColors.warning),
            ]),
          ),
          const SizedBox(height: 20),
          // Menu items
          _menuTile(Icons.person_outline_rounded, 'المعلومات الشخصية', onTap: () {}),
          const SizedBox(height: 8),
          _menuTile(Icons.card_membership_rounded, 'خطة الاشتراك',
              subtitle: 'الخطة الاحترافية نشطة', subtitleColor: AppColors.primary, onTap: () {}),
          const SizedBox(height: 8),
          _menuTile(Icons.shield_outlined, 'الأمان', onTap: () {}),
          const SizedBox(height: 8),
          _menuTile(Icons.help_outline_rounded, 'المساعدة والدعم', onTap: () {}),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text('→ تسجيل الخروج', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      )),
    ),
  );

  Widget _stat(String val, String label, String unit, Color color) => Expanded(child: Column(children: [
    Text(val, style: AppTextStyles.headlineMedium.copyWith(color: color)),
    Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
    Text(unit, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
  ]));

  Widget _divider() => Container(width: 1, height: 50, color: AppColors.border);

  Widget _menuTile(IconData icon, String title, {String? subtitle, Color? subtitleColor, VoidCallback? onTap}) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        const Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.textMuted),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          if (subtitle != null) Text(subtitle, style: AppTextStyles.caption.copyWith(color: subtitleColor ?? AppColors.textMuted)),
        ]),
        const SizedBox(width: 12),
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.textSecondary)),
      ]),
    ));
}
