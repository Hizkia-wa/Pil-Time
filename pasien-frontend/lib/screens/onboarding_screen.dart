import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding1.png',
      detail:
          'Solusi Digital Untuk Membantu\nPemantauan Jadwal Pasien Secara\nTerintegrasi Dan Akurat.',
      buttonLabel: 'Selanjutnya',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding2.png',
      detail:
          'Memastikan Setiap Tindakan Atau\nPemberian Obat Tercatat Dengan\nPengingat Yang Tepat Sasaran.',
      buttonLabel: 'Selanjutnya',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding3.png',
      detail:
          'Tingkatkan Efisiensi Kerja Dan Kualitas\nLayanan Kesehatan Dengan\nManajemen Jadwal Yang Lebih Baik',
      buttonLabel: 'Mulai Pantau',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.hasSeenOnboardingKey, true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: SafeArea(
        child: Column(
          children: [
            // App Title at top
            const Padding(
              padding: EdgeInsets.only(top: 32.0, bottom: 8.0),
              child: Text(
                'Pil Time',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            _buildDots(),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Illustration image
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  data.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Detail description
          Text(
            data.detail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF15BE77) // Emerald Green resmi
                  : const Color(0xFFCBD5E1), // Soft Slate
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButton() {
    final currentData = _pages[_currentPage];
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage == _pages.length - 1) {
              _completeOnboarding();
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15BE77),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF15BE77).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            currentData.buttonLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String detail;
  final String buttonLabel;

  const OnboardingData({
    required this.imagePath,
    required this.detail,
    required this.buttonLabel,
  });
}
