import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/dashboard.dart';
import '../models/jadwal.dart';
import 'package:frontend_pasien/screens/riwayat/riwayat_konsumsi_obat.dart';
import "package:frontend_pasien/screens/rutinitas_mandiri/rutinitas_sehat_screen.dart";
import 'package:frontend_pasien/screens/info_obat/info_obat.dart';
import 'package:frontend_pasien/screens/notifikasi/notifikasi_screen.dart';
import 'package:frontend_pasien/screens/alarm/alarm_screen.dart';
import 'package:frontend_pasien/screens/profile/profile.dart';
import '../services/notification_service.dart';
import '../services/fcm_service.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';

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
  late final DashboardBloc _dashboardBloc;
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = true; // toggle Minggu/Bulan

  // Track status riwayat per tanggal "YYYY-MM-DD"
  Map<String, List<String>> _riwayatByDate = {};

  // Track jadwal yang sudah ditandai diminum di sesi ini
  final Set<int> _takenJadwalIds = {};
  bool _notificationPermissionGranted = true;

  // Properti Rutinitas Sehat
  List<dynamic> _listRutinitas = [];
  bool _loadingRutinitas = true;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = DashboardBloc()..add(FetchDashboard(
      pasienId: widget.pasienId,
      pasienNama: widget.pasienNama,
    ));
    // Tunda _loadRutinitas sampai setelah frame pertama untuk memastikan
    // token sudah tersimpan sepenuhnya di SharedPreferences sebelum dibaca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRutinitas();
    });
    // Init FCM service: daftarkan token ke backend (fire-and-forget)
    FcmService.instance.initialize();
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  Future<void> _checkNotificationPermission() async {
    final granted = await NotificationService.instance.checkPermissionStatus();
    if (mounted) {
      setState(() {
        _notificationPermissionGranted = granted;
      });
    }
  }

  Future<void> _onRefresh() async {
    _dashboardBloc.add(FetchDashboard(
      pasienId: widget.pasienId,
      pasienNama: widget.pasienNama,
    ));
    _loadRutinitas();
  }

  // ==========================================================
  // TEST ALARM — Hanya untuk development/debug
  // Langsung tampilkan AlarmRingingScreen tanpa menunggu jadwal
  // ==========================================================
  void _testAlarm() {
    // Gunakan payload dummy: "0:Test Obat Paracetamol"
    NotificationService.instance.showAlarmScreen('0:Test Obat Paracetamol');
  }

  /// Log jadwal sebagai 'Diminum' ke backend tracking API
  Future<void> _markAsTaken(Jadwal jadwal, int pasienId) async {
    final status = _getJadwalStatus(jadwal.waktuMinum);
    if (status == _JadwalStatus.upcoming) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Belum memasuki waktu minum obat ${jadwal.namaObat}! Jadwal Anda adalah pukul ${jadwal.waktuMinum}.',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEA580C), // Orange warning color
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    _dashboardBloc.add(MarkAsTaken(jadwal: jadwal, pasienId: pasienId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: BlocConsumer<DashboardBloc, DashboardState>(
        bloc: _dashboardBloc,
        listener: (context, state) {
          if (state is DashboardFailure && state.statusCode == 401) {
            AuthService.logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else if (state is DashboardMarkingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(state.message),
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
          } else if (state is DashboardMarkingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red[400],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF15BE77),
                strokeWidth: 3,
              ),
            );
          }

          if (state is DashboardFailure) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF15BE77),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFFF4D4D),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _dashboardBloc.add(FetchDashboard(
                            pasienId: widget.pasienId,
                            pasienNama: widget.pasienNama,
                          )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15BE77),
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
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final dashboard = state.dashboard;
            _takenJadwalIds.clear();
            _takenJadwalIds.addAll(state.takenJadwalIds);
            _riwayatByDate = state.riwayatByDate;

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
                            _buildProgressCard(dashboard.todayJadwals),
                            if (!_notificationPermissionGranted)
                              _buildPermissionWarningBanner(),
                            _buildMenuUtama(),
                            _buildCalendarSection(dashboard.allJadwals),
                            _buildJadwalList(dashboard.todayJadwals, dashboard.pasienId),
                            _buildRutinitasHariIniList(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- PROGRESS TRACKER CARD (NEW & PREMIUM) ---
  Widget _buildProgressCard(List<Jadwal> todayJadwals) {
    // Saring jadwal yang aktif
    final activeToday = todayJadwals.where((j) => j.status.toLowerCase() == 'aktif').toList();
    final totalToday = activeToday.length;
    final takenToday = activeToday.where((j) => _takenJadwalIds.contains(j.id)).length;
    final progress = totalToday > 0 ? takenToday / totalToday : 0.0;

    String quote;
    if (totalToday == 0) {
      quote = 'Tidak ada jadwal obat hari ini. Selalu jaga kesehatan Anda! 🌟';
    } else if (progress == 0.0) {
      quote = 'Ayo mulai hari sehat Anda dengan minum obat pertama tepat waktu!';
    } else if (progress < 1.0) {
      quote = 'Luar biasa! Tinggal sedikit lagi untuk menyelesaikan semua obat hari ini.';
    } else {
      quote = 'Hebat sekali! Semua obat untuk hari ini telah berhasil diminum. 🎉';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15BE77), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15BE77).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KEPATUHAN HARI INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalToday > 0 
                          ? '$takenToday dari $totalToday Selesai' 
                          : 'Hari Bebas Obat!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalToday > 0 ? progress : 1.0,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- PERMISSION WARNING BANNER ---
  Widget _buildPermissionWarningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Warm subtle orange
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_paused_rounded,
              color: Color(0xFFEA580C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Izin Alarm & Notifikasi Mati',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF7C2D12),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Aktifkan notifikasi agar alarm penting Anda tetap berdering tepat waktu.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF7C2D12).withValues(alpha: 0.8),
                    height: 1.3,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _showPermissionInstructionDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Aktifkan',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionInstructionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.notifications_active_rounded, color: Color(0xFF15BE77), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aktifkan Notifikasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pil-Time membutuhkan izin notifikasi agar alarm obat Anda dapat berdering tepat waktu di HP Anda.',
                style: TextStyle(
                  fontSize: 14, 
                  color: Color(0xFF475569), 
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cara mengaktifkan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14, 
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              _buildStepRow('1', 'Buka Pengaturan (Settings) di HP Anda.'),
              _buildStepRow('2', 'Pilih Aplikasi > Pil-Time.'),
              _buildStepRow('3', 'Pilih Notifikasi (Notifications).'),
              _buildStepRow('4', 'Aktifkan semua izin notifikasi & suara.'),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF64748B), 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await NotificationService.instance.initialize();
                _checkNotificationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15BE77),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Beri Izin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15BE77),
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13, 
                color: Color(0xFF334155), 
                height: 1.4,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(Dashboard dashboard) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 4 && hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        fontSize: 14, 
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dashboard.nama,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Roboto',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Test Alarm (hanya muncul di debug mode)
          if (kDebugMode) ...[
            GestureDetector(
              onTap: _testAlarm,
              child: Tooltip(
                message: 'Test Alarm Screen',
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF15BE77),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF15BE77).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm_on_rounded,
                    color: Color(0xFF15BE77),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          // Notification bell
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD1D1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFFF6B6B),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU UTAMA (SPACIOUS & ACCESSIBLE) ---
  Widget _buildMenuUtama() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.25, // Taller ratio for better readability and touch targets
            children: [
              _buildMenuCard(
                icon: Icons.alarm_rounded,
                iconBg: const Color(0xFFFFECEC),
                iconColor: const Color(0xFFFF6B6B),
                label: 'Reminder & Alarm',
                subLabel: 'Kelola Pengingat',
                subLabelColor: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlarmScreen(pasienId: widget.pasienId),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.local_pharmacy_rounded,
                iconBg: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFF9800),
                label: 'Info Obat',
                subLabel: 'Detail & Panduan',
                subLabelColor: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoObatScreen(pasienId: widget.pasienId),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.bar_chart_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2F80ED), // Secondary Blue dari Style Guide
                label: 'Riwayat',
                subLabel: 'Kepatuhan Minum',
                subLabelColor: const Color(0xFF2F80ED),
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
                icon: Icons.fitness_center_rounded,
                iconBg: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9C27B0),
                label: 'Rutinitas Sehat',
                subLabel: 'Jadwal Aktivitas',
                subLabelColor: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: subLabelColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- CALENDAR SECTION (ENLARGED & CONTRASTING) ---
  Color _getCalendarDotColor(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (_riwayatByDate.containsKey(dateStr)) {
      final statuses = _riwayatByDate[dateStr] ?? [];
      if (statuses.isEmpty) {
        if (dateOnly.isBefore(today)) {
          return const Color(0xFFFF4D4D); // Merah - Terlewat
        }
        return const Color(0xFF94A3B8); // Abu-abu default
      }
      if (statuses.contains('Terlewat')) {
        return const Color(0xFFFF4D4D); // Merah - Terlewat
      }
      if (statuses.contains('Terlambat')) {
        return const Color(0xFFFFA726); // Kuning - Terlambat
      }
      if (statuses.contains('Diminum')) {
        return const Color(0xFF15BE77); // Hijau - Selesai
      }
    } else {
      if (dateOnly.isBefore(today)) {
        return const Color(0xFFFF4D4D); // Merah - Terlewat
      }
    }
    return const Color(0xFF94A3B8); // Abu-abu default
  }

  Widget _buildCalendarLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(const Color(0xFF15BE77), 'Selesai'),
          const SizedBox(width: 14),
          _legendItem(const Color(0xFFFFA726), 'Terlambat'),
          const SizedBox(width: 14),
          _legendItem(const Color(0xFFFF4D4D), 'Terlewat'),
          const SizedBox(width: 14),
          _legendItem(const Color(0xFF94A3B8), 'Belum Diminum'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthYear(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                ),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 16),
          _isWeekView
              ? _buildWeekCalendar(allJadwals)
              : _buildMonthCalendar(allJadwals),
          const SizedBox(height: 18),
          _buildCalendarLegend(),
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
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(List<Jadwal> allJadwals) {
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
                  width: 38,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day = mondayOfWeek.add(Duration(days: i));
            final isToday =
                day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;
            final hasDot = _hasJadwalOnDate(day, allJadwals);

            return SizedBox(
              width: 38,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF15BE77)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday 
                          ? null 
                          : Border.all(color: const Color(0xFFF1F5F9), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : const Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasDot)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getCalendarDotColor(day),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 8),
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
    final weekdayOfFirst = firstDay.weekday;
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _selectedDate.year && now.month == _selectedDate.month;

    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 24, color: Color(0xFF0F172A)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              }),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFF0F172A)),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
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
            final dateToCheck =
                DateTime(_selectedDate.year, _selectedDate.month, day);
            final hasDot = _hasJadwalOnDate(dateToCheck, allJadwals);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (hasDot)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getCalendarDotColor(dateToCheck),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            );
          },
        ),
      ],
    );
  }

  // --- JADWAL LIST ---
  _JadwalStatus _getJadwalStatus(String waktuMinum) {
    try {
      final now = DateTime.now();
      final parts = waktuMinum.split(':');
      if (parts.length < 2) return _JadwalStatus.upcoming;
      final jadwalDt = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      if (now.isBefore(jadwalDt)) return _JadwalStatus.upcoming;
      final diffMinutes = now.difference(jadwalDt).inMinutes;
      if (diffMinutes > 75) return _JadwalStatus.expired;
      if (diffMinutes <= 30) return _JadwalStatus.onTime;
      return _JadwalStatus.late;
    } catch (_) {
      return _JadwalStatus.upcoming;
    }
  }

  Future<void> _autoLogExpiredJadwal(Jadwal jadwal, int pasienId) async {
    try {
      final now = DateTime.now();
      final waktuSekarang = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
      await ApiService.postRiwayat(
        jadwalId: jadwal.id,
        status: 'Terlewat',
        waktuMinum: waktuSekarang,
      );
      debugPrint('[Dashboard] Auto-logged Terlewat for jadwal #${jadwal.id} (${jadwal.namaObat})');
    } catch (e) {
      debugPrint('[Dashboard] Gagal auto-log Terlewat (non-fatal): $e');
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

    // Pisahkan jadwal aktif vs expired
    final activeJadwals = <Jadwal>[];
    for (final j in jadwals) {
      if (_takenJadwalIds.contains(j.id)) {
        activeJadwals.add(j);
        continue;
      }
      final status = _getJadwalStatus(j.waktuMinum);
      if (status == _JadwalStatus.expired) {
        _autoLogExpiredJadwal(j, pasienId);
      } else {
        activeJadwals.add(j);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jadwal Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13, 
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                if (activeJadwals.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${activeJadwals.length} Obat',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15BE77),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (activeJadwals.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF15BE77),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada jadwal obat hari ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selamat! Tubuh Anda sehat. Semua jadwal hari ini kosong.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, 
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...activeJadwals.map(
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
          statusIcon = Icons.error_outline_rounded;
          break;
        case _JadwalStatus.upcoming:
          statusColor = const Color(0xFF64748B);
          statusBg = const Color(0xFFF1F5F9);
          statusLabel = 'Akan Datang';
          statusIcon = Icons.schedule_rounded;
          break;
        case _JadwalStatus.expired:
          statusColor = const Color(0xFFFF4D4D);
          statusBg = const Color(0xFFFFECEC);
          statusLabel = 'Terlewat';
          statusIcon = Icons.cancel_rounded;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTaken ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTaken ? null : () => _markAsTaken(jadwal, pasienId),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // EMOJI OBAT / ICON
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getPillEmoji(jadwal.namaObat),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // INFO OBAT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.namaObat,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isTaken ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${jadwal.jumlahDosis} ${jadwal.satuan}  •  ${jadwal.aturanKonsumsi}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      // BADGES ROW
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jadwal.waktuMinum,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    fontFamily: 'Inter',
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
                const SizedBox(width: 8),

                // INTERACTIVE LARGE ACTION BUTTON
                GestureDetector(
                  onTap: isTaken ? null : () => _markAsTaken(jadwal, pasienId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isTaken ? const Color(0xFF15BE77) : Colors.white,
                      border: Border.all(
                        color: isTaken 
                            ? const Color(0xFF15BE77) 
                            : status == _JadwalStatus.upcoming
                                ? const Color(0xFFCBD5E1)
                                : statusColor,
                        width: 2.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isTaken
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          )
                        : Icon(
                            Icons.check_rounded,
                            color: status == _JadwalStatus.upcoming
                                ? const Color(0xFFCBD5E1)
                                : statusColor.withValues(alpha: 0.5),
                            size: 20,
                          ),
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

  // --- BOTTOM NAV (ACCESSIBLE LABELED BAR) ---
  Widget _buildBottomNav() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME TAB
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.home_rounded,
                    color: Color(0xFF15BE77),
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Beranda',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15BE77),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ADD ROUTINE TAB (CENTER PLUS)
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RutinitasSehatScreen(initialIndex: 1),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15BE77),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF15BE77).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PROFILE TAB
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const ProfileScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.person_rounded,
                    color: Color(0xFF94A3B8),
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  String _getMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _loadRutinitas() async {
    if (!mounted) return;
    setState(() => _loadingRutinitas = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/pasien/rutinitas"),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _listRutinitas = data['data'] ?? [];
          });
        }
      } else {
        debugPrint('[Rutinitas] HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[Rutinitas] Error: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingRutinitas = false);
      }
    }
  }

  Future<void> _toggleRutinitasTracking(dynamic item, bool isChecked) async {
    try {
      final token = await AuthService.getToken();
      final newStatus = isChecked ? 'done' : 'none';
      
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/pasien/rutinitas/tracking"),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rutinitas_id': item['id'],
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          item['today_status'] = newStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChecked 
                ? 'Rutinitas "${item['nama_rutinitas']}" selesai! 🏆' 
                : 'Rutinitas dibatalkan.'),
            backgroundColor: const Color(0xFF15BE77),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        if (!mounted) return;
        final errorMsg = jsonDecode(response.body)['error'] ?? 'Gagal memperbarui status';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $errorMsg'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error toggling routine tracking: $e");
    }
  }

  Widget _buildRutinitasHariIniList() {
    if (_loadingRutinitas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF15BE77))),
      );
    }

    if (_listRutinitas.isEmpty) {
      return const SizedBox.shrink(); // Hide if empty to keep it compact
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Rutinitas Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ceklis aktivitas sehat Anda hari ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_listRutinitas.length} Rutinitas',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._listRutinitas.map((item) {
            final isDone = item['today_status'] == 'done';
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDone ? const Color(0xFFE8F8F1) : const Color(0xFFF1F5F9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleRutinitasTracking(item, !isDone),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFFE8F8F1) : const Color(0xFFF5F3FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: isDone ? const Color(0xFF15BE77) : const Color(0xFF8B5CF6),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_rutinitas'] ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDone ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['waktu_reminder'] ?? '00:00',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _toggleRutinitasTracking(item, !isDone),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFF15BE77) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone ? const Color(0xFF15BE77) : const Color(0xFFCBD5E1),
                                width: 2.0,
                              ),
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFFCBD5E1),
                                    size: 18,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

enum _JadwalStatus { onTime, late, upcoming, expired }

