import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _pasienId;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadPasienSession();
  }

  Future<void> _loadPasienSession() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && session['pasien_id'] != null) {
        setState(() {
          _pasienId = session['pasien_id'] as int;
        });
        await _fetchProfile();
      } else {
        setState(() {
          _errorMsg = 'Session tidak ditemukan, silakan login kembali';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
      setState(() {
        _errorMsg = 'Gagal memuat session';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    if (_pasienId == null) return;

    try {
      final response = await ApiService.getProfile(pasienId: _pasienId!);
      if (response['success'] == true) {
        setState(() {
          _profileData = response['data'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = response['error'] ?? 'Gagal memuat data profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      setState(() {
        _errorMsg = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMsg != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gagal Memuat Data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMsg!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMsg = null;
                        });
                        _loadPasienSession();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : Padding(
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
                            backgroundImage: AssetImage(
                              "assets/images/profile.jpg",
                            ),
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
                        title: Text(
                          _profileData?['nama'] ?? 'Nama Pasien',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _profileData?['email'] ?? 'email@example.com',
                        ),
                        children: [
                          const Divider(),
                          ProfileItem(
                            title: "NIK",
                            value: _profileData?['nik'] ?? '-',
                          ),
                          ProfileItem(
                            title: "Tanggal Lahir",
                            value: _profileData?['tanggal_lahir'] ?? '-',
                          ),
                          ProfileItem(
                            title: "Tempat Lahir",
                            value: _profileData?['tempat_lahir'] ?? '-',
                          ),
                          ProfileItem(
                            title: "Jenis Kelamin",
                            value: _profileData?['jenis_kelamin'] ?? '-',
                          ),
                          ProfileItem(
                            title: "No Telepon",
                            value: _profileData?['no_telepon'] ?? '-',
                          ),
                          ProfileItem(
                            title: "Alamat",
                            value: _profileData?['alamat'] ?? '-',
                          ),
                          const SizedBox(height: 10),
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
                        onTap: () async {
                          await AuthService.clearSession();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
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

  const ProfileItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
