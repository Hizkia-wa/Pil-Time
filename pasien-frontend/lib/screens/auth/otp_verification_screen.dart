import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/dialog_helper.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();
  final otp5 = TextEditingController();
  final otp6 = TextEditingController();

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    otp4.dispose();
    otp5.dispose();
    otp6.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void verifyOTP(String email) {
    if (otp1.text.isEmpty ||
        otp2.text.isEmpty ||
        otp3.text.isEmpty ||
        otp4.text.isEmpty ||
        otp5.text.isEmpty ||
        otp6.text.isEmpty) {
      DialogHelper.showErrorDialog(
        context: context,
        title: 'Gagal',
        message: 'OTP belum lengkap',
      );
      return;
    }

    String otp = otp1.text + otp2.text + otp3.text + otp4.text + otp5.text + otp6.text;
    context.read<AuthBloc>().add(OtpVerificationSubmitted(email: email, otp: otp));
  }

  void _resendOtp(String email) {
    context.read<AuthBloc>().add(ForgotPasswordSubmitted(email: email));
  }

  Widget otpBox(TextEditingController controller, {bool autoFocus = false}) {
    const emerald = Color(0xFF15BE77);

    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          fontFamily: 'Inter',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: emerald, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    const emerald = Color(0xFF15BE77);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          Navigator.pushNamed(
            context,
            '/reset',
            arguments: {'email': state.email, 'code': state.otp},
          );
        } else if (state is ForgotPasswordSuccess) {
          DialogHelper.showSuccessDialog(
            context: context,
            title: 'Berhasil',
            message: 'Kode OTP baru telah dikirim!',
          );
          _startTimer();
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(
            context: context,
            title: 'Verifikasi Gagal',
            message: state.error,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Custom Keypad Illustration as in Mockup
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
                      Icons.mark_email_unread_rounded,
                      size: 72,
                      color: emerald,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title Masukkan Kode Verifikasi
              const Text(
                "Masukkan Kode Verifikasi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "Silakan masukkan 6 digit kode yang telah dikirimkan ke email Anda untuk melanjutkan di "),
                      const TextSpan(
                        text: "Pil-Time",
                        style: TextStyle(
                          color: emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ".\n\n"),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Row 6 OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  otpBox(otp1, autoFocus: true),
                  otpBox(otp2),
                  otpBox(otp3),
                  otpBox(otp4),
                  otpBox(otp5),
                  otpBox(otp6),
                ],
              ),
              const SizedBox(height: 32),

              // Countdown timer display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _secondsRemaining > 0
                        ? "Kirim ulang dalam $_secondsRemaining detik"
                        : "Waktu verifikasi telah habis",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Resend OTP Link
              GestureDetector(
                onTap: _secondsRemaining == 0 && !isLoading ? () => _resendOtp(email) : null,
                child: Text(
                  "Belum menerima kode? Kirim ulang",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining == 0 ? emerald : const Color(0xFF94A3B8),
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => verifyOTP(email),
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
                          "Verifikasi",
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

