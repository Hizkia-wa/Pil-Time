import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/jadwal_rutinitas_model.dart';

class JadwalRutinitasScreen extends StatefulWidget {
  const JadwalRutinitasScreen({super.key});

  @override
  State<JadwalRutinitasScreen> createState() =>
      _JadwalRutinitasScreenState();
}

class _JadwalRutinitasScreenState
    extends State<JadwalRutinitasScreen> {

  static const Color _bgPage = Color(0xFFF8FAF9);
  static const Color _streakBg = Color(0xFF10221C);
  static const Color _streakTeal = Color(0xFF13ECA4);
  static const Color _green = Color(0xFF13EC5B);
  static const Color _cardBg = Color(0xFFF6F8F7);
  static const Color _cardBorder = Color(0xFFF1F5F9);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  final int _streakHari = 12;

  final List<JadwalRutinitasItem> _jadwalList = [
    JadwalRutinitasItem(
      jadwalRutinitasId: 1,
      namaAktivitas: 'Lari Pagi',
      jamMulai: '06:30',
      jamSelesai: '07:00',
      pengulangan: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'],
      status: 'done',
    ),
    JadwalRutinitasItem(
      jadwalRutinitasId: 2,
      namaAktivitas: 'Minum Air Putih',
      jamMulai: '19:00',
      jamSelesai: '20:00',
      pengulangan: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      status: 'done',
    ),
  ];

  Future<void> _loadPasienId() async {
    await SharedPreferences.getInstance();
  }

  Future<void> _refresh() async {
    await _loadPasienId();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _hariIni() {
    const hari = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final now = DateTime.now();
    return '${hari[now.weekday]}, ${now.day} ${bulan[now.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              _buildStreakCard(),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Jadwal Hari Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    _hariIni(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ..._jadwalList.map(_buildJadwalCard),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _streakBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏆 STREAK KAMU!",
            style: TextStyle(
              color: _streakTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$_streakHari Hari",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(JadwalRutinitasItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.namaAktivitas,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.jamMulai} - ${item.jamSelesai}',
            style: const TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 88,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: _textPrimary),
        label: const Text(
          'Tambah Rutinitas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ),
    );
  }
}