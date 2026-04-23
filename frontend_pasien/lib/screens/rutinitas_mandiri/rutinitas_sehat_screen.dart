import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk jsonEncode & decode
import 'package:http/http.dart' as http; // Untuk koneksi ke Backend Go
import '../../models/jadwal_rutinitas_model.dart';
import 'tambah_rutinitas_screen.dart';
import 'edit_rutinitas_screen.dart';

class RutinitasSehatScreen extends StatefulWidget {
  const RutinitasSehatScreen({super.key});

  @override
  State<RutinitasSehatScreen> createState() => _RutinitasSehatScreenState();
}

class _RutinitasSehatScreenState extends State<RutinitasSehatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- KONFIGURASI API ---
  // Gunakan 10.0.2.2 jika pakai Emulator Android, atau IP Laptop jika pakai HP asli
  final String baseUrl = "http://10.0.2.2:8080/api"; 
  int _currentStreak = 0; 

  // Warna Tema Pil-Time
  static const Color _streakBg = Color(0xFF0F291E);
  static const Color _streakTeal = Color(0xFF13ECA4);
  static const Color _greenAction = Color(0xFF00E676);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  // Data List
  final List<JadwalRutinitasItem> _jadwalList = [
    JadwalRutinitasItem(
      jadwalRutinitasId: 1,
      namaAktivitas: 'Sarapan Pagi',
      jamMulai: '07:00',
      jamSelesai: '08:00',
      status: 'none',
      pengulangan: ['Sen'],
    ),
    JadwalRutinitasItem(
      jadwalRutinitasId: 2,
      namaAktivitas: 'Minum Obat Siang',
      jamMulai: '14:00',
      jamSelesai: '16:00',
      status: 'none',
      pengulangan: ['Sen'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _refreshStreak(); // Ambil data streak saat layar dibuka
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- INTEGRASI BACKEND ---
  
  Future<void> _refreshStreak() async {
    try {
      // Ganti '1' dengan ID pasien yang dinamis nanti
      final response = await http.get(Uri.parse('$baseUrl/pasien/streak/1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentStreak = data['current_streak'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil streak: $e");
    }
  }

  void _toggleStatus(JadwalRutinitasItem item) async {
    final logic = _getStatusLogic(item);

    if (!logic['canInteract']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal sudah terlewat.")),
      );
      return;
    }

    try {
      final newStatus = (item.status == 'done') ? 'none' : 'done';
      
      // Update ke Backend
      final response = await http.post(
        Uri.parse('$baseUrl/tracking/update'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rutinitas_id": item.jadwalRutinitasId,
          "status": newStatus,
          "tanggal": DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        // Jika sukses, hitung ulang streak
        await _refreshStreak();
        
        setState(() {
          final index = _jadwalList.indexOf(item);
          _jadwalList[index] = JadwalRutinitasItem(
            jadwalRutinitasId: item.jadwalRutinitasId,
            namaAktivitas: item.namaAktivitas,
            jamMulai: item.jamMulai,
            jamSelesai: item.jamSelesai,
            pengulangan: item.pengulangan,
            status: newStatus,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error koneksi: $e")),
      );
    }
  }

  // --- HELPER & LOGIC UI ---

  int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.replaceAll('.', ':').split(':');
      return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> _getStatusLogic(JadwalRutinitasItem item) {
    if (item.status == 'done') {
      return {
        'icon': Icons.check_box,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFE8FDF5),
        'canInteract': true,
      };
    }

    final now = DateTime.now();
    final currentMin = (now.hour * 60) + now.minute;
    final startMin = _timeToMinutes(item.jamMulai);
    final endMin = _timeToMinutes(item.jamSelesai);

    if (currentMin > endMin) {
      return {
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
        'bg': const Color(0xFFFEF2F2),
        'canInteract': false,
      };
    }

    return {
      'icon': Icons.check_box_outline_blank,
      'color': const Color(0xFF10B981),
      'bg': const Color(0xFFE8FDF5),
      'canInteract': true,
    };
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: _textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rutinitas Sehat', 
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: _textPrimary,
            indicatorColor: _streakTeal,
            tabs: const [Tab(text: 'Obat'), Tab(text: 'Rutinitas')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("Halaman Obat")),
                _buildMainContent(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStreakCard(),
        const SizedBox(height: 24),
        const Text('Daftar Jadwal Hari Ini', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._jadwalList.map(_buildItemCard),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _streakBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 STREAK KAMU!', 
              style: TextStyle(color: _streakTeal, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text('$_currentStreak Hari', 
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItemCard(JadwalRutinitasItem item) {
    final ui = _getStatusLogic(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaAktivitas, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${item.jamMulai} - ${item.jamSelesai}', 
                    style: const TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleStatus(item),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: ui['bg'], borderRadius: BorderRadius.circular(8)),
                  child: Icon(ui['icon'], color: ui['color'], size: 22),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: Colors.grey[300]),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _navEdit(item), 
                icon: const Icon(Icons.edit_note, color: Colors.blue, size: 22)
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmHapus(item), 
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NAVIGATION & FAB ---

  void _navTambah() async {
    final result = await Navigator.push<JadwalRutinitasItem>(
      context,
      MaterialPageRoute(builder: (context) => const TambahRutinitasScreen()),
    );
    if (result != null && mounted) setState(() => _jadwalList.add(result));
  }

  void _navEdit(JadwalRutinitasItem item) async {
    final result = await Navigator.push<JadwalRutinitasItem>(
      context,
      MaterialPageRoute(builder: (context) => EditRutinitasScreen(item: item)),
    );
    if (result != null && mounted) {
      setState(() {
        final index = _jadwalList.indexWhere((e) => e.jadwalRutinitasId == result.jadwalRutinitasId);
        if (index != -1) _jadwalList[index] = result;
      });
    }
  }

  void _confirmHapus(JadwalRutinitasItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Rutinitas"),
        content: Text("Yakin ingin menghapus '${item.namaAktivitas}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              setState(() => _jadwalList.removeWhere((e) => e.jadwalRutinitasId == item.jadwalRutinitasId));
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _navTambah,
        icon: const Icon(Icons.add, color: _textPrimary),
        label: const Text("Tambah Rutinitas", 
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _greenAction, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}