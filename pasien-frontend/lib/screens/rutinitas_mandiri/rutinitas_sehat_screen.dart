import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
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
  static const Color _bgPage = Color(0xFFF8FAF9);
  static const Color _green = Color(0xFF13EC5B);
  static const Color _streakDark = Color(0xFF10221C);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  List<dynamic> _listObat = [];
  List<dynamic> _listRutinitas = [];
  int _streakHari = 0;
  bool _isLoading = true;
  int? _pasienId;
  late TabController _tabController;

  final String _baseUrl = "http://10.0.2.2:8080/api/pasien";

@override
void initState() {
  super.initState();
  // Gunakan widget.initialIndex supaya otomatis pindah tab
  _tabController = TabController(
    length: 2, 
    vsync: this, 
    initialIndex: widget.initialIndex
  );
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

  // Mengambil data dari Backend
  Future<void> _initData() async {
    if (!mounted || _pasienId == null) return;
    setState(() => _isLoading = true);
    try {
      final headers = await _getAuthHeaders();

      // Fetch obat mandiri pasien (obat yang ditambah pasien sendiri)
      final obatResponse = await http.get(
        Uri.parse("$_baseUrl/obat-mandiri"),
        headers: headers,
      );

      // Fetch rutinitas pasien (rutinitas yang dibuat pasien sendiri)
      final rutinitasResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas"),
        headers: headers,
      );

      // Fetch streak dari endpoint streak
      final streakResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas/streak/$_pasienId"),
        headers: headers,
      );

      if (obatResponse.statusCode == 200) {
        final obatData = jsonDecode(obatResponse.body);
        setState(() {
          _listObat = obatData['data'] ?? [];
        });
      } else {
        debugPrint(
          "Gagal fetch obat mandiri: ${obatResponse.statusCode} ${obatResponse.body}",
        );
      }

      if (rutinitasResponse.statusCode == 200) {
        final rutinitasData = jsonDecode(rutinitasResponse.body);
        setState(() {
          // Backend mengembalikan { "data": [...] }
          _listRutinitas = rutinitasData['data'] ?? [];
        });
      } else {
        debugPrint(
          "Gagal fetch rutinitas: ${rutinitasResponse.statusCode} ${rutinitasResponse.body}",
        );
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Rutinitas Sehat",
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _green,
            labelColor: _textPrimary,
            unselectedLabelColor: _textSecondary,
            tabs: const [
              Tab(text: "Obat"),
              Tab(text: "Rutinitas"),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStreakCard(),
            ),
            const SizedBox(height: 20),
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
        color: _streakDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("🏆", style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                "STREAK KAMU!",
                style: TextStyle(
                  color: Color(0xFF13ECA4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$_streakHari Hari",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Section khusus untuk tab Obat (obat mandiri)
  Widget _buildObatSection() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_listObat.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada jadwal obat. Tambah yuk!",
          style: TextStyle(color: _textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _listObat.length,
        itemBuilder: (context, index) {
          final item = _listObat[index];
          return _buildObatCard(item);
        },
      ),
    );
  }

  Widget _buildListSection(List<dynamic> list, String type) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (list.isEmpty) {
      return Center(
        child: Text(
          "Belum ada jadwal $type. Tambah yuk!",
          style: const TextStyle(color: _textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildCard(item);
      },
    );
  }

  // Card untuk obat mandiri (field dari ObatResponseDTO)
  Widget _buildObatCard(dynamic item) {
    final List<dynamic> pengingatRaw = item['pengingat'] ?? [];
    final pengingat = pengingatRaw.isNotEmpty ? pengingatRaw.join(', ') : '-';
    final frekuensi = item['frekuensi'] ?? '-';
    // Dosis disimpan di field 'fungsi' karena CreateMandiri memakai: obat.Fungsi = req.Dosis
    final dosis = item['fungsi'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_obat'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dosis: $dosis",
                  style: const TextStyle(color: _textSecondary, fontSize: 13),
                ),
                Text(
                  "$frekuensi • $pengingat",
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_box_outline_blank, color: _green),
        ],
      ),
    );
  }

  // Card untuk rutinitas yang dibuat pasien sendiri (field dari domain.Rutinitas)
  Widget _buildCard(dynamic item) {
    final namaRutinitas = item['nama_rutinitas'] ?? '-';
    final waktuReminder = item['waktu_reminder'] ?? '';
    final deskripsi = item['deskripsi'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaRutinitas,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (waktuReminder.isNotEmpty)
                  Text(
                    '⏰ $waktuReminder',
                    style: const TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                if (deskripsi.isNotEmpty)
                  Text(
                    deskripsi,
                    style: const TextStyle(color: _textSecondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.check_box_outline_blank, color: _green),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    final isObatTab = _tabController.index == 0;
    final buttonLabel = isObatTab ? "Tambah Obat" : "Tambah Rutinitas";

    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 54,
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

          // Refresh data jika result bernilai true
          if (result == true && mounted) {
            _initData();
          }
        },
        icon: const Icon(Icons.add, color: _textPrimary),
        label: Text(
          buttonLabel,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
