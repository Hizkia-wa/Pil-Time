import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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

  bool isLoading = false;

  void verifyOTP(String email) async {
    // VALIDASI OTP
    if (otp1.text.isEmpty ||
        otp2.text.isEmpty ||
        otp3.text.isEmpty ||
        otp4.text.isEmpty ||
        otp5.text.isEmpty ||
        otp6.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP belum lengkap")));
      return;
    }

    String otp =
        otp1.text + otp2.text + otp3.text + otp4.text + otp5.text + otp6.text;

    setState(() => isLoading = true);

    final result = await ApiService.verifyOtp(email, otp);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushNamed(
        context,
        '/reset',
        arguments: {'email': email, 'code': otp},
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'] ?? "OTP salah")));
    }
  }

  Widget otpBox(TextEditingController controller, {bool autoFocus = false}) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.green),
              SizedBox(height: 20),

              Text(
                "Verifikasi OTP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),
              Text("Kode dikirim ke $email"),

              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  otpBox(otp1, autoFocus: true),
                  otpBox(otp2),
                  otpBox(otp3),
                  otpBox(otp4),
                  otpBox(otp5),
                  otpBox(otp6),
                ],
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : () => verifyOTP(email),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Verifikasi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
