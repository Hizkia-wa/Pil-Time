import 'package:flutter/material.dart';

class ShowProfile extends StatelessWidget {
  const ShowProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            const SizedBox(height: 40),

            // Avatar
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage("assets/images/profile.jpg"),
            ),

            const SizedBox(height: 16),

            const Text(
              "Hizkia Siahaan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Info list (simple, bukan card besar)
            Expanded(
              child: ListView(
                children: const [
                  ProfileRow(title: "Email", value: "hizkia@email.com"),
                  ProfileRow(title: "NIK", value: "1234567890123456"),
                  ProfileRow(title: "Tanggal Lahir", value: "2000-01-01"),
                  ProfileRow(title: "Jenis Kelamin", value: "L"),
                  ProfileRow(title: "No Telepon", value: "08123456789"),
                  ProfileRow(title: "Alamat", value: "Medan"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String title;
  final String value;

  const ProfileRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // garis tipis seperti di gambar
        Divider(
          color: Colors.white.withValues(alpha: 0.3),
          thickness: 0.8,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}