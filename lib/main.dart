import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK (safe fallback in test/desktop environments)
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}

  // Lock orientation to portrait for typical compass ergonomics
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set immersive dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: CompassApp(),
    ),
  );
}

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentCyan,
          surface: AppColors.surface,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
