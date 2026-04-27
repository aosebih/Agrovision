import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'temes/app_colors.dart';
import 'services/api_client.dart';
import 'providers/dashboard_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/analytics_provider.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AnalysisProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => InventoryProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(apiClient)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            settingsProvider.load();
          });

          return MaterialApp(
            title: 'زراعتي',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            builder: (context, child) =>
                Directionality(textDirection: TextDirection.rtl, child: child!),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                surface: AppColors.surface,
              ),
              scaffoldBackgroundColor: AppColors.background,
              textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
                  Theme.of(context).textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected)
                        ? Colors.white
                        : AppColors.textMuted),
                trackColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.border),
              ),
            ),
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// Switches between LoginPage and MainScaffold based on auth state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) return const MainScaffold();
        return const LoginPage();
      },
    );
  }
}
