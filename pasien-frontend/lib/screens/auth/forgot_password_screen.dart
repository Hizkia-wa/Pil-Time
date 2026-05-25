import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  void sendOTP() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            "Email wajib diisi",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            'Email harus menggunakan tanda "@"',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.sendOtp(emailController.text);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushNamed(context, '/otp', arguments: emailController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            result['error'] ?? "Gagal mengirim OTP",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF15BE77);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF0F172A), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Custom Beautiful Lock Illustration as in User Mockup
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F1), // Soft emerald background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: emerald.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 72,
                          color: emerald,
                        ),
                        Positioned(
                          top: 48,
                          child: Icon(
                            Icons.help_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title Lupa Password
              const Text(
                "Lupa Password?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Masukkan alamat email yang terdaftar untuk menerima kode verifikasi OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Email Input Field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'EMAIL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                    letterSpacing: 1.1,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: "Contoh: megahteruan@gmail.com",
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: emerald, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Kirim OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading || emailController.text.isEmpty ? null : sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emerald,
                    disabledBackgroundColor: const Color(0xFFC0E5D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: isLoading ? 0 : 4,
                    shadowColor: emerald.withValues(alpha: 0.3),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Kirim Kode OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

