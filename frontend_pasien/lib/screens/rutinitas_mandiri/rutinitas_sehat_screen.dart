import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const Color _bgPage        = Color(0xFFF8FAF9);
  static const Color _streakBg      = Color(0xFF10221C);
  static const Color _streakTeal    = Color(0xFF13ECA4);
  static const Color _green         = Color(0xFF13EC5B);
  static const Color _tabActive     = Color(0xFF0F172A);
  static const Color _tabInactive   = Color(0xFF64748B);
  static const Color _cardBg        = Color(0xFFF6F8F7);
  static const Color _cardBorder    = Color(0xFFF1F5F9);
  static const Color _textPrimary   = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  final List<JadwalRutinitasItem> _jadwalList = [
    JadwalRutinitasItem(jadwalRutinitasId: 1, namaAktivitas: 'Lari Pagi',       jamMulai: '06:30', jamSelesai: '07:00', pengulangan: ['Sen','Sel','Rab','Kam','Jum'],              status: 'done'),
    JadwalRutinitasItem(jadwalRutinitasId: 2, namaAktivitas: 'Minum Air Putih', jamMulai: '19:00', jamSelesai: '20:00', pengulangan: ['Sen','Sel','Rab','Kam','Jum','Sab','Min'], status: 'done'),
    JadwalRutinitasItem(jadwalRutinitasId: 3, namaAktivitas: 'Makan Malam',     jamMulai: '08:00', jamSelesai: '09:00', pengulangan: ['Sen','Sel','Rab','Kam','Jum','Sab','Min'], status: 'done'),
    JadwalRutinitasItem(jadwalRutinitasId: 4, namaAktivitas: 'Sedekah',         jamMulai: '21:00', jamSelesai: '22:00', pengulangan: ['Sen','Sel','Rab','Kam','Jum'],              status: 'terlewat'),
  ];

  final int _streakHari = 12;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _loadPasienId();
  }

  Future<void> _loadPasienId() async { await SharedPreferences.getInstance(); }

  Future<void> _refresh() async {
    await _loadPasienId();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _hariIni() {
    const hari  = ['','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final now = DateTime.now();
    return '${hari[now.weekday]}, ${now.day} ${bulan[now.month]}';
  }

  // ── Tambah ────────────────────────────────────────────────────────────────
  Future<void> _navTambah() async {
    final result = await Navigator.push<JadwalRutinitasItem>(
      context,
      MaterialPageRoute(builder: (_) => const TambahRutinitasScreen()),
    );
    if (result != null) setState(() => _jadwalList.add(result));
  }

  // ── Edit ──────────────────────────────────────────────────────────────────
  Future<void> _navEdit(JadwalRutinitasItem item) async {
    final result = await Navigator.push<JadwalRutinitasItem>(
      context,
      MaterialPageRoute(builder: (_) => EditRutinitasScreen(item: item)),
    );
    if (result != null) {
      final idx = _jadwalList.indexWhere((e) => e.jadwalRutinitasId == result.jadwalRutinitasId);
      if (idx != -1) setState(() => _jadwalList[idx] = result);
    }
  }

  // ── Hapus (dialog) ────────────────────────────────────────────────────────
  Future<void> _confirmHapus(JadwalRutinitasItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Hapus Rutinitas?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              Text(
                'Kamu yakin ingin menghapus\n"${item.namaAktivitas}"?\nTindakan ini tidak bisa dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'Inter', height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textSecondary, fontFamily: 'Inter')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ya, Hapus',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      setState(() => _jadwalList.removeWhere((e) => e.jadwalRutinitasId == item.jadwalRutinitasId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('"${item.namaAktivitas}" berhasil dihapus.'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildObatTab(), _buildRutinitasTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.chevron_left_rounded, color: _textPrimary),
            ),
          ),
          const Expanded(
            child: Text('Rutinitas Sehat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Roboto')),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _tabActive,
        unselectedLabelColor: _tabInactive,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter', letterSpacing: 0.35),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter', letterSpacing: 0.35),
        indicatorColor: _streakTeal,
        indicatorWeight: 2.5,
        tabs: const [Tab(text: 'Obat'), Tab(text: 'Rutinitas')],
      ),
    );
  }

  Widget _buildObatTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💊', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Belum ada jadwal obat',
            style: TextStyle(fontSize: 14, color: _tabInactive, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRutinitasTab() {
    return RefreshIndicator(
      color: _green,
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _buildStreakCard(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Jadwal Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Roboto', letterSpacing: -0.45)),
              Text(_hariIni(), style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 10),
          if (_jadwalList.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('Belum ada rutinitas.\nTambahkan sekarang!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _textSecondary, fontFamily: 'Inter', height: 1.6)),
              ),
            )
          else
            ..._jadwalList.map(_buildJadwalCard),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      decoration: BoxDecoration(color: _streakBg, borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -0.8), radius: 1.5,
                  colors: [_streakTeal.withOpacity(0.15), _streakTeal.withOpacity(0.0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('🏆', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('STREAK KAMU!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _streakTeal, letterSpacing: 0.7, fontFamily: 'Inter')),
                ]),
                const SizedBox(height: 6),
                Text('$_streakHari Hari',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Roboto')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(JadwalRutinitasItem item) {
    final isDone = item.isDone;
    final isLate = item.isTerlewat;
    final Color badgeBg = isDone
        ? const Color(0xFF13EC5B).withOpacity(0.5)
        : isLate ? const Color(0xFFEC1E13).withOpacity(0.95) : Colors.orange.withOpacity(0.3);
    final String badgeText = isDone ? 'Selesai' : isLate ? 'Terlewat' : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.namaAktivitas,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Roboto')),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 12, color: _textSecondary),
                const SizedBox(width: 4),
                Text('${item.jamMulai} - ${item.jamSelesai}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary, fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _actionButton(icon: Icons.edit_rounded,   color: const Color(0xFF0061FF), bg: const Color(0xFFDBEAFE), onTap: () => _navEdit(item)),
                const SizedBox(width: 6),
                _actionButton(icon: Icons.delete_rounded, color: const Color(0xFFFF0303), bg: const Color(0xFFFEE2E2), onTap: () => _confirmHapus(item)),
              ]),
            ],
          ),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(9999)),
            alignment: Alignment.center,
            child: Text(badgeText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10221C), fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required Color bg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  Widget _buildFAB() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 88,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _navTambah,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: _textPrimary,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: const Icon(Icons.add_rounded, size: 22, color: _textPrimary),
        label: const Text('Tambah Rutinitas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Inter')),
      ),
    );
  }
}