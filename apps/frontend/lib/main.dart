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
import 'providers/alerts_provider.dart';
import 'providers/fields_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/expense_provider.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  final apiClient = ApiClient();
  await apiClient.ready;
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<ApiClient>.value(value: apiClient),
      ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => DashboardProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => InventoryProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => AlertsProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => FieldsProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => WeatherProvider(apiClient)),
      ChangeNotifierProvider(create: (_) => ExpenseProvider(apiClient)),
    ],
    child: const _AppRoot(),
  );
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: dark ? const Color(0xFF1E293B) : AppColors.surface,
      ),
      scaffoldBackgroundColor: dark ? const Color(0xFF0F172A) : AppColors.background,
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData(brightness: brightness).textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF1E293B) : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<SettingsProvider>(
    builder: (context, sp, _) {
      final lang   = sp.settings.language;
      final isDark = sp.settings.darkMode;
      return MaterialApp(
        title: 'زراعتي',
        debugShowCheckedModeBanner: false,
        locale: Locale(lang),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme:     _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        builder: (context, child) => Directionality(
          textDirection: lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const _AuthGate(),
      );
    },
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
    builder: (_, auth, __) =>
        auth.isAuthenticated ? const MainScaffold() : const LoginPage(),
  );
}

