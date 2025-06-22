import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renkli_zeka_ar_macera/screens/splash_screen.dart';
import 'package:renkli_zeka_ar_macera/services/stats_service.dart';

// Yeni Renk Paletimiz
class AppColors {
  static const Color primary = Color(0xFF1E88E5); // Canlı Mavi
  static const Color secondary = Color(0xFFFFB74D); // Yumuşak Turuncu
  static const Color background = Color(0xFFF5F5F5); // Çok Açık Gri
  static const Color card = Colors.white;
  static const Color text = Color(0xFF333333);
  static const Color textLight = Colors.white;
}

Future<void> main() async {
  // Uygulama başlamadan önce Flutter bağlamının hazır olduğundan emin ol
  WidgetsFlutterBinding.ensureInitialized();
  // İstatistik servisini başlat
  await StatsService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _startTime = DateTime.now();
    } else if (state == AppLifecycleState.paused) {
      if (_startTime != null) {
        final duration = DateTime.now().difference(_startTime!);
        StatsService.addSessionTime(duration.inSeconds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temel bir tema oluşturuyoruz
    final ThemeData base = ThemeData.light(useMaterial3: true);

    return MaterialApp(
      title: 'Renkli Zeka AR Macera',
      theme: base.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 2,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        cardTheme: base.cardTheme.copyWith(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: AppColors.card,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.text,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
