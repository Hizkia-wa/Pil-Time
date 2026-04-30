import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../models/dashboard.dart';
import '../../models/jadwal.dart';
import '../../models/reminder.dart';

class AlarmScreen extends StatefulWidget {
  final int pasienId;

  const AlarmScreen({
    super.key,
    required this.pasienId,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late Future<List<ReminderGroup>> _remindersFuture;
  bool _alarmsActive = true; // Track status alarm global

  @override
  void initState() {
    super.initState();
    _remindersFuture = _fetchAndScheduleReminders();
  }

  // ── Fetch jadwal & langsung schedule notifikasi ─────────────────
  Future<List<ReminderGroup>> _fetchAndScheduleReminders() async {
    try {
      final response = await ApiService.getDashboard(pasienId: widget.pasienId);
      if (!response['success']) {
        throw Exception(response['error'] ?? 'Gagal mengambil data jadwal');
      }

      final dashboard = Dashboard.fromJson(response['data']);
      final reminders = _extractReminders(dashboard.todayJadwals);

      // ── Scheduling alarm TERPISAH dari fetch data (fire-and-forget) ──
      // Jika scheduling gagal (misal permission belum diberikan),
      // data jadwal tetap tampil di UI — tidak ikut throw exception.
      if (_alarmsActive) {
        _scheduleAlarmsBackground(dashboard.todayJadwals);
      }

      return reminders;
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      rethrow;
    }
  }

  /// Jalankan scheduling alarm di background — tidak memblokir UI.
  void _scheduleAlarmsBackground(List<Jadwal> jadwals) {
    Future(() async {
      try {
        final notifModels = jadwals
            .where((j) => j.status.toLowerCase() == 'aktif')
            .map((j) => JadwalNotifModel(
                  jadwalId: j.id,
                  namaObat: j.namaObat,
                  dosis: '${j.jumlahDosis} ${j.satuan}',
                  waktuMinum: j.waktuMinum,
                  waktuReminderPagi: j.waktuReminderPagi,
                  waktuReminderMalam: j.waktuReminderMalam,
                ))
            .toList();

        await NotificationService.instance.scheduleAllJadwals(notifModels);
        debugPrint('[AlarmScreen] ${notifModels.length} alarm dijadwalkan.');
      } catch (e) {
        // Alarm gagal tidak boleh crash UI — cukup log
        debugPrint('[AlarmScreen] Gagal jadwalkan alarm (non-fatal): $e');
      }
    });
  }

  List<ReminderGroup> _extractReminders(List<Jadwal> jadwals) {
    final Map<String, List<Reminder>> reminderMap = {};

    for (var jadwal in jadwals) {
      if (jadwal.status.toLowerCase() != 'aktif') continue;

      if (jadwal.waktuMinum.isNotEmpty) {
        _addReminderToMap(reminderMap, jadwal.waktuMinum, jadwal);
      }
      if (jadwal.waktuReminderPagi.isNotEmpty &&
          jadwal.waktuReminderPagi != jadwal.waktuMinum) {
        _addReminderToMap(reminderMap, jadwal.waktuReminderPagi, jadwal);
      }
      if (jadwal.waktuReminderMalam.isNotEmpty &&
          jadwal.waktuReminderMalam != jadwal.waktuMinum) {
        _addReminderToMap(reminderMap, jadwal.waktuReminderMalam, jadwal);
      }
    }

    final sortedTimes = reminderMap.keys.toList()..sort();
    return sortedTimes
        .map((time) => ReminderGroup(
              time: time,
              reminders: reminderMap[time] ?? [],
            ))
        .toList();
  }

  void _addReminderToMap(
      Map<String, List<Reminder>> map, String time, Jadwal jadwal) {
    if (!map.containsKey(time)) {
      map[time] = [];
    }
    map[time]!.add(
      Reminder(
        id: jadwal.id,
        time: time,
        namaObat: jadwal.namaObat,
        jumlahDosis: jadwal.jumlahDosis,
        satuan: jadwal.satuan,
        kategoriObat: jadwal.kategoriObat,
        jadwalId: jadwal.id.toString(),
        status: 'pending',
      ),
    );
  }

  // ── Toggle ON / OFF semua alarm ──────────────────────────────────
  Future<void> _toggleAlarms() async {
    if (_alarmsActive) {
      // Matikan semua alarm
      await NotificationService.instance.cancelAll();
      setState(() => _alarmsActive = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔕 Semua alarm telah dimatikan'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Nyalakan kembali — reload & re-schedule
      setState(() {
        _alarmsActive = true;
        _remindersFuture = _fetchAndScheduleReminders();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Alarm dijadwalkan ulang'),
            backgroundColor: Color(0xFF2BB673),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ── TEST: Kirim notifikasi 5 detik dari sekarang ──────────────────
  // Gunakan ini untuk verifikasi bahwa notifikasi berfungsi.
  // Tombol ini aman untuk dihapus setelah testing selesai.
  Future<void> _testNotifikasi(List<ReminderGroup> groups) async {
    final namaObat = groups.isNotEmpty && groups.first.reminders.isNotEmpty
        ? groups.first.reminders.first.namaObat
        : 'Test Obat';

    // Schedule 5 detik dari sekarang via zonedSchedule (bukan show langsung)
    // sehingga path kode sama persis dengan alarm asli
    await NotificationService.instance.scheduleTestNotification(
      namaObat: namaObat,
      delaySeconds: 5,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.timer, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Notifikasi test akan muncul dalam 5 detik...'),
            ],
          ),
          backgroundColor: Color(0xFF0B1F3A),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // ── TEST: Kirim ALARM 1 menit dari sekarang ─────────────────────────
  // Menggunakan fungsi scheduleJadwalNotification yang persis sama
  // dengan produksi untuk melihat integrasi alarm pada waktu nyata.
  Future<void> _testAlarmSatuMenit(List<ReminderGroup> groups) async {
    final namaObat = groups.isNotEmpty && groups.first.reminders.isNotEmpty
        ? groups.first.reminders.first.namaObat
        : 'Test Obat';

    final now = DateTime.now().add(const Duration(minutes: 1));
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    await NotificationService.instance.scheduleJadwalNotification(
      notifId: 88888, // ID khusus untuk test
      namaObat: '🧪 ALARM TEST: $namaObat',
      dosis: '1 Dosis Uji Coba',
      scheduledTime: timeStr,
      jadwalId: 88888,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.alarm, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Alarm test dijadwalkan pada $timeStr'),
            ],
          ),
          backgroundColor: const Color(0xFF2BB673),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getNextReminderTime(List<ReminderGroup> groups) {
    if (groups.isEmpty) return '--:--';
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (var group in groups) {
      if (group.time.compareTo(currentTime) >= 0) {
        return group.time;
      }
    }
    return groups.isNotEmpty ? groups.first.time : '--:--';
  }

  String _getNextReminderMedicine(List<ReminderGroup> groups) {
    if (groups.isEmpty) return 'Tidak ada jadwal';
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (var group in groups) {
      if (group.time.compareTo(currentTime) >= 0) {
        return group.reminders.isNotEmpty
            ? group.reminders.first.fullInfo
            : 'Obat terjadwal';
      }
    }
    return groups.isNotEmpty && groups.first.reminders.isNotEmpty
        ? groups.first.reminders.first.fullInfo
        : 'Tidak ada jadwal';
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Antibiotik')) return const Color(0xFF4CAF50);
    if (category.contains('Pereda')) return const Color(0xFFFFC107);
    if (category.contains('Suplemen')) return const Color(0xFF2196F3);
    if (category.contains('Flu')) return const Color(0xFF9C27B0);
    if (category.contains('Darah')) return const Color(0xFFF44336);
    return const Color(0xFF607D8B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<List<ReminderGroup>>(
          future: _remindersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Gagal mengambil data jadwal'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => setState(
                          () => _remindersFuture = _fetchAndScheduleReminders()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2BB673),
                      ),
                    ),
                  ],
                ),
              );
            }

            final groups = snapshot.data ?? [];

            return Column(
              children: [
                // ── HEADER ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Reminder dan Alarm',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // ── CARD ALARM BERIKUTNYA ────────────────────────────
                if (groups.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _alarmsActive
                          ? const Color(0xFF0B1F3A)
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _alarmsActive ? 'Alarm berikutnya' : 'Alarm dimatikan',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _alarmsActive ? _getNextReminderTime(groups) : '--:--',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _alarmsActive
                              ? _getNextReminderMedicine(groups)
                              : 'Aktifkan kembali untuk menjadwalkan alarm',
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _chip(
                              _alarmsActive ? 'Notifikasi Aktif' : 'Notifikasi Mati',
                              _alarmsActive ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 10),
                            _chip(
                              _alarmsActive ? 'Alarm Aktif' : 'Alarm Mati',
                              _alarmsActive ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ── LIST REMINDERS ───────────────────────────────────
                if (groups.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada jadwal hari ini',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Text(
                          'Semua Alarm Hari ini (${groups.fold<int>(0, (sum, g) => sum + g.reminders.length)} obat)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ...groups.map((g) => _buildReminderGroup(g)),
                      ],
                    ),
                  ),

                // ── TOMBOL TEST NOTIFIKASI & ALARM (dev helper) ─────────────
                if (groups.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2BB673)),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _testNotifikasi(groups),
                          icon: const Icon(Icons.notifications_active,
                              color: Color(0xFF2BB673)),
                          label: const Text(
                            '🔔 Test Notifikasi (5 detik)',
                            style: TextStyle(color: Color(0xFF2BB673)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _testAlarmSatuMenit(groups),
                          icon: const Icon(Icons.alarm,
                              color: Color(0xFFF59E0B)),
                          label: const Text(
                            '⏰ Test Alarm Nyata (1 menit)',
                            style: TextStyle(color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── TOMBOL TOGGLE ALARM ──────────────────────────────
                if (groups.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alarmsActive
                            ? Colors.black
                            : const Color(0xFF2BB673),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _toggleAlarms,
                      icon: Icon(
                        _alarmsActive
                            ? Icons.notifications_off
                            : Icons.notifications_active,
                        color: Colors.white,
                      ),
                      label: Text(
                        _alarmsActive
                            ? 'Matikan Semua Alarm'
                            : 'Aktifkan Kembali Alarm',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReminderGroup(ReminderGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              group.time,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
          ),
          ...group.reminders.map((reminder) => _alarmItem(
                reminder.time,
                reminder.namaObat,
                '${reminder.jumlahDosis} ${reminder.satuan}',
                _getCategoryColor(reminder.kategoriObat),
              )),
        ],
      ),
    );
  }

  Widget _chip(String text, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: borderColor, fontSize: 12),
      ),
    );
  }

  Widget _alarmItem(String time, String title, String dosage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(dosage,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule, color: color, size: 18),
          ),
        ],
      ),
    );
  }
}
