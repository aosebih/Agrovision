import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/alerts_provider.dart';
import '../providers/settings_provider.dart';
import '../pages/home_page.dart';
import '../pages/crops_page.dart';
import '../pages/settings_page.dart';
import '../pages/camera_page.dart';
import '../pages/expenses_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CameraPage()));
      return;
    }
    setState(() => _currentIndex = index);
  }

  // Camera is index 2 (not in stack), so stack indices are:
  // tab 0 → stack 0 (Home)
  // tab 1 → stack 1 (Crops)
  // tab 2 → camera (push, not in stack)
  // tab 3 → stack 2 (Expenses)
  // tab 4 → stack 3 (Settings)
  int get _pageIndex => _currentIndex > 2 ? _currentIndex - 1 : _currentIndex;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Directionality(
      textDirection: lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: IndexedStack(
          index: _pageIndex,
          children: const [
            HomePage(),
            CropsPage(),
            ExpensesPage(),
            SettingsPage(),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          lang: lang,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String lang;
  const _BottomNavBar(
      {required this.currentIndex,
      required this.onTap,
      required this.lang});

  String _t(String ar, String fr) => lang == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) => Directionality(
        // Always LTR so Home stays left and Settings stays right
        textDirection: TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            border: Border(top: BorderSide(color: AppColors.bord(context))),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shad(context),
                  blurRadius: 20,
                  offset: const Offset(0, -4))
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home — always left
                  Consumer<AlertsProvider>(
                    builder: (context, alerts, _) => _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: _t('الرئيسية', 'Accueil'),
                      isActive: currentIndex == 0,
                      badge: alerts.unreadCount > 0
                          ? alerts.unreadCount
                          : null,
                      onTap: () => onTap(0),
                    ),
                  ),
                  _NavItem(
                      icon: Icons.eco_outlined,
                      activeIcon: Icons.eco_rounded,
                      label: _t('محاصيلي', 'Cultures'),
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1)),
                  // Camera FAB — center
                  GestureDetector(
                    onTap: () => onTap(2),
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                  _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet_rounded,
                      label: _t('المالية', 'Finances'),
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3)),
                  // Settings — always right
                  _NavItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: _t('الإعدادات', 'Paramètres'),
                      isActive: currentIndex == 4,
                      onTap: () => onTap(4)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.isActive,
      this.badge,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Stack(clipBehavior: Clip.none, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    size: 22,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.navIn(context)),
              ),
              if (badge != null)
                Positioned(
                  top: -5,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: Text(badge! > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ]),
            const SizedBox(height: 3),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.navIn(context),
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400)),
          ]),
        ),
      );
}
