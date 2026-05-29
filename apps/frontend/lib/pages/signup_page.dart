import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/auth_provider.dart';

import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _farmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  final _errors = <String, String?>{};
  String _lang = 'ar';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _farmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final errs = <String, String?>{};
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (name.length < 3) errs['name'] = _t(_lang, 'الاسم يجب أن يكون 3 أحرف على الأقل', 'Nom trop court (3 min)');
    if (!email.contains('@')) errs['email'] = _t(_lang, 'يرجى إدخال بريد إلكتروني صحيح', 'Email invalide');
    if (pass.length < 6) errs['pass'] = _t(_lang, 'كلمة المرور 6 أحرف على الأقل', 'Mot de passe trop court (6 min)');
    if (pass != confirm) errs['confirm'] = _t(_lang, 'كلمتا المرور غير متطابقتين', 'Les mots de passe ne correspondent pas');
    setState(() => _errors.addAll(errs));
    return errs.isEmpty;
  }

  void _submit() async {
  _errors.clear();
  if (!_validate()) return;

  try {
    final auth = context.read<AuthProvider>();
    await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      farmName: _farmCtrl.text.trim().isEmpty ? null : _farmCtrl.text.trim(),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.surf(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.bord(context))),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.txtSec(context)),
                      ),
                    ),
                  ]),
                  SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primLight(context),
                        borderRadius: BorderRadius.circular(22),
                        // ignore: deprecated_member_use
                        border: Border.all(
                            // ignore: deprecated_member_use
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          size: 38, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(_t(_lang, 'إنشاء حساب جديد', 'Créer un compte'),
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 26),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(_t(_lang, 'أنشئ حسابك وابدأ إدارة مزرعتك', 'Créez votre compte et gérez votre ferme'),
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(builder: (_, auth, __) {
                    if (auth.state == AuthState.error &&
                        auth.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        // ignore: deprecated_member_use
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                // ignore: deprecated_member_use
                                color: AppColors.error.withOpacity(0.3))),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(auth.errorMessage!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error))),
                        ]),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _SignupField(
                      label: _t(_lang, 'الاسم الكامل', 'Nom complet'),
                      controller: _nameCtrl,
                      hint: _t(_lang, 'الاسم', 'Nom'),
                      icon: Icons.person_outline_rounded,
                      error: _errors['name']),
                  SizedBox(height: 16),
                  _SignupField(
                      label: _t(_lang, 'البريد الإلكتروني', 'Email'),
                      controller: _emailCtrl,
                      hint: 'example@farm.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isLtr: true,
                      error: _errors['email']),
                  const SizedBox(height: 16),
                  _SignupField(
                      label: _t(_lang, 'اسم المزرعة (اختياري)', 'Nom de la ferme (optionnel)'),
                      controller: _farmCtrl,
                      hint: _t(_lang, 'مزرعة النجاح', 'Ma ferme'),
                      icon: Icons.landscape_outlined,
                      error: null),
                  const SizedBox(height: 16),
                  _SignupField(
                    label: _t(_lang, 'كلمة المرور', 'Mot de passe'),
                    controller: _passCtrl,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    error: _errors['pass'],
                    suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.txtMuted(context))),
                  ),
                  SizedBox(height: 16),
                  _SignupField(
                    label: _t(_lang, 'تأكيد كلمة المرور', 'Confirmer le mot de passe'),
                    controller: _confirmCtrl,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    error: _errors['confirm'],
                    suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.txtMuted(context))),
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(builder: (_, auth, __) {
                    return _GreenButton(
                        label: _t(_lang, 'إنشاء الحساب', 'Créer le compte'),
                        isLoading: auth.isLoading,
                        onTap: _submit);
                  }),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(_t(_lang, 'تسجيل الدخول', 'Se connecter'),
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(_t(_lang, ' لديك حساب بالفعل؟ ', ' Déjà un compte ? '), style: AppTextStyles.bodySmall),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? error;
  final bool isLtr;

  const _SignupField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.error,
    this.isLtr = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.txt(context), fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: error != null ? AppColors.error : AppColors.bord(context),
                  width: error != null ? 1.5 : 1),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              textDirection: isLtr ? TextDirection.ltr : null,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.txt(context)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.txtMuted(context)),
                prefixIcon: Icon(icon, size: 20, color: AppColors.txtMuted(context)),
                suffixIcon: suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12), child: suffix)
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ],
        ],
      );
}

class _GreenButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _GreenButton(
      {required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isLoading
                // ignore: deprecated_member_use
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            // ignore: deprecated_member_use
            boxShadow: [
              BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(label, style: AppTextStyles.buttonText),
          ),
        ),
      );
}