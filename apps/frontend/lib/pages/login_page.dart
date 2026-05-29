import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/auth_provider.dart';
import 'signup_page.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _emailValid = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    setState(() => _emailValid = email.contains('@'));
    if (!_emailValid || pass.isEmpty) return;
    final lang = context.read<SettingsProvider>().settings.language;
    try {
      final auth = context.read<AuthProvider>();
      await auth.login(email: email, password: pass);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t(lang, 'حدث خطأ غير متوقع: $e', 'Erreur inattendue: $e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24),
                    // Logo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.bord(context)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset('assets/logo_app_2cp.jpg',
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(_t(lang, 'مرحباً بك', 'Bienvenue'),
                        style:
                            AppTextStyles.headlineLarge.copyWith(fontSize: 28),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(_t(lang, 'سجّل دخولك لمتابعة مزرعتك', 'Connectez-vous à votre ferme'),
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 40),

                    // Error banner
                    Consumer<AuthProvider>(builder: (_, auth, __) {
                      if (auth.state == AuthState.error &&
                          auth.errorMessage != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            // ignore: deprecated_member_use
                            border: Border.all(
                                // ignore: deprecated_member_use
                                color: AppColors.error.withOpacity(0.3)),
                          ),
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

                    // Email
                    // ignore: prefer_const_constructors
                    _Label(text: _t(lang, 'البريد الإلكتروني', 'Email')),
                    SizedBox(height: 8),
                    _Field(
                      controller: _emailCtrl,
                      hint: 'example@farm.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isError: !_emailValid,
                      errorText: _t(lang, 'يرجى إدخال بريد إلكتروني صحيح', 'Email invalide'),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    // ignore: prefer_const_constructors
                    _Label(text: _t(lang, 'كلمة المرور', 'Mot de passe')),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _passCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.txtMuted(context)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit
                    Consumer<AuthProvider>(builder: (_, auth, __) {
                      return _GreenButton(
                        label: _t(lang, 'تسجيل الدخول', 'Se connecter'),
                        isLoading: auth.isLoading,
                        onTap: _submit,
                      );
                    }),

                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage())),
                        child: Text(_t(lang, 'إنشاء حساب جديد', 'Créer un compte'),
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(_t(lang, ' ليس لديك حساب؟ ', ' Pas de compte ? '), style: AppTextStyles.bodySmall),
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

// ── Reusable sub-widgets ───────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.bodyMedium
          .copyWith(color: AppColors.txt(context), fontWeight: FontWeight.w600));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final bool isError;
  final String? errorText;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.isError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isError ? AppColors.error : AppColors.bord(context),
                  width: isError ? 1.5 : 1),
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
              textDirection: TextDirection.ltr,
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
          if (isError && errorText != null) ...[
            const SizedBox(height: 6),
            Text(errorText!,
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