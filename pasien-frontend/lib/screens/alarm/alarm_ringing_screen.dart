import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _parsePayload();

    // Pastikan suara alarm berbunyi terus menerus saat layar ini terbuka
    FlutterRingtonePlayer().playAlarm();

    // Animasi denyut (pulse) untuk lingkaran
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _parsePayload() {
    try {
      final parts = widget.payload.split(':');
      if (parts.isNotEmpty) _jadwalId = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) _namaObat = parts.sublist(1).join(':');
      debugPrint('[AlarmRingingScreen] Parsed Jadwal ID: $_jadwalId, Nama Obat: $_namaObat');
    } catch (e) {
      debugPrint('[AlarmRingingScreen] Error parse payload: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    FlutterRingtonePlayer().stop(); // Hentikan suara saat layar ditutup
    super.dispose();
  }

  void _handleMatikanAlarm() {
    FlutterRingtonePlayer().stop(); // Hentikan suara alarm
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // Fallback: load session dan go to DashboardScreen jika dibuka langsung dari background/killed state
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
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Icon Lonceng dengan Animasi Pulse
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2BB673).withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFF2BB673),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.alarm_on,
                  size: 80,
                  color: Color(0xFF2BB673),
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

            // Nama Obat
            const Text(
              'Waktunya Minum Obat!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _namaObat,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                'Halo! Yuk, minum obat dulu dan centang daftarnya di halaman utama.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),


            const Spacer(flex: 3),

            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4D), // Merah mencolok khas mematikan alarm
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFF4D4D).withValues(alpha: 0.5),
                  ),
                  onPressed: _handleMatikanAlarm,
                  icon: const Icon(Icons.alarm_off, size: 28),
                  label: const Text(
                    'MATIKAN ALARM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
