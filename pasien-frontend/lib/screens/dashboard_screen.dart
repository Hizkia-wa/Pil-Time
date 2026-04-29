import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/dashboard.dart';
import '../models/jadwal.dart';
import 'package:frontend_pasien/screens/riwayat/riwayat_konsumsi_obat.dart';
import "package:frontend_pasien/screens/rutinitas_mandiri/rutinitas_sehat_screen.dart";
import 'package:frontend_pasien/screens/rutinitas_mandiri/tambah_rutinitas_screen.dart';
import 'package:frontend_pasien/screens/info_obat/info_obat.dart';
import 'package:frontend_pasien/screens/notifikasi/notifikasi_screen.dart';
import 'package:frontend_pasien/screens/alarm/alarm_screen.dart';
import 'package:frontend_pasien/screens/profile/profile.dart';

class DashboardScreen extends StatefulWidget {
  final int pasienId;
  final String pasienNama;

  const DashboardScreen({
    super.key,
    required this.pasienId,
    required this.pasienNama,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Dashboard?> dashboardFuture;
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = true; // toggle Minggu/Bulan

  // Track jadwal yang sudah ditandai diminum di sesi ini
  final Set<int> _takenJadwalIds = {};
  bool _isMarkingTaken = false;

  @override
  void initState() {
    super.initState();
    dashboardFuture = _fetchDashboard();
  }

  Future<Dashboard?> _fetchDashboard() async {
    try {
      final response = await ApiService.getDashboard(pasienId: widget.pasienId);
      if (!mounted) return null;
      if (response['success']) {
        return Dashboard.fromJson(response['data']);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error']}')),
          );
        }
        return null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return null;
    }
  }

  Future<void> _onRefresh() async {
    // Trigger dashboard refresh
    setState(() {
      dashboardFuture = _fetchDashboard();
      _takenJadwalIds.clear();
    });
    // Wait for the future to complete
    await dashboardFuture;
  }

  /// Log jadwal sebagai 'Diminum' ke backend tracking API
  Future<void> _markAsTaken(Jadwal jadwal, int pasienId) async {
    if (_isMarkingTaken) return;
    setState(() => _isMarkingTaken = true);

    try {
      final token = await AuthService.getToken();
      final now = DateTime.now();
      final today = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final waktuSekarang = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      // Tentukan status: tepat waktu atau terlambat
      final jadwalStatus = _getJadwalStatus(jadwal.waktuMinum);
      final status =
          jadwalStatus == _JadwalStatus.upcoming ? 'Diminum' : 'Diminum';

      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8080/api/admin/riwayat'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'jadwal_id': jadwal.id,
              'pasien_id': pasienId,
              'tanggal': today,
              'status': status,
              'waktu_minum': waktuSekarang,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _takenJadwalIds.add(jadwal.id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('${jadwal.namaObat} berhasil dicatat!'),
                ],
              ),
              backgroundColor: const Color(0xFF15BE77),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal mencatat, coba lagi'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingTaken = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Dashboard?>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF15BE77)),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF15BE77),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gagal memuat dashboard'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(
                            () => dashboardFuture = _fetchDashboard(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15BE77),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tarik ke bawah untuk refresh',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final dashboard = snapshot.data!;
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF15BE77),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(dashboard),
                          _buildMenuUtama(),
                          _buildCalendarSection(dashboard.allJadwals),
                          _buildJadwalList(dashboard.todayJadwals, dashboard.pasienId),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          );
        },
      ),
    );
  }

  // HEADER //
  Widget _buildHeader(Dashboard dashboard) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Selamat Pagi,',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dashboard.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFFF6B6B),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MENU UTAMA //
  Widget _buildMenuUtama() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildMenuCard(
                icon: Icons.alarm,
                iconBg: const Color(0xFFFFECEC),
                iconColor: const Color(0xFFFF6B6B),
                label: 'Reminder & Alarm',
                subLabel: 'Kelola Pengingat',
                subLabelColor: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AlarmScreen(pasienId: widget.pasienId),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.local_pharmacy_outlined,
                iconBg: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFF9800),
                label: 'Info Obat',
                subLabel: 'Detail & Panduan',
                subLabelColor: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InfoObatScreen(pasienId: widget.pasienId),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.bar_chart,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF2196F3),
                label: 'Riwayat',
                subLabel: 'Kepatuhan Minum',
                subLabelColor: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatKonsumsiObatScreen(),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.fitness_center,
                iconBg: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                label: 'Rutinitas Sehat',
                subLabel: 'Jadwal Aktivitas',
                subLabelColor: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Tambahkan parameter streakHari di sini
                      builder: (context) => const RutinitasSehatScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String subLabel,
    required Color subLabelColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: subLabelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CALENDAR ──────────────────────────────────────────────────────────────

  /// Mengecek apakah [date] jatuh dalam rentang tanggal salah satu jadwal aktif.
  bool _hasJadwalOnDate(DateTime date, List<Jadwal> jadwals) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    for (final j in jadwals) {
      if (j.tanggalMulai.isEmpty || j.tanggalSelesai.isEmpty) continue;
      try {
        final mulai = DateTime.parse(j.tanggalMulai);
        final selesai = DateTime.parse(j.tanggalSelesai);
        final start = DateTime(mulai.year, mulai.month, mulai.day);
        final end = DateTime(selesai.year, selesai.month, selesai.day);
        if (!dateOnly.isBefore(start) && !dateOnly.isAfter(end)) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Widget _buildCalendarSection(List<Jadwal> allJadwals) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Header row: bulan & toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthYear(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              // Toggle Minggu / Bulan
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _toggleBtn(
                      'Minggu',
                      _isWeekView,
                      () => setState(() => _isWeekView = true),
                    ),
                    _toggleBtn(
                      'Bulan',
                      !_isWeekView,
                      () => setState(() => _isWeekView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isWeekView
              ? _buildWeekCalendar(allJadwals)
              : _buildMonthCalendar(allJadwals),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF1A1A1A) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(List<Jadwal> allJadwals) {
    // Tampilkan 7 hari mulai dari Senin minggu ini
    final now = DateTime.now();
    final mondayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day = mondayOfWeek.add(Duration(days: i));
            final isToday =
                day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;
            // Dot real: cek apakah tanggal ini masuk rentang jadwal pasien
            final hasDot = _hasJadwalOnDate(day, allJadwals);

            return SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF15BE77)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasDot)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF15BE77)
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar(List<Jadwal> allJadwals) {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final weekdayOfFirst = firstDay.weekday; // 1=Mon
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _selectedDate.year && now.month == _selectedDate.month;

    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      children: [
        // Nav arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              }),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              }),
            ),
          ],
        ),
        // Day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weekdayOfFirst - 1 + daysInMonth,
          itemBuilder: (context, index) {
            if (index < weekdayOfFirst - 1) return const SizedBox();
            final day = index - (weekdayOfFirst - 1) + 1;
            final isToday = isCurrentMonth && day == now.day;
            // Dot real: cek apakah tanggal ini masuk rentang jadwal pasien
            final dateToCheck =
                DateTime(_selectedDate.year, _selectedDate.month, day);
            final hasDot = _hasJadwalOnDate(dateToCheck, allJadwals);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF15BE77)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                if (hasDot) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF15BE77)
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // ── JADWAL LIST ───────────────────────────────────────────────────────────

  /// Klasifikasi status jadwal berdasarkan waktu sekarang
  _JadwalStatus _getJadwalStatus(String waktuMinum) {
    try {
      final now = DateTime.now();
      final parts = waktuMinum.split(':');
      if (parts.length < 2) return _JadwalStatus.upcoming;
      final jadwalDt = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      final diffMinutes = now.difference(jadwalDt).inMinutes;
      if (diffMinutes < -5) return _JadwalStatus.upcoming;   // belum waktunya
      if (diffMinutes <= 30) return _JadwalStatus.onTime;    // dalam 30 menit
      return _JadwalStatus.late;                             // sudah lewat
    } catch (_) {
      return _JadwalStatus.upcoming;
    }
  }

  Widget _buildJadwalList(List<Jadwal> jadwals, int pasienId) {
    final now = DateTime.now();
    final dayNames = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final monthNames = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember',
    ];
    final dayName = dayNames[now.weekday - 1];
    final dateStr = '$dayName, ${now.day} ${monthNames[now.month - 1]} ${now.year}';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jadwal Hari Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (jadwals.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${jadwals.length} obat',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15BE77),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Empty state ──────────────────────────────────────────────────
          if (jadwals.isEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFF15BE77),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada jadwal obat hari ini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selamat, tidak ada obat yang perlu diminum hari ini',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),

          // ── Jadwal cards ─────────────────────────────────────────────────
          ...jadwals.map(
            (jadwal) => _buildJadwalCard(
              jadwal: jadwal,
              pasienId: pasienId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard({
    required Jadwal jadwal,
    required int pasienId,
  }) {
    final isTaken = _takenJadwalIds.contains(jadwal.id);
    final status = isTaken ? _JadwalStatus.onTime : _getJadwalStatus(jadwal.waktuMinum);

    // ── Warna & teks per status ──────────────────────────────────────────
    final Color statusColor;
    final Color statusBg;
    final String statusLabel;
    final IconData statusIcon;

    if (isTaken) {
      statusColor = const Color(0xFF15BE77);
      statusBg = const Color(0xFFE8F8F1);
      statusLabel = 'Sudah Diminum';
      statusIcon = Icons.check_circle_rounded;
    } else {
      switch (status) {
        case _JadwalStatus.onTime:
          statusColor = const Color(0xFF15BE77);
          statusBg = const Color(0xFFE8F8F1);
          statusLabel = 'Waktunya Minum!';
          statusIcon = Icons.alarm_on_rounded;
          break;
        case _JadwalStatus.late:
          statusColor = const Color(0xFFFFA726);
          statusBg = const Color(0xFFFFF8E1);
          statusLabel = 'Segera Minum';
          statusIcon = Icons.alarm_rounded;
          break;
        case _JadwalStatus.upcoming:
          statusColor = const Color(0xFF78909C);
          statusBg = const Color(0xFFF5F5F5);
          statusLabel = 'Akan Datang';
          statusIcon = Icons.schedule_rounded;
          break;
      }
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTaken
              ? null
              : () => _markAsTaken(jadwal, pasienId),
          borderRadius: BorderRadius.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Ikon obat ──────────────────────────────────────────────
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getPillEmoji(jadwal.namaObat),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Info obat ─────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama obat
                      Text(
                        jadwal.namaObat,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isTaken
                              ? Colors.grey[400]
                              : const Color(0xFF1A1A1A),
                          decoration: isTaken
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Dosis & aturan
                      Text(
                        '${jadwal.jumlahDosis} ${jadwal.satuan}  •  ${jadwal.aturanKonsumsi}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Status badge
                      Row(
                        children: [
                          // Waktu minum
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  jadwal.waktuMinum,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, size: 11, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── Checkbox interaktif ───────────────────────────────────
                GestureDetector(
                  onTap: isTaken
                      ? null
                      : () => _markAsTaken(jadwal, pasienId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isTaken
                          ? const Color(0xFF15BE77)
                          : Colors.transparent,
                      border: Border.all(
                        color: isTaken
                            ? const Color(0xFF15BE77)
                            : status == _JadwalStatus.upcoming
                                ? Colors.grey[300]!
                                : statusColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isTaken
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPillEmoji(String namaObat) {
    final lower = namaObat.toLowerCase();
    if (lower.contains('vitamin')) return '🟡';
    if (lower.contains('probiotic') || lower.contains('probiotik')) return '🟠';
    if (lower.contains('ibuprofen')) return '🟠';
    if (lower.contains('aspirin')) return '🔴';
    return '💊';
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.home_rounded,
              color: Color(0xFF15BE77),
              size: 28,
            ),
          ),
          // FAB +
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahRutinitasScreen(),
                ),
              );
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF15BE77),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4015BE77),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          // Profile
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: Icon(
              Icons.person_outline_rounded,
              color: Colors.grey[400],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  String _getMonthYear(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Status jadwal berdasarkan waktu sekarang
enum _JadwalStatus { onTime, late, upcoming }
