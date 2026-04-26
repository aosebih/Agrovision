import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'temes/app_colors.dart';
import 'services/api_client.dart';
import 'providers/dashboard_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/main_scaffold.dart';

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
    // Single shared ApiClient for the whole app
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AnalysisProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(apiClient)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          // Load settings on first build
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
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}
