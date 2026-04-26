import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tambah_rutinitas_screen.dart'; 

class RutinitasSehatScreen extends StatefulWidget {
  const RutinitasSehatScreen({super.key});

  @override
  State<RutinitasSehatScreen> createState() => _RutinitasSehatScreenState();
}

class _RutinitasSehatScreenState extends State<RutinitasSehatScreen> {
  static const Color _bgPage         = Color(0xFFF8FAF9);
  static const Color _green          = Color(0xFF13EC5B);
  static const Color _streakDark      = Color(0xFF10221C);
  static const Color _textPrimary     = Color(0xFF0F172A);
  static const Color _textSecondary   = Color(0xFF64748B);

  List<dynamic> _listObat = [];
  List<dynamic> _listRutinitas = [];
  int _streakHari = 0;
  bool _isLoading = true;

  final String _baseUrl = "http://10.0.2.2:8080/api/pasien";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Mengambil data dari Backend
  Future<void> _initData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("$_baseUrl/dashboard?pasien_id=1"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listObat = data['jadwal_obat'] ?? []; 
          _listRutinitas = data['rutinitas'] ?? [];
          _streakHari = data['streak'] ?? 0;
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
          bottom: const TabBar(
            indicatorColor: _green,
            labelColor: _textPrimary,
            unselectedLabelColor: _textSecondary,
            tabs: [
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
                children: [
                  _buildListSection(_listObat, "obat"),
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
                style: TextStyle(color: Color(0xFF13ECA4), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$_streakHari Hari",
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(List<dynamic> list, String type) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (list.isEmpty) {
      return Center(
        child: Text("Belum ada jadwal $type. Tambah yuk!", style: const TextStyle(color: _textSecondary)),
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

  Widget _buildCard(dynamic item) {
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
                  item['nama_aktivitas'] ?? item['nama_obat'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "${item['jam_mulai']} - ${item['jam_selesai']}",
                  style: const TextStyle(color: _textSecondary, fontSize: 13),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Navigasi dan menunggu hasil (result)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahRutinitasScreen()),
          );
          
          // Jika result bernilai true, panggil _initData() untuk refresh riwayat
          if (result == true) {
            _initData();
          }
        },
        icon: const Icon(Icons.add, color: _textPrimary),
        label: const Text("Tambah Rutinitas", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}