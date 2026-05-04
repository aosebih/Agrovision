import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../pages/home_page.dart';
import '../pages/crops_page.dart';
import '../pages/analytics_page.dart';
import '../pages/settings_page.dart';
import '../pages/camera_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // 0=Home 1=Crops 2=camera(push) 3=Analytics 4=Settings
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CameraPage()));
      return;
    }
    setState(() => _currentIndex = index);
  }

  // Tab index → page index (slot 2 is camera push, not a tab)
  int get _pageIndex => _currentIndex > 2 ? _currentIndex - 1 : _currentIndex;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _pageIndex,
            children: const [
              HomePage(),
              CropsPage(),
              AnalyticsPage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: _BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      );
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'الإعدادات',
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4)),
                _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'التحليلات',
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3)),
                // Camera FAB
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
                            // ignore: deprecated_member_use
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
                    icon: Icons.eco_outlined,
                    activeIcon: Icons.eco_rounded,
                    label: 'محاصيلي',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1)),
                _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'الرئيسية',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0)),
              ],
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    size: 22,
                    color:
                        isActive ? AppColors.primary : AppColors.navInactive),
              ),
              const SizedBox(height: 3),
              Text(label,
                  style: AppTextStyles.caption.copyWith(
                      color:
                          isActive ? AppColors.primary : AppColors.navInactive,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      );
}