import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool _showPass = false;
  bool _showConfirm = false;

  bool _isPasswordValid(String val) {
    if (val.length < 8) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(val);
    final hasNumber = RegExp(r'[0-9]').hasMatch(val);
    return hasLetter && hasNumber;
  }

  bool _canSubmit(bool isLoading) {
    return _isPasswordValid(passController.text) &&
        passController.text == confirmController.text &&
        !isLoading;
  }

  void resetPassword(String email, String code) {
    if (!_isPasswordValid(passController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            "Password harus minimal 8 karakter dengan huruf dan angka!",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      );
      return;
    }

    if (passController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            "Password tidak sama",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      ResetPasswordSubmitted(
        email: email,
        password: passController.text,
        otp: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = args['email'] as String;
    final code = args['code'] as String;
    const emerald = Color(0xFF15BE77);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          Navigator.pushReplacementNamed(context, '/success');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                state.error,
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium background
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Custom Padlock Rotate Illustration as in Mockup
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F1),
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
                    child: Icon(
                      Icons.lock_open_rounded,
                      size: 72,
                      color: emerald,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title Reset Password Baru
              const Center(
                child: Text(
                  "Reset Password Baru",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Roboto',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Password Baru Input
              const Text(
                'PASSWORD BARU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                  letterSpacing: 1.1,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passController,
                obscureText: !_showPass,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan Minimal 8 Karakter',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
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
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(
                        _showPass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _showPass = !_showPass;
                        });
                      },
                    ),
                  ),
                ),
              ),
              
              // Red Text Hint as in mockup - Hilang otomatis bila password memenuhi syarat
              if (!_isPasswordValid(passController.text))
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '* Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
                
              const SizedBox(height: 20),

              // Konfirmasi Password Input
              const Text(
                'KONFIRMASI PASSWORD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                  letterSpacing: 1.1,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmController,
                obscureText: !_showConfirm,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan Ulang Password',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
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
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(
                        _showConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirm = !_showConfirm;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Perbaharui Password Button - Otomatis aktif hijau saat memenuhi syarat
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSubmit(isLoading) ? () => resetPassword(email, code) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emerald,
                    disabledBackgroundColor: const Color(0xFFC0E5D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: _canSubmit(isLoading) ? 4 : 0,
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
                          "Perbaharui Password",
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
  },
);
  }
}

