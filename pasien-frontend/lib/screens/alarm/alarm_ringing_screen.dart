import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../services/api_service.dart';

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

  bool _isLoading = false;

  void _handleDiminum() async {
    if (_isLoading || _jadwalId == 0) return;
    setState(() => _isLoading = true);

    final now = TimeOfDay.now();
    final waktuMinum = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final result = await ApiService.postRiwayat(
      jadwalId: _jadwalId,
      status: 'Diminum',
      waktuMinum: waktuMinum,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Obat ditandai telah diminum!'),
            backgroundColor: Color(0xFF2BB673),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: ${result['error']}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleLewati() async {
    if (_isLoading || _jadwalId == 0) return;
    setState(() => _isLoading = true);

    final now = TimeOfDay.now();
    final waktuMinum = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final result = await ApiService.postRiwayat(
      jadwalId: _jadwalId,
      status: 'Terlewat',
      waktuMinum: waktuMinum,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Anda melewati jadwal obat ini.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: ${result['error']}'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
            const SizedBox(height: 8),
            Text(
              _namaObat,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 3),

            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Tombol Diminum (Primary)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2BB673),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF2BB673).withValues(alpha: 0.5),
                      ),
                      onPressed: _isLoading ? null : _handleDiminum,
                      icon: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle, size: 28),
                      label: Text(
                        _isLoading ? 'MENYIMPAN...' : 'TANDAI DIMINUM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Lewati (Secondary/Danger)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLewati,
                      icon: const Icon(Icons.close, size: 24),
                      label: const Text(
                        'LEWATI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
