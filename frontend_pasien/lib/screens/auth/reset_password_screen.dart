import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  void resetPassword(String email, String code) async {
    // VALIDASI
    if (passController.text.isEmpty || confirmController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    if (passController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password tidak sama")));
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.resetPassword(
      email,
      passController.text,
      code,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? "Gagal reset password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = args['email'] as String;
    final code = args['code'] as String;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Reset Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            TextField(
              controller: passController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: confirmController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "Konfirmasi Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  isLoading ||
                      passController.text.isEmpty ||
                      confirmController.text.isEmpty
                  ? null
                  : () => resetPassword(email, code),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
