import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'screens/riwayat/riwayat_konsumsi_obat.dart';

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
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

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

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nauli Reminder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF15BE77)),
      ),
      home: FutureBuilder<Widget>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}
