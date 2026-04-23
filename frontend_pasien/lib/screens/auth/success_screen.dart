import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text("Berhasil!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Password berhasil diubah"),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: Text("Kembali ke Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}