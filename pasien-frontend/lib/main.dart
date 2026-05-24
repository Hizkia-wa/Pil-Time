import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/success_screen.dart';

/// Global key untuk navigasi dari mana saja (khususnya untuk Notifikasi)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase (wajib sebelum apapun yang pakai Firebase)
  await Firebase.initializeApp();

  // 2. Daftarkan background FCM handler SEBELUM runApp
  //    Harus top-level function
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 3. Init local notification service
  await NotificationService.instance.initialize();

  // 4. Cek apakah app dibuka dari tap notifikasi (terminated state)
  //    Jika iya, alarm screen akan muncul otomatis
  await NotificationService.instance.checkLaunchFromNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _determineInitialScreen();

    // Handle FCM ketika app di foreground:
    // Jika ada pesan FCM masuk saat app terbuka, tampilkan alarm screen langsung
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final payload = message.data['payload'] as String?;
      if (payload != null && payload.contains(':')) {
        debugPrint('[PilTime] FCM foreground → tampilkan alarm: $payload');
        NotificationService.instance.showAlarmScreen(payload);
      }
    });
  }

  Future<Widget> _determineInitialScreen() async {
    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool(AppConfig.hasSeenOnboardingKey) ?? false;

    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final session = await AuthService.getPasienSession();
      if (session != null) {
        return DashboardScreen(
          pasienId: session['pasien_id'],
          pasienNama: session['pasien_name'],
        );
      }
    }

    // User has seen onboarding but not logged in → returning user
    return const LoginScreen(isReturningUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pil Time',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF15BE77)),
      ),
      home: FutureBuilder<Widget>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/forgot': (context) => ForgotPasswordScreen(),
        '/otp': (context) => OtpVerificationScreen(),
        '/reset': (context) => ResetPasswordScreen(),
        '/success': (context) => SuccessScreen(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Splash screen yang muncul saat app menentukan rute awal
// ---------------------------------------------------------------------------
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pil Time',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF15BE77)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
