import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/dashboard.dart';
import '../models/jadwal.dart';

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
    });
    // Wait for the future to complete
    await dashboardFuture;
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
                          _buildCalendarSection(),
                          _buildJadwalList(dashboard.todayJadwals),
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

  // ── HEADER ────────────────────────────────────────────────────────────────
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
            onTap: () {},
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

  // ── MENU UTAMA ────────────────────────────────────────────────────────────
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
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.local_pharmacy_outlined,
                iconBg: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFF9800),
                label: 'Info Obat',
                subLabel: 'Detail & Panduan',
                subLabelColor: const Color(0xFFFF9800),
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.bar_chart,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF2196F3),
                label: 'Riwayat',
                subLabel: 'Kepatuhan Minum',
                subLabelColor: const Color(0xFF2196F3),
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.build_outlined,
                iconBg: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                label: 'Rutinitas Sehat',
                subLabel: 'Jadwal Aktivitas',
                subLabelColor: const Color(0xFF9C27B0),
                onTap: () {},
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
  Widget _buildCalendarSection() {
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
          _isWeekView ? _buildWeekCalendar() : _buildMonthCalendar(),
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

  Widget _buildWeekCalendar() {
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
            // dot: simulasi ada jadwal
            final hasDot = i < 4;

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

  Widget _buildMonthCalendar() {
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
            final hasDot = day % 3 == 0; // simulasi dot jadwal

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
  Widget _buildJadwalList(List<Jadwal> jadwals) {
    if (jadwals.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Tidak ada jadwal obat untuk hari ini',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Simulasi jadwal aktif (yang sedang waktunya) — highlight row ke-1 (index 1)
    // Dalam produksi, bandingkan waktuMinum dengan jam sekarang

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: List.generate(jadwals.length, (i) {
          final jadwal = jadwals[i];
          final isActive = i == 1; // highlight baris ke-2 seperti desain
          final isDone = i == 0; // baris pertama sudah selesai (centang)

          return _buildJadwalRow(
            jadwal: jadwal,
            isActive: isActive,
            isDone: isDone,
          );
        }),
      ),
    );
  }

  Widget _buildJadwalRow({
    required Jadwal jadwal,
    bool isActive = false,
    bool isDone = false,
  }) {
    return Container(
      color: isActive ? const Color(0xFFE8E8E8) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Pill emoji / icon
          Text(
            _getPillEmoji(jadwal.namaObat),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 14),
          // Waktu & nama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      jadwal.waktuMinum,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${jadwal.jumlahDosis} ${jadwal.satuan} 1x Sehari',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  jadwal.namaObat,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive
                        ? const Color(0xFF1A1A1A)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Checkbox
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF15BE77) : Colors.transparent,
              border: Border.all(
                color: isDone
                    ? const Color(0xFF15BE77)
                    : isActive
                    ? const Color(0xFF15BE77)
                    : Colors.grey[300]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ],
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
            onTap: () {},
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
            onPressed: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.clearSession();
              if (mounted && context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
