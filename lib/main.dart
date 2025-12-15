import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/onboarding_provider.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/providers/user_management_provider.dart';
import 'package:laporin/providers/notification_provider.dart';
import 'package:laporin/routes/app_router.dart';
import 'package:laporin/services/fcm_service.dart';
import 'firebase_options.dart';

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper configuration
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('📝 App will run in mock mode without Firebase');
    isFirebaseInitialized = false;
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://hwskzjaimgnrruxaeasu.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3c2t6amFpbWducnJ1eGFlYXN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NzY5ODgsImV4cCI6MjA4MTI1Mjk4OH0.7QrQiWJtP6kQ2WlDSBkYujH-sXpuVj35Cw99Gq1gntw',
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization failed: $e');
  }

  // Initialize Firebase Cloud Messaging
  if (isFirebaseInitialized) {
    try {
      await FCMService().initialize();
      debugPrint('✅ FCM initialized successfully');
    } catch (e) {
      debugPrint('⚠️ FCM initialization failed: $e');
    }
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp(isFirebaseEnabled: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseEnabled;

  const MyApp({super.key, required this.isFirebaseEnabled});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = AppRouter(authProvider).router;

          return MaterialApp.router(
            title: 'LaporJTI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.white,
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                centerTitle: true,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                color: AppColors.white,
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
