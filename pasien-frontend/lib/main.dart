import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_config.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/success_screen.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/notifikasi/notifikasi_bloc.dart';

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
  // AuthBloc dibuat di sini supaya hidup selama app berjalan
  // dan bisa diakses oleh SEMUA screen via MaterialApp builder
  late final AuthBloc _authBloc;
  // NotifikasiBloc juga dibuat sekali di sini agar satu instance
  // dipakai di seluruh app — termasuk route yang dipush via navigatorKey
  late final NotifikasiBloc _notifikasiBloc;
  bool _hasSeenOnboarding = false;
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _notifikasiBloc = NotifikasiBloc();
    _initApp();

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

  Future<void> _initApp() async {
    // Cek onboarding terlebih dahulu, BARU dispatch AuthCheckRequested
    // sehingga BlocBuilder sudah terpasang ketika state berubah → tidak ada race condition
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool(AppConfig.hasSeenOnboardingKey) ?? false;

    if (mounted) {
      setState(() => _initDone = true);
      // Dispatch SETELAH widget ter-mount supaya BlocBuilder tidak kehilangan event
      if (_hasSeenOnboarding) {
        _authBloc.add(AuthCheckRequested());
      }
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _notifikasiBloc.close();
    super.dispose();
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
      // ✅ builder dijalankan untuk SETIAP route/screen yang dibuka.
      // Dengan membungkus child dalam BlocProvider.value, semua screen
      // di seluruh app (termasuk yang dipush via Navigator) mendapat
      // akses ke AuthBloc yang sama — tanpa perlu pass manual per-route.
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: _authBloc),
            // BlocProvider.value agar semua route (termasuk via navigatorKey)
            // mendapat instance NotifikasiBloc yang SAMA
            BlocProvider<NotifikasiBloc>.value(value: _notifikasiBloc),
          ],
          child: child!,
        );
      },
      home: !_initDone
          // Masih loading SharedPreferences → tampilkan splash
          ? const _SplashScreen()
          : !_hasSeenOnboarding
              // Belum onboarding → arahkan ke onboarding
              ? const OnboardingScreen()
              // Sudah onboarding → BlocBuilder menentukan Login atau Dashboard
              : BlocBuilder<AuthBloc, AuthState>(
                  bloc: _authBloc,
                  // Hanya rebuild saat status auth benar-benar berubah
                  buildWhen: (previous, current) {
                    if (current is AuthLoading) return false;
                    return true;
                  },
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return DashboardScreen(
                        pasienId: state.session['pasien_id'],
                        pasienNama: state.session['pasien_name'],
                      );
                    } else if (state is AuthInitial || state is AuthLoading) {
                      return const _SplashScreen();
                    } else {
                      return const LoginScreen(isReturningUser: true);
                    }
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
