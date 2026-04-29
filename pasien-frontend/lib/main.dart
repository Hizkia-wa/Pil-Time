import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pil Time',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
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
