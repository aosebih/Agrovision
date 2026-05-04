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
  Widget build(BuildContext context) {
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
      child: const _AppRoot(),
    );
  }
}

// Stateful so we can call SettingsProvider.load() exactly once in initState,
// avoiding the rebuild loop that occurred when addPostFrameCallback was placed
// inside the Consumer builder (which re-registered the callback on every build).
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    // Safe: runs after the first frame, never during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
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
  }
}

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