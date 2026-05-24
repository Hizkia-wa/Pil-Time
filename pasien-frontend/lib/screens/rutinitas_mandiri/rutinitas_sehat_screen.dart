import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'tambah_rutinitas_screen.dart';
import '../obat_mandiri/tambah_jadwal_konsumsi_obat_mandiri.dart';

class RutinitasSehatScreen extends StatefulWidget {
  final int initialIndex;
  const RutinitasSehatScreen({super.key, this.initialIndex = 0});

  @override
  State<RutinitasSehatScreen> createState() => _RutinitasSehatScreenState();
}

class _RutinitasSehatScreenState extends State<RutinitasSehatScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgPage = Color(0xFFF8FAFC); // Premium soft background
  static const Color _green = Color(0xFF15BE77); // Style guide Emerald Green
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  List<dynamic> _listObat = [];
  List<dynamic> _listRutinitas = [];
  int _streakHari = 0;
  bool _isLoading = true;
  int? _pasienId;
  late TabController _tabController;

  String get _baseUrl => "${ApiService.baseUrl}/api/pasien";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadPasienSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPasienSession() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && session['pasien_id'] != null) {
        setState(() {
          _pasienId = session['pasien_id'] as int;
        });
        await _initData();
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _initData() async {
    if (!mounted || _pasienId == null) return;
    setState(() => _isLoading = true);
    try {
      final headers = await _getAuthHeaders();

      final obatResponse = await http.get(
        Uri.parse("$_baseUrl/obat-mandiri"),
        headers: headers,
      );

      final rutinitasResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas"),
        headers: headers,
      );

      final streakResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas/streak/$_pasienId"),
        headers: headers,
      );

      if (obatResponse.statusCode == 200) {
        final obatData = jsonDecode(obatResponse.body);
        setState(() {
          _listObat = obatData['data'] ?? [];
        });
      }

      if (rutinitasResponse.statusCode == 200) {
        final rutinitasData = jsonDecode(rutinitasResponse.body);
        setState(() {
          _listRutinitas = rutinitasData['data'] ?? [];
        });
      }

      if (streakResponse.statusCode == 200) {
        final streakData = jsonDecode(streakResponse.body);
        setState(() {
          _streakHari = streakData['current_streak'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Gagal load data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgPage,
        body: SafeArea(
          child: Column(
            children: [
              // ─── APP BAR (CUSTOM ERGONOMIC) ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 24, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: _textPrimary,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Rutinitas Sehat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        fontFamily: 'Roboto',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStreakCard(),
              ),
              
              const SizedBox(height: 12),
              
              // Custom styled TabBar inside white container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _textPrimary.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab, // Membagi rata tab indikator antara Obat dan Rutinitas
                  indicatorColor: _green,
                  indicatorWeight: 0,
                  indicator: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: _textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  tabs: const [
                    Tab(text: "Obat"),
                    Tab(text: "Rutinitas"),
                  ],
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildObatSection(),
                    _buildListSection(_listRutinitas, "rutinitas"),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildTambahButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text("🏆", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Text(
                "KEPATUHAN KAMU",
                style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$_streakHari Hari Beruntun!",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Roboto',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Mantap sekali! Pertahankan terus kebiasaan minum obat sehatmu ini ya.",
            style: TextStyle(
              color: Color(0xFFECFDF5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObatSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _green,
          strokeWidth: 3,
        ),
      );
    }

    if (_listObat.isEmpty) {
      return _buildEmptyState("Belum Ada Jadwal Obat Mandiri", "Tambahkan obat mandiri pertama Anda sekarang.");
    }

    return RefreshIndicator(
      onRefresh: _initData,
      color: _green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
        itemCount: _listObat.length,
        itemBuilder: (context, index) {
          final item = _listObat[index];
          return _buildObatCard(item);
        },
      ),
    );
  }

  Widget _buildListSection(List<dynamic> list, String type) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _green,
          strokeWidth: 3,
        ),
      );
    }

    if (list.isEmpty) {
      return _buildEmptyState("Belum Ada Jadwal Rutinitas", "Mulai hidup sehat dengan menambahkan rutinitas baru.");
    }

    return RefreshIndicator(
      onRefresh: _initData,
      color: _green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildCard(item);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 250,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_task_rounded,
                color: Color(0xFF94A3B8),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObatCard(dynamic item) {
    final List<dynamic> pengingatRaw = item['pengingat'] ?? [];
    final pengingat = pengingatRaw.isNotEmpty ? pengingatRaw.join(', ') : '-';
    final frekuensi = item['frekuensi'] ?? '-';
    final dosis = item['fungsi'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _textPrimary.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF), // Soft Blue
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_obat'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dosis: $dosis",
                  style: const TextStyle(
                    color: _textPrimary, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$frekuensi • $pengingat",
                  style: const TextStyle(
                    color: _textSecondary, 
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _green, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final namaRutinitas = item['nama_rutinitas'] ?? '-';
    final waktuReminder = item['waktu_reminder'] ?? '';
    final deskripsi = item['deskripsi'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _textPrimary.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF), // Soft Purple
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF8B5CF6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaRutinitas,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (waktuReminder.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.alarm_rounded, color: _textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        waktuReminder,
                        style: const TextStyle(
                          color: _textSecondary, 
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    deskripsi,
                    style: const TextStyle(
                      color: _textSecondary, 
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _green, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    final isObatTab = _tabController.index == 0;
    final buttonLabel = isObatTab ? "Tambah Obat Mandiri" : "Tambah Rutinitas Sehat";

    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (_pasienId == null) return;

          final result = isObatTab
              ? await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TambahJadwalKonsumsi(),
                  ),
                )
              : await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TambahRutinitasScreen(),
                  ),
                );

          if (result == true && mounted) {
            _initData();
          }
        },
        icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 22),
        label: Text(
          buttonLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
          shadowColor: _green.withOpacity(0.3),
        ),
      ),
    );
  }
}
