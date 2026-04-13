import 'package:flutter/material.dart';
import '../login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              // 🔙 Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 30),

              // 👤 FOTO PROFILE DI TENGAH
              Center(
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage("assets/images/profile.jpg"),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📦 CARD PROFILE (EXPAND)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ExpansionTile(
                  title: const Text(
                    "Hizkia Siahaan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("hizkia@email.com"),

                  children: const [
                    Divider(),

                    ProfileItem(
                        title: "NIK", value: "1234567890123456"),
                    ProfileItem(
                        title: "Tanggal Lahir", value: "2000-01-01"),
                    ProfileItem(
                        title: "Jenis Kelamin", value: "L"),
                    ProfileItem(
                        title: "No Telepon", value: "08123456789"),
                    ProfileItem(
                        title: "Alamat", value: "Medan"),

                    SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🚪 Logout
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false, // hapus semua halaman sebelumnya
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Item dalam expand
class ProfileItem extends StatelessWidget {
  final String title;
  final String value;

  const ProfileItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}