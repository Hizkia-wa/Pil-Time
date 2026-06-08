import 'package:flutter/material.dart';
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
import '../services/notification_storage_service.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/notifikasi/notifikasi_bloc.dart';
import '../bloc/notifikasi/notifikasi_event.dart';
import '../bloc/notifikasi/notifikasi_state.dart';
import '../services/permission_service.dart';
import '../utils/dialog_helper.dart';

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
  // Track slot waktu obat mandiri yang sudah ditandai (key: "jadwalId_waktu")
  final Set<String> _takenMandiriSlots = {};
  bool _notificationPermissionGranted = true;
  int _unreadNotificationCount = 0;

  // Properti Rutinitas Sehat
  List<dynamic> _listRutinitas = [];
  bool _loadingRutinitas = true;

  Future<void> _loadUnreadCount(List<Jadwal> todayJadwals, Set<int> takenJadwalIds) async {
    try {
      final riwayatResponse = await ApiService.getPasienRiwayat();
      final riwayatData = riwayatResponse['success'] ? (riwayatResponse['data'] as List<dynamic>) : [];
      final count = await NotificationStorageService.instance.getUnreadCount(
        todayJadwals: todayJadwals.map((j) => j.toJson()).toList(),
        takenJadwalIds: takenJadwalIds,
        riwayatData: riwayatData,
      );
      if (mounted && _unreadNotificationCount != count) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (_) {}
  }

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
      context.read<NotifikasiBloc>().add(FetchNotifications(pasienId: widget.pasienId));
      final currentState = _dashboardBloc.state;
      if (currentState is DashboardLoaded) {
        _loadUnreadCount(currentState.dashboard.todayJadwals, currentState.takenJadwalIds);
      }
      // Minta izin alarm (overlay + battery) saat pertama kali masuk dashboard
      PermissionService.instance.requestAlarmPermissions(context);
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
    context.read<NotifikasiBloc>().add(FetchNotifications(pasienId: widget.pasienId));
  }



  /// Log jadwal sebagai 'Diminum' ke backend tracking API
  Future<void> _markAsTaken(Jadwal jadwal, int pasienId) async {
    // Obat mandiri tidak memiliki waktu minum tunggal, langsung bisa dichecklist
    if (jadwal.kategoriObat != 'Mandiri') {
      final status = _getJadwalStatus(jadwal.waktuMinum);
      if (status == _JadwalStatus.upcoming) {
        if (mounted) {
          final formattedWaktu = _formatWaktuMinum(jadwal.waktuMinum);
          DialogHelper.showErrorDialog(
            context: context,
            title: 'Perhatian',
            message: 'Belum memasuki waktu minum obat ${jadwal.namaObat}! Jadwal Anda adalah pukul $formattedWaktu.',
          );
        }
        return;
      }
      if (status == _JadwalStatus.expired) {
        if (mounted) {
          DialogHelper.showErrorDialog(
            context: context,
            title: 'Terlewat',
            message: 'Waktu minum obat ${jadwal.namaObat} sudah terlewat dan tidak bisa diceklis lagi.',
          );
        }
        return;
      }
    }

    _dashboardBloc.add(MarkAsTaken(jadwal: jadwal, pasienId: pasienId));
  }

  /// Log slot mandiri sebagai 'Diminum'
  Future<void> _markMandiriSlotAsTaken(Jadwal jadwal, int pasienId, String waktuSlot) async {
    final status = _getJadwalStatus(waktuSlot);
    if (status == _JadwalStatus.upcoming) {
      if (mounted) {
        final formattedWaktu = _formatWaktuMinum(waktuSlot);
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Perhatian',
          message: 'Belum memasuki waktu minum obat ${jadwal.namaObat}! Jadwal Anda adalah pukul $formattedWaktu.',
        );
      }
      return;
    }
    if (status == _JadwalStatus.expired) {
      if (mounted) {
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Terlewat',
          message: 'Waktu minum obat mandiri ${jadwal.namaObat} sudah terlewat dan tidak bisa diceklis lagi.',
        );
      }
      return;
    }

    _dashboardBloc.add(MarkMandiriSlotAsTaken(jadwal: jadwal, pasienId: pasienId, waktuSlot: waktuSlot));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: BlocConsumer<DashboardBloc, DashboardState>(
        bloc: _dashboardBloc,
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _loadUnreadCount(state.dashboard.todayJadwals, state.takenJadwalIds);
            context.read<NotifikasiBloc>().add(FetchNotifications(pasienId: widget.pasienId));
          }
          if (state is DashboardFailure && state.statusCode == 401) {
            AuthService.logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else if (state is DashboardMarkingSuccess) {
            DialogHelper.showSuccessDialog(
              context: context,
              title: 'Berhasil',
              message: state.message,
            );
          } else if (state is DashboardMarkingFailure) {
            DialogHelper.showErrorDialog(
              context: context,
              title: 'Gagal',
              message: state.error,
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
            _takenMandiriSlots.clear();
            _takenMandiriSlots.addAll(state.takenMandiriSlots);
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
    // Saring jadwal yang aktif (termasuk mandiri)
    final activeToday = todayJadwals.where((j) => j.status.toLowerCase() == 'aktif').toList();
    
    int totalToday = 0;
    int takenToday = 0;

    for (final j in activeToday) {
      if (j.kategoriObat == 'Mandiri') {
        final slots = j.waktuMinum.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        totalToday += slots.length;
        for (final slot in slots) {
          if (_takenMandiriSlots.contains('${j.id}_$slot')) {
            takenToday++;
          }
        }
      } else {
        totalToday++;
        if (_takenJadwalIds.contains(j.id)) {
          takenToday++;
        }
      }
    }

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
          // Notification bell
          const ModernNotificationBell(),
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
                subLabel: 'Jadwal Pengingat',
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
                label: 'Riwayat Kepatuhan',
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
                label: 'Aktivitas Sehat',
                subLabel: 'Jadwal Aktivitas',
                subLabelColor: const Color(0xFF9C27B0),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RutinitasSehatScreen(),
                    ),
                  );
                  _loadRutinitas();
                  _dashboardBloc.add(FetchDashboard(
                    pasienId: widget.pasienId,
                    pasienNama: widget.pasienNama,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                NotificationService.instance.scheduleTestNotification(
                  namaObat: 'Test Paracetamol',
                  delaySeconds: 5,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alarm test akan berbunyi dalam 5 detik...'),
                    backgroundColor: Color(0xFF15BE77),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text(
                'Test Alarm (5 Detik)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
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
      if (j.kategoriObat == 'Mandiri') continue;
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
  String _formatWaktuMinum(String raw) {
    final slots = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final formattedSlots = slots.map((slot) {
      final numericOnly = slot.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericOnly.length == 4) {
        return '${numericOnly.substring(0, 2)}:${numericOnly.substring(2, 4)}';
      }
      return slot;
    });
    return formattedSlots.join(', ');
  }

  _JadwalStatus _getJadwalStatus(String waktuMinum) {
    try {
      final now = DateTime.now();
      final formatted = _formatWaktuMinum(waktuMinum);
      final slots = formatted.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      
      _JadwalStatus overallStatus = _JadwalStatus.upcoming;
      
      for (final slot in slots) {
        final parts = slot.split(':');
        if (parts.length < 2) continue;
        final jadwalDt = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
        );
        if (now.isBefore(jadwalDt)) continue;
        final diffMinutes = now.difference(jadwalDt).inMinutes;
        
        _JadwalStatus slotStatus;
        if (diffMinutes > 75) {
          slotStatus = _JadwalStatus.expired;
        } else if (diffMinutes <= 60) {
          slotStatus = _JadwalStatus.onTime;
        } else {
          slotStatus = _JadwalStatus.late;
        }
        
        if (slotStatus == _JadwalStatus.onTime || slotStatus == _JadwalStatus.late) {
          return slotStatus;
        }
        if (slotStatus == _JadwalStatus.expired) {
          overallStatus = _JadwalStatus.expired;
        }
      }
      return overallStatus;
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

    // Pisahkan obat biasa (non-mandiri) vs obat mandiri
    final activeJadwals = <Jadwal>[];
    final mandiriJadwals = <Jadwal>[];

    for (final j in jadwals) {
      if (j.kategoriObat == 'Mandiri') {
        if (j.status.toLowerCase() == 'aktif') {
          mandiriJadwals.add(j);
        }
        continue;
      }
      // Obat yang sudah diminum tidak perlu ditampilkan lagi
      if (_takenJadwalIds.contains(j.id)) {
        continue;
      }
      final status = _getJadwalStatus(j.waktuMinum);
      if (status != _JadwalStatus.expired) {
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
                      'Obat Hari Ini',
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

          if (activeJadwals.isEmpty && mandiriJadwals.isEmpty)
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

          // Bagian Obat Mandiri
          if (mandiriJadwals.isNotEmpty) ..._buildMandiriSection(mandiriJadwals, pasienId),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Bangun section obat mandiri dengan header dan kartu tersendiri per slot waktu
  List<Widget> _buildMandiriSection(List<Jadwal> mandiriJadwals, int pasienId) {
    final widgets = <Widget>[];
    int totalSlots = 0;

    for (final jadwal in mandiriJadwals) {
      final slots = jadwal.waktuMinum.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      totalSlots += slots.length;

      // Urutkan slot berdasarkan waktu
      slots.sort();

      for (final slot in slots) {
        widgets.add(_buildJadwalCard(
          jadwal: jadwal,
          pasienId: pasienId,
          isMandiri: true,
          mandiriSlotTime: slot,
        ));
      }
    }

    return [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Obat Mandiri Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Roboto',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalSlots Jadwal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
      ...widgets,
    ];
  }

  Widget _buildJadwalCard({
    required Jadwal jadwal,
    required int pasienId,
    bool isMandiri = false,
    String? mandiriSlotTime,
  }) {
    final bool isTaken;
    final _JadwalStatus status;

    if (isMandiri && mandiriSlotTime != null) {
      isTaken = _takenMandiriSlots.contains('${jadwal.id}_$mandiriSlotTime');
      status = isTaken ? _JadwalStatus.onTime : _getJadwalStatus(mandiriSlotTime);
    } else {
      isTaken = _takenJadwalIds.contains(jadwal.id);
      status = isTaken ? _JadwalStatus.onTime : _getJadwalStatus(jadwal.waktuMinum);
    }

    final Color statusColor;
    final Color statusBg;
    final String statusLabel;
    final IconData statusIcon;

    if (isTaken) {
      statusColor = const Color(0xFF15BE77);
      statusBg = const Color(0xFFE8F8F1);
      statusLabel = 'Sudah Diminum';
      statusIcon = Icons.check_circle_rounded;
    } else if (isMandiri) {
      // Obat mandiri: tampilkan warna orange untuk aktif, abu-abu untuk akan datang
      if (status == _JadwalStatus.upcoming) {
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusLabel = 'Akan Datang';
        statusIcon = Icons.schedule_rounded;
      } else if (status == _JadwalStatus.late) {
        statusColor = const Color(0xFFF97316);
        statusBg = const Color(0xFFFFF7ED);
        statusLabel = 'Segera Minum';
        statusIcon = Icons.error_outline_rounded;
      } else if (status == _JadwalStatus.expired) {
        statusColor = const Color(0xFFFF4D4D);
        statusBg = const Color(0xFFFFECEC);
        statusLabel = 'Terlewat';
        statusIcon = Icons.cancel_rounded;
      } else {
        statusColor = const Color(0xFFF97316);
        statusBg = const Color(0xFFFFF7ED);
        statusLabel = 'Waktunya Minum!';
        statusIcon = Icons.alarm_on_rounded;
      }
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
          onTap: isTaken
              ? null
              : (isMandiri && mandiriSlotTime != null)
                  ? () => _markMandiriSlotAsTaken(jadwal, pasienId, mandiriSlotTime)
                  : () => _markAsTaken(jadwal, pasienId),
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
                                  _formatWaktuMinum(isMandiri ? (mandiriSlotTime ?? jadwal.waktuMinum) : jadwal.waktuMinum),
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
                  onTap: isTaken
                      ? null
                      : (isMandiri && mandiriSlotTime != null)
                          ? () => _markMandiriSlotAsTaken(jadwal, pasienId, mandiriSlotTime)
                          : () => _markAsTaken(jadwal, pasienId),
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
                                ? const Color(0xFFE2E8F0)
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
                            status == _JadwalStatus.upcoming 
                                ? Icons.lock_rounded 
                                : status == _JadwalStatus.expired 
                                    ? Icons.close_rounded 
                                    : Icons.check_rounded,
                            color: status == _JadwalStatus.upcoming
                                ? const Color(0xFFCBD5E1)
                                : statusColor.withValues(alpha: 0.5),
                            size: status == _JadwalStatus.upcoming ? 16 : 20,
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
      height: 78,
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
          _BottomNavTab(
            icon: Icons.home_rounded,
            label: 'Beranda',
            isActive: true,
            onTap: () {},
          ),

          // ADD MEDICINE TAB (CENTER PLUS)
          _BottomNavCenterButton(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RutinitasSehatScreen(initialIndex: 0),
                ),
              );
              _loadRutinitas();
            },
          ),

          // PROFILE TAB
          _BottomNavTab(
            icon: Icons.person_rounded,
            label: 'Profil',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const ProfileScreen(),
                ),
              );
            },
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

  bool _isTimeReached(String waktuReminder) {
    try {
      final parts = waktuReminder.split(':');
      if (parts.length < 2) return true;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = DateTime.now();
      if (now.hour > hour) {
        return true;
      } else if (now.hour == hour) {
        return now.minute >= minute;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> _scheduleRutinitasAlarms(List<dynamic> routines) async {
    try {
      await NotificationService.instance.cancelAllRoutineAlarms();
      for (final item in routines) {
        final status = item['today_status'] ?? 'none';
        final isDone = status == 'done';
        final id = item['id'];
        final nama = item['nama_rutinitas'] ?? '';
        final waktu = _formatWaktuMinum(item['waktu_reminder'] ?? '');
        final deskripsi = item['deskripsi'] ?? '';
        if (id != null && waktu.isNotEmpty) {
          await NotificationService.instance.scheduleRutinitasNotification(
            notifId: id,
            namaRutinitas: nama,
            waktuReminder: waktu,
            rutinitasId: id,
            deskripsi: deskripsi,
            startFromTomorrow: isDone,
          );
        }
      }
    } catch (e) {
      debugPrint('[Dashboard] Error scheduling routines: $e');
    }
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
          _scheduleRutinitasAlarms(_listRutinitas);
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
    final waktu = _formatWaktuMinum(item['waktu_reminder'] ?? '');
    var cleanWaktu = waktu.trim();
    final timeParts = cleanWaktu.split(':');
    if (timeParts.length > 2) {
      cleanWaktu = '${timeParts[0]}:${timeParts[1]}';
    }

    if (isChecked && !_isTimeReached(cleanWaktu)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Belum waktunya! Silakan lakukan aktivitas ini mulai pukul $cleanWaktu.'),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

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
        if (isChecked) {
          await NotificationService.instance.cancelRutinitas(item['id']);
        } else {
          await _scheduleRutinitasAlarms(_listRutinitas);
        }
        if (!mounted) return;
        DialogHelper.showSuccessDialog(
          context: context,
          title: 'Berhasil',
          message: isChecked 
                ? 'Rutinitas "${item['nama_rutinitas']}" selesai!' 
                : 'Rutinitas dibatalkan.',
        );
      } else {
        if (!mounted) return;
        final errorMsg = jsonDecode(response.body)['error'] ?? 'Gagal memperbarui status';
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Gagal',
          message: errorMsg,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Roboto',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '0 Aktivitas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada aktivitas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tambahkan rutinitas sehat Anda untuk hari ini.',
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
        ],
      );
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
                      'Aktivitas Hari Ini',
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
            final waktu = _formatWaktuMinum((item['waktu_reminder'] ?? '').trim());
            final timeParts = waktu.split(':');
            final cleanWaktu = timeParts.length > 2
                ? '${timeParts[0]}:${timeParts[1]}'
                : waktu;
            final timeReached = _isTimeReached(cleanWaktu);
            // Checkbox hanya bisa diklik jika waktu sudah tiba DAN belum selesai
            final canCheck = !isDone && timeReached;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFFE8F8F1)
                      : timeReached
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFE2E8F0),
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
                  onTap: canCheck
                      ? () => _toggleRutinitasTracking(item, true)
                      : !isDone
                          ? () {
                              DialogHelper.showErrorDialog(
                                context: context,
                                title: 'Perhatian',
                                message: 'Belum waktunya! Rutinitas ini bisa diceklis mulai pukul $cleanWaktu.',
                              );
                            }
                          : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFFE8F8F1)
                                : timeReached
                                    ? const Color(0xFFF5F3FF)
                                    : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: isDone
                                ? const Color(0xFF15BE77)
                                : timeReached
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFFCBD5E1),
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
                                  color: isDone
                                      ? const Color(0xFF64748B)
                                      : timeReached
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF94A3B8),
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.access_time_rounded
                                        : timeReached
                                            ? Icons.access_time_rounded
                                            : Icons.lock_clock,
                                    color: isDone
                                        ? const Color(0xFF64748B)
                                        : timeReached
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFFCBD5E1),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeReached || isDone
                                        ? cleanWaktu.isEmpty ? '00:00' : cleanWaktu
                                        : 'Tersedia pukul $cleanWaktu',
                                    style: TextStyle(
                                      color: isDone
                                          ? const Color(0xFF64748B)
                                          : timeReached
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFFCBD5E1),
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
                        // Checkbox — terkunci jika belum waktunya
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: canCheck
                              ? () => _toggleRutinitasTracking(item, true)
                              : !isDone
                                  ? () {
                                      DialogHelper.showErrorDialog(
                                        context: context,
                                        title: 'Perhatian',
                                        message: 'Belum waktunya! Rutinitas ini bisa diceklis mulai pukul $cleanWaktu.',
                                      );
                                    }
                                  : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF15BE77)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF15BE77)
                                    : timeReached
                                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                                        : const Color(0xFFE2E8F0),
                                width: 2.0,
                              ),
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Icon(
                                    timeReached ? Icons.check_rounded : Icons.lock_rounded,
                                    color: timeReached
                                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                                        : const Color(0xFFE2E8F0),
                                    size: timeReached ? 18 : 14,
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

class _BottomNavTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_BottomNavTab> createState() => _BottomNavTabState();
}

class _BottomNavTabState extends State<_BottomNavTab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF15BE77);
    const inactiveColor = Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isActive ? 16 : 8,
                  vertical: widget.isActive ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: widget.isActive 
                      ? activeColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: widget.isActive ? 1.15 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Icon(
                    widget.icon,
                    color: widget.isActive ? activeColor : inactiveColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.bold,
                  color: widget.isActive ? activeColor : inactiveColor,
                  fontFamily: 'Inter',
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavCenterButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BottomNavCenterButton({
    required this.onTap,
  });

  @override
  State<_BottomNavCenterButton> createState() => _BottomNavCenterButtonState();
}

class _BottomNavCenterButtonState extends State<_BottomNavCenterButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF15BE77);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernNotificationBell extends StatefulWidget {
  const ModernNotificationBell({super.key});

  @override
  State<ModernNotificationBell> createState() => _ModernNotificationBellState();
}

class _ModernNotificationBellState extends State<ModernNotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotifikasiBloc, NotifikasiState>(
      listener: (context, state) {
        if (state is NotifikasiLoaded) {
          // Trigger subtle scale micro-animation when unread count updates
          _controller.forward().then((_) => _controller.reverse());
        }
      },
      builder: (context, state) {
        final unreadCount = state is NotifikasiLoaded
            ? state.allNotifications.where((n) => !n.isRead).length
            : 0;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF475569),
                    size: 24,
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

