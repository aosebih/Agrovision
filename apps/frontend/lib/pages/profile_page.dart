import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: Consumer2<SettingsProvider, DashboardProvider>(
            builder: (context, sp, dp, _) {
              final s = sp.settings;
              final data = dp.data;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surf(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.bord(context)),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              size: 18, color: AppColors.txtSec(context)),
                        ),
                      ),
                      Text('الملف الشخصي', style: AppTextStyles.titleLarge),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Avatar
                  Stack(alignment: Alignment.bottomLeft, children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primLight(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.bord(context), width: 2),
                      ),
                      child: Icon(Icons.person_rounded,
                          size: 54, color: AppColors.primary),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    s.userName.isNotEmpty ? s.userName : '—',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 4),

                  // Farm name
                  if (s.farmName != null && s.farmName!.isNotEmpty)
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.storefront_outlined,
                          size: 14, color: AppColors.txtMuted(context)),
                      SizedBox(width: 5),
                      Text(s.farmName!, style: AppTextStyles.bodySmall),
                    ]),

                  // Email
                  if (s.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.email_outlined,
                          size: 14, color: AppColors.txtMuted(context)),
                      SizedBox(width: 5),
                      Text(s.email, style: AppTextStyles.bodySmall),
                    ]),
                  ],

                  const SizedBox(height: 20),

                  // Stats row — real data from DashboardProvider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.bord(context)),
                    ),
                    child: Row(children: [
                      _stat(
                        data != null ? '${data.totalCrops}' : '—',
                        'المحاصيل النشطة',
                        'محصول',
                        AppColors.primary,
                      ),
                      _divider(),
                      _stat(
                        data != null
                            ? '${data.totalIrrigationEvents}'
                            : '—',
                        'أحداث الري',
                        'إجمالي',
                        AppColors.warning,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Menu items
                  _menuTile(Icons.person_outline_rounded, 'المعلومات الشخصية',
                      onTap: () => _showPersonalInfo(context)),

                  const SizedBox(height: 8),
                  _menuTile(Icons.shield_outlined, 'تغيير كلمة المرور', onTap: () => _showChangePassword(context)),
                  const SizedBox(height: 8),
                  _menuTile(Icons.help_outline_rounded, 'المساعدة والدعم',
                      onTap: () {}),
                  const SizedBox(height: 24),

                  const SizedBox(height: 8),
                  _menuTile(Icons.delete_forever_rounded, 'حذف الحساب',
                      subtitleColor: AppColors.error,
                      subtitle: 'حذف نهائي لا يمكن التراجع عنه',
                      onTap: () => _confirmDeleteAccount(context)),
                  const SizedBox(height: 24),
                  // Logout
                  GestureDetector(
                    onTap: () {
                      context.read<AuthProvider>().logout();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'تسجيل الخروج',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stat(String val, String label, String unit, Color color) =>
      Expanded(
        child: Column(children: [
          Text(val,
              style: AppTextStyles.headlineMedium.copyWith(color: color)),
          Text(label,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          Text(unit,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.txtMuted(context))),
        ]),
      );

  Widget _divider() =>
      Container(width: 1, height: 50, color: AppColors.bord(context));

  Widget _menuTile(IconData icon, String title,
          {String? subtitle, Color? subtitleColor, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bord(context)),
          ),
          child: Row(children: [
            Icon(Icons.chevron_left_rounded,
                size: 18, color: AppColors.txtMuted(context)),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.txt(context))),
              if (subtitle != null)
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: subtitleColor ?? AppColors.txtMuted(context))),
            ]),
            SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AppColors.surfAlt(context),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: AppColors.txtSec(context)),
            ),
          ]),
        ),
      );
  void _showChangePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20,
            MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.bord(context),
                  borderRadius: BorderRadius.circular(2))),
          Text('تغيير كلمة المرور',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 20),
          _pwField(context, oldCtrl, 'كلمة المرور الحالية'),
          const SizedBox(height: 12),
          _pwField(context, newCtrl, 'كلمة المرور الجديدة'),
          const SizedBox(height: 12),
          _pwField(context, confirmCtrl, 'تأكيد كلمة المرور الجديدة'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمتا المرور غير متطابقتين')));
                return;
              }
              if (newCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل')));
                return;
              }
              try {
                await context.read<SettingsProvider>().changePassword(newCtrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));
                }
              } catch (_) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فشل تغيير كلمة المرور')));
              }
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                  color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text('حفظ',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pwField(BuildContext context, TextEditingController ctrl, String hint) =>
      Container(
        decoration: BoxDecoration(
            color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bord(context))),
        child: TextField(
          controller: ctrl,
          obscureText: true,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.txt(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context)),
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.txtMuted(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      );

  // ── Personal info sheet ─────────────────────────────────────────────────
  void _showPersonalInfo(BuildContext context) {
    final sp = context.read<SettingsProvider>();
    final s = sp.settings;
    final nameCtrl  = TextEditingController(text: s.userName);
    final farmCtrl  = TextEditingController(text: s.farmName ?? '');
    final emailCtrl = TextEditingController(text: s.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: AppColors.bord(context),
                borderRadius: BorderRadius.circular(2)),
          ),
          Text('المعلومات الشخصية',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 20),
          _infoField(context, nameCtrl,  'الاسم',              Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _infoField(context, farmCtrl,  'اسم المزرعة',        Icons.storefront_outlined),
          const SizedBox(height: 12),
          _infoField(context, emailCtrl, 'البريد الإلكتروني',  Icons.email_outlined),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              try {
                await sp.updateProfile(
                  userName:  nameCtrl.text.trim(),
                  farmName:  farmCtrl.text.trim(),
                  email:     emailCtrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ المعلومات بنجاح')));
                }
              } catch (_) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فشل حفظ المعلومات')));
              }
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Text('حفظ',
                      style: AppTextStyles.buttonText
                          .copyWith(color: Colors.white))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoField(BuildContext context, TextEditingController ctrl,
      String hint, IconData icon) =>
      Container(
        decoration: BoxDecoration(
            color: AppColors.surfAlt(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bord(context))),
        child: TextField(
          controller: ctrl,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.txt(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall
                .copyWith(color: AppColors.txtMuted(context)),
            prefixIcon: Icon(icon, size: 18, color: AppColors.txtMuted(context)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      );

  // ── Delete / reset account ────────────────────────────────────────────────
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surf(context),
          title: const Text('حذف الحساب نهائياً؟'),
          content: const Text(
              'سيتم مسح جميع البيانات المحلية وتسجيل خروجك فوراً.\n'
              'إذا كانت بياناتك محفوظة على الخادم فستحتاج إلى حذفها يدوياً.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // 1. Try backend delete (best-effort)
                  try {
                    final api = context.read<ApiClient>();
                    await api.delete('/users/me');
                  } catch (_) {}
                  // 2. Wipe ALL local SharedPreferences data
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // 3. Clear in-memory token and log out
                  if (context.mounted) {
                    await context.read<ApiClient>().clearToken();
                    context.read<AuthProvider>().logout();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('فشل الحذف: $e'),
                        backgroundColor: AppColors.error));
                  }
                }
              },
              child: Text('حذف الحساب',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

}