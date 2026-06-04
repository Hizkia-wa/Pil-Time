import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../dashboard_screen.dart';

class AlarmRingingScreen extends StatefulWidget {
  final String payload; // Format: "jadwalId:namaObat"

  const AlarmRingingScreen({super.key, required this.payload});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _namaObat = 'Obat';
  int _jadwalId = 0;
  bool _isRoutine = false;

  // ── Kategori Terlambat ──
  bool _isTerlambat = false;
  int _sisaMenitToleransi = 15;

  // ── Kontrol Pemutaran Suara Kustom & Alarm Sistem ──
  Timer? _customSoundTimer;
  int _playCount = 0;
  Timer? _autoDismissTimer;
  String _scheduledTime = '';

  @override
  void initState() {
    super.initState();
    _parsePayload();

    // Beri tahu NotificationService bahwa AlarmScreen sedang aktif.
    // Ini menekan semua pop-up/heads-up notifikasi baru agar tidak mengganggu.
    NotificationService.instance.activeAlarmScreensCount++;
    NotificationService.instance.isAlarmScreenActive = true;

    // Mulai sequence suara: suara kustom 3x → lalu alarm sistem (obat)
    // atau loop MP3 rutinitas (rutinitas)
    _startAlarmSoundSequence();

    // Auto-dismiss setelah 60 detik jika diabaikan oleh user (mati sendiri)
    _autoDismissTimer = Timer(const Duration(seconds: 60), () {
      debugPrint('[PilTime] Alarm diabaikan selama 60 detik. Menutup layar alarm otomatis (mati sendiri).');
      _handleMatikanAlarm(isAutoDismiss: true);
    });

    // Animasi denyut (pulse) untuk lingkaran
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAlarmSoundSequence() {
    // Pilih file audio sesuai tipe alarm:
    // - Rutinitas → rutinitas_alarm.mp3
    // - Jadwal Obat → alarm_voice.mp3
    final audioAsset = _isRoutine
        ? 'assets/audio/rutinitas_alarm.mp3'
        : 'assets/audio/alarm_voice.mp3';

    _playCount = 1;
    debugPrint('[PilTime] Memutar suara kustom $audioAsset untuk pertama kali (1/3)');
    FlutterRingtonePlayer().play(
      fromAsset: audioAsset,
      looping: false,
      volume: 1.0,
      asAlarm: true,
    );

    // Timer periodic setiap 4000ms
    _customSoundTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_playCount < 3) {
        _playCount++;
        debugPrint('[PilTime] Memutar suara kustom $audioAsset ($_playCount/3)');
        FlutterRingtonePlayer().play(
          fromAsset: audioAsset,
          looping: false,
          volume: 1.0,
          asAlarm: true,
        );
      } else {
        timer.cancel();
        _customSoundTimer = null;

        if (_isRoutine) {
          // Rutinitas: loop MP3 rutinitas (konsisten, tidak switch ke suara sistem)
          debugPrint('[PilTime] Suara kustom rutinitas selesai 3x. Loop rutinitas_alarm.mp3.');
          FlutterRingtonePlayer().play(
            fromAsset: audioAsset,
            looping: true,
            volume: 1.0,
            asAlarm: true,
          );
        } else {
          // Jadwal Obat: switch ke alarm sistem (looping)
          debugPrint('[PilTime] Suara kustom obat selesai 3x. Beralih ke suara alarm sistem (looping)');
          FlutterRingtonePlayer().playAlarm(
            looping: true,
            volume: 1.0,
            asAlarm: true,
          );
        }
      }
    });
  }

  void _parsePayload() {
    try {
      final parts = widget.payload.split(':');
      if (parts.isNotEmpty && parts[0] == 'routine') {
        _isRoutine = true;
        if (parts.length > 1) _jadwalId = int.tryParse(parts[1]) ?? 0;
        if (parts.length > 2) _namaObat = parts[2];
        if (parts.length > 3) _scheduledTime = parts[3];
      } else {
        if (parts.isNotEmpty) _jadwalId = int.tryParse(parts[0]) ?? 0;
        if (parts.length > 2) {
          _scheduledTime = parts.last;
          _namaObat = parts.sublist(1, parts.length - 1).join(':');
        } else if (parts.length > 1) {
          _namaObat = parts.last;
        }

        // Hitung apakah sudah masuk rentang terlambat (60 - 75 menit)
        if (_scheduledTime.isNotEmpty) {
          final timeParts = _scheduledTime.split(':');
          if (timeParts.length == 2) {
            final now = DateTime.now();
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            final scheduledDt = DateTime(now.year, now.month, now.day, hour, minute);
            
            final diff = now.difference(scheduledDt).inMinutes;
            // Rentang waktu Terlambat (60 - 75 menit)
            if (diff >= 60 && diff <= 75) {
              _isTerlambat = true;
              _sisaMenitToleransi = 75 - diff;
              if (_sisaMenitToleransi < 0) _sisaMenitToleransi = 0;
            }
          }
        }
      }

      debugPrint(
        '[AlarmRingingScreen] Parsed Jadwal ID: $_jadwalId, Nama Obat/Aktivitas: $_namaObat, Scheduled Time: $_scheduledTime, isTerlambat: $_isTerlambat, sisaMenit: $_sisaMenitToleransi, isRoutine: $_isRoutine',
      );
    } catch (e) {
      debugPrint('[AlarmRingingScreen] Error parse payload: $e');
    }
  }

  @override
  void dispose() {
    // Beritahu NotificationService bahwa AlarmScreen sudah tidak aktif
    // (menggunakan counter agar aman saat transisi antar AlarmScreen berurutan).
    NotificationService.instance.activeAlarmScreensCount--;
    if (NotificationService.instance.activeAlarmScreensCount <= 0) {
      NotificationService.instance.isAlarmScreenActive = false;
      NotificationService.instance.activeAlarmScreensCount = 0;
    }
    _pulseController.dispose();
    _customSoundTimer?.cancel();
    _customSoundTimer = null;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    FlutterRingtonePlayer().stop(); // Hentikan semua suara saat layar ditutup
    super.dispose();
  }

  void _handleMatikanAlarm({bool isSnooze = false, bool isAutoDismiss = false}) {
    _customSoundTimer?.cancel();
    _customSoundTimer = null;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    FlutterRingtonePlayer().stop(); // Hentikan semua suara alarm
    
    if (mounted) {
      if (!isSnooze && !isAutoDismiss) {
        // Tampilkan petunjuk centang secara global dengan SnackBar Premium
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _isRoutine
                      ? Icons.check_circle_outline_rounded
                      : (_isTerlambat ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isRoutine
                        ? 'Alarm dimatikan. Yuk centang rutinitas "$_namaObat" di dashboard agar tercatat! 🏃'
                        : (_isTerlambat
                            ? 'Alarm dimatikan. Status Anda saat ini TERLAMBAT! Yuk segera centang jadwal "$_namaObat" di dashboard agar tidak berubah jadi Terlewat! ⚠️'
                            : 'Alarm dimatikan. Yuk centang jadwal minum obat "$_namaObat" di bawah ini agar tercatat! 💊'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: _isRoutine
                ? const Color(0xFF15BE77)
                : (_isTerlambat ? const Color(0xFFEA580C) : const Color(0xFF15BE77)), // Orange vs Emerald Green
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      // Cek apakah masih ada alarm lain yang mengantre
      final nextAlarmPayload = NotificationService.instance.showNextAlarm();
      if (nextAlarmPayload != null) {
        // Ganti layar saat ini dengan layar alarm yang baru dari antrean
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AlarmRingingScreen(payload: nextAlarmPayload),
            settings: const RouteSettings(name: '/alarm-ringing'),
          ),
        );
      } else {
        // Jika antrean kosong, arahkan langsung ke dashboard agar pasien melihat checklist
        AuthService.getPasienSession().then((session) {
          if (session != null && mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  pasienId: session['pasien_id'],
                  pasienNama: session['pasien_name'],
                ),
              ),
              (route) => false,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background gelap khas alarm
      backgroundColor: _isTerlambat ? null : const Color(0xFF0F172A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _isTerlambat
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E0A0A), // Deep Burgundy/Crimson Dark
                    Color(0xFF1A0505),
                    Color(0xFF0F172A), // Slate Dark
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon Lonceng/Warning dengan Animasi Pulse
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_isRoutine 
                        ? const Color(0xFF15BE77)
                        : (_isTerlambat ? const Color(0xFFEF4444) : const Color(0xFF2BB673))).withValues(alpha: 0.2),
                    border: Border.all(
                      color: _isRoutine 
                          ? const Color(0xFF15BE77)
                          : (_isTerlambat ? const Color(0xFFEF4444) : const Color(0xFF2BB673)),
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    _isRoutine 
                        ? Icons.directions_run_rounded 
                        : (_isTerlambat ? Icons.warning_amber_rounded : Icons.alarm_on),
                    size: 80,
                    color: _isRoutine 
                        ? const Color(0xFF15BE77)
                        : (_isTerlambat ? const Color(0xFFEF4444) : const Color(0xFF2BB673)),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Waktu Sekarang
              Text(
                '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // Nama Obat / Status
              Text(
                _isRoutine
                    ? 'Waktunya Aktivitas Sehat!'
                    : (_isTerlambat ? '⚠️ STATUS TERLAMBAT!' : 'Waktunya Minum Obat!'),
                style: TextStyle(
                  fontSize: 20,
                  color: _isTerlambat ? const Color(0xFFF59E0B) : Colors.white70, // Amber warning color
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _namaObat,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Sisa waktu toleransi widget
              if (_isTerlambat) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFFFF9F0A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sisa Toleransi Waktu: $_sisaMenitToleransi Menit Lagi!',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFF9F0A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _isRoutine
                      ? 'Halo! Yuk, lakukan aktivitas sehat ini dan centang daftarnya di halaman utama.'
                      : (_isTerlambat
                          ? 'PENTING: Waktu minum obat Anda sudah terlambat! Segera matikan alarm dan lakukan pencatatan agar kepatuhan Anda tetap baik!'
                          : 'Halo! Yuk, minum obat dulu dan centang daftarnya di halaman utama.'),
                  style: TextStyle(
                    fontSize: 14,
                    color: _isTerlambat ? const Color(0xFFCBD5E1) : Colors.white60,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),

              // Tombol Aksi Stacked (Column)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // 1. Tombol MATIKAN ALARM (Red/Orange, Premium)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRoutine
                              ? const Color(0xFF15BE77)
                              : (_isTerlambat ? const Color(0xFFEA580C) : const Color(0xFFFF4D4D)),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: (_isRoutine
                                  ? const Color(0xFF15BE77)
                                  : (_isTerlambat ? const Color(0xFFEA580C) : const Color(0xFFFF4D4D)))
                              .withValues(alpha: 0.3),
                        ),
                        onPressed: () => _handleMatikanAlarm(isSnooze: false),
                        icon: const Icon(Icons.alarm_off_rounded, size: 24),
                        label: const Text(
                          'MATIKAN ALARM',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // 2. Tombol INGATKAN NANTI (SNOOZE 20M)
                    if (!_isRoutine) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _handleMatikanAlarm(isSnooze: true),
                          icon: const Icon(Icons.snooze_rounded, size: 20),
                          label: const Text(
                            'INGATKAN NANTI (SNOOZE 20M)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}