import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
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
  bool _isExpanded = false;

  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _noTeleponCtrl = TextEditingController();
  final _jenisKelaminCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _alamatCtrl.dispose();
    _noTeleponCtrl.dispose();
    _jenisKelaminCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    super.dispose();
  }

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

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }

  void _showLogoutDialog() {
    // Capture AuthBloc reference BEFORE opening BottomSheet,
    // because the sheet's builder gets a new context that doesn't
    // inherit the BlocProvider from the widget tree.
    final authBloc = context.read<AuthBloc>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin keluar?\nAnda perlu masuk kembali untuk melihat jadwal obat Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
                    ),
                  ),
                  onPressed: () {
                    // 1. Tutup bottom sheet
                    Navigator.of(sheetContext).pop();
                    // 2. Pop ProfileScreen (dan semua route lain) kembali ke root,
                    //    agar BlocBuilder di main.dart bisa menampilkan LoginScreen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // 3. Dispatch logout — BlocBuilder akan ubah home ke LoginScreen
                    authBloc.add(LogoutRequested());
                  },
                  child: const Text(
                    'Ya, Keluar dari Akun',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8), 
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 15, 
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _profileData?['nama'] ?? 'Nama Pasien';
    final nik = _profileData?['nik'] ?? '-';
    const emerald = Color(0xFF15BE77);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium background
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: emerald,
                  strokeWidth: 3,
                ),
              )
            : _errorMsg != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Color(0xFFFF4D4D),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal Memuat Data',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMsg!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMsg = null;
                          });
                          _loadPasienSession();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded, 
                              size: 32,
                              color: Color(0xFF0F172A),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              "Profil & Pengaturan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer to balance back button
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: emerald,
                            child: CircleAvatar(
                              radius: 51,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: const Color(0xFFE8F8F1),
                                child: Text(
                                  _getInitials(name),
                                  style: const TextStyle(
                                    color: emerald,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.edit_rounded, size: 16, color: emerald),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User Name & NIK
                    Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "NIK: $nik",
                          style: const TextStyle(
                            fontSize: 13, 
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Data Pribadi Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          onExpansionChanged: (val) {
                            setState(() {
                               _isExpanded = val;
                            });
                          },
                          leading: Icon(
                            Icons.person_outline_rounded, 
                            color: _isExpanded ? emerald : const Color(0xFF64748B),
                            size: 24,
                          ),
                          title: const Text(
                            "Data Pribadi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Roboto',
                            ),
                          ),
                          iconColor: const Color(0xFF64748B),
                          collapsedIconColor: const Color(0xFF64748B),
                          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          children: [
                            if (!_isEditing) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                      _namaCtrl.text = _profileData?['nama'] ?? '';
                                      _emailCtrl.text = _profileData?['email'] ?? '';
                                      _alamatCtrl.text = _profileData?['alamat'] ?? '';
                                      _noTeleponCtrl.text = _profileData?['no_telepon'] ?? '';
                                      _jenisKelaminCtrl.text = _profileData?['jenis_kelamin'] ?? 'Laki-laki';
                                      _tempatLahirCtrl.text = _profileData?['tempat_lahir'] ?? '';
                                      _tanggalLahirCtrl.text = _profileData?['tanggal_lahir'] ?? '';
                                    });
                                  },
                                  icon: const Icon(Icons.edit_rounded, color: emerald, size: 16),
                                  label: const Text(
                                    "Ubah Data",
                                    style: TextStyle(
                                      color: emerald,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoItem("Nama Lengkap", _profileData?['nama']),
                                    _buildInfoItem("Email", _profileData?['email']),
                                    _buildInfoItem("Alamat", _profileData?['alamat']),
                                    _buildInfoItem("NIK", _profileData?['nik']),
                                    _buildInfoItem("Jenis Kelamin", _profileData?['jenis_kelamin']),
                                    _buildInfoItem("Tanggal Lahir", _profileData?['tanggal_lahir']),
                                    _buildInfoItem("Tempat Lahir", _profileData?['tempat_lahir']),
                                    _buildInfoItem("No. Telepon", _profileData?['no_telepon']),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoItem("NIK (Tidak dapat diubah)", _profileData?['nik']),
                                    const SizedBox(height: 8),
                                    _buildEditableField("Nama Lengkap", _namaCtrl, validator: (v) {
                                      if (v == null || v.isEmpty) return 'Nama tidak boleh kosong';
                                      return null;
                                    }),
                                    _buildEditableField("Email", _emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) {
                                      if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                                      if (!v.contains('@')) return 'Email tidak valid';
                                      return null;
                                    }),
                                    _buildEditableField("Alamat", _alamatCtrl, maxLines: 2),
                                    _buildDropdownField("Jenis Kelamin", _jenisKelaminCtrl, ['Laki-laki', 'Perempuan']),
                                    _buildEditableField("Tempat Lahir", _tempatLahirCtrl),
                                    _buildDatePickerField("Tanggal Lahir", _tanggalLahirCtrl),
                                    _buildEditableField("No. Telepon", _noTeleponCtrl, keyboardType: TextInputType.phone),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 52,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF64748B),
                                                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(26),
                                                ),
                                              ),
                                              onPressed: _isSaving ? null : () {
                                                setState(() {
                                                  _isEditing = false;
                                                });
                                              },
                                              child: const Text(
                                                "Batal",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SizedBox(
                                            height: 52,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: emerald,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(26),
                                                ),
                                              ),
                                              onPressed: _isSaving ? null : _saveProfileChanges,
                                              child: _isSaving
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    )
                                                  : const Text(
                                                      "Simpan",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Keluar Akun Button (Premium Red)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2), // Soft pink/red background
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                        title: const Text(
                          "Keluar Akun",
                          style: TextStyle(
                            color: Color(0xFFEF4444), 
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        onTap: _showLogoutDialog,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final updatedData = {
        'nama': _namaCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        'no_telepon': _noTeleponCtrl.text.trim(),
        'jenis_kelamin': _jenisKelaminCtrl.text.trim(),
        'tempat_lahir': _tempatLahirCtrl.text.trim(),
        'tanggal_lahir': _tanggalLahirCtrl.text.trim(),
      };
      
      final response = await ApiService.updateProfile(
        pasienId: _pasienId!,
        data: updatedData,
      );
      
      if (response['success'] == true) {
        setState(() {
          // Sync local data
          _profileData?['nama'] = updatedData['nama'];
          _profileData?['email'] = updatedData['email'];
          _profileData?['alamat'] = updatedData['alamat'];
          _profileData?['no_telepon'] = updatedData['no_telepon'];
          _profileData?['jenis_kelamin'] = updatedData['jenis_kelamin'];
          _profileData?['tempat_lahir'] = updatedData['tempat_lahir'];
          _profileData?['tanggal_lahir'] = updatedData['tanggal_lahir'];
          
          _isEditing = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil Anda berhasil diperbarui! 🏆"),
            backgroundColor: Color(0xFF15BE77),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan: ${response['error']}"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: ${e.toString()}"),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF15BE77), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> options,
  ) {
    if (!options.contains(controller.text)) {
      controller.text = options.first;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: controller.text,
            items: options.map((opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(
                  opt,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.text = val;
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF15BE77), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
              try {
                if (controller.text.isNotEmpty) {
                  initialDate = DateTime.parse(controller.text);
                }
              } catch (_) {}
              
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF15BE77),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF0F172A),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              
              if (picked != null) {
                controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              }
            },
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              suffixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF94A3B8), size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF15BE77), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

