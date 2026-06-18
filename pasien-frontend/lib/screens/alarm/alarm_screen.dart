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
  final bool _alarmsActive = true; // Track status alarm global

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
      if (_alarmsActive) {
        _scheduleAlarmsBackground(dashboard.todayJadwals);
      }

      return reminders;
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      rethrow;
    }
  }

  /// Cek apakah waktu jadwal sudah lewat >75 menit (Terlewat).
  bool _isExpired(String waktuMinum) {
    try {
      final parts = waktuMinum.split(':');
      if (parts.length < 2) return false;
      final now = DateTime.now();
      final jadwalDt = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      return now.difference(jadwalDt).inMinutes > 75;
    } catch (_) {
      return false;
    }
  }

  /// Jalankan scheduling alarm di background — tidak memblokir UI.
  void _scheduleAlarmsBackground(List<Jadwal> jadwals) {
    Future(() async {
      try {
        final notifModels = jadwals
            .where((j) =>
                j.status.toLowerCase() == 'aktif' &&
                !_isExpired(j.waktuMinum))
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
        debugPrint('[AlarmScreen] Gagal jadwalkan alarm (non-fatal): $e');
      }
    });
  }

  List<ReminderGroup> _extractReminders(List<Jadwal> jadwals) {
    final Map<String, List<Reminder>> reminderMap = {};

    for (var jadwal in jadwals) {
      if (jadwal.status.toLowerCase() != 'aktif') continue;

      // Sembunyikan jadwal yang sudah >75 menit (Terlewat)
      if (_isExpired(jadwal.waktuMinum)) continue;

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
    final lower = category.toLowerCase();
    if (lower.contains('antibiotik')) return const Color(0xFF10B981); // Emerald
    if (lower.contains('pereda') || lower.contains('nyeri')) return const Color(0xFFF97316); // Orange
    if (lower.contains('suplemen') || lower.contains('vitamin')) return const Color(0xFF3B82F6); // Blue
    if (lower.contains('flu') || lower.contains('batuk')) return const Color(0xFF8B5CF6); // Purple
    if (lower.contains('darah') || lower.contains('tensi')) return const Color(0xFFEF4444); // Red
    return const Color(0xFF64748B); // Slate
  }

  Color _getCategoryBgColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('antibiotik')) return const Color(0xFFE8F8F1); // Soft Emerald
    if (lower.contains('pereda') || lower.contains('nyeri')) return const Color(0xFFFFF7ED); // Soft Orange
    if (lower.contains('suplemen') || lower.contains('vitamin')) return const Color(0xFFEFF6FF); // Soft Blue
    if (lower.contains('flu') || lower.contains('batuk')) return const Color(0xFFF5F3FF); // Soft Purple
    if (lower.contains('darah') || lower.contains('tensi')) return const Color(0xFFFEF2F2); // Soft Red
    return const Color(0xFFF1F5F9); // Soft Slate
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: SafeArea(
        child: FutureBuilder<List<ReminderGroup>>(
          future: _remindersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF15BE77),
                  strokeWidth: 3,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Color(0xFFFF4D4D),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal Memuat Data Jadwal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => setState(
                          () => _remindersFuture = _fetchAndScheduleReminders(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
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
                      ),
                    ],
                  ),
                ),
              );
            }

            final groups = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 24, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Reminder & Alarm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── CARD ALARM BERIKUTNYA ────────────────────────────
                if (groups.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.alarm_rounded,
                              color: Color(0xFF15BE77),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'ALARM BERIKUTNYA HARI INI',
                              style: TextStyle(
                                color: Color(0xFF15BE77),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getNextReminderTime(groups),
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getNextReminderMedicine(groups),
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _chip(
                              'Notifikasi Aktif',
                              const Color(0xFF15BE77),
                              const Color(0xFFE8F8F1),
                            ),
                            const SizedBox(width: 10),
                            _chip(
                              'Alarm Aktif',
                              const Color(0xFF15BE77),
                              const Color(0xFFE8F8F1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ── LIST REMINDERS ───────────────────────────────────
                if (groups.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F8F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 40,
                                color: Color(0xFF15BE77),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tidak ada jadwal obat hari ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Semua jadwal Anda telah tuntas atau kosong. Jaga kesehatan Anda selalu!',
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
                  )
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: const Text(
                                'Semua Alarm Hari Ini',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${groups.fold<int>(0, (sum, g) => sum + g.reminders.length)} Obat',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...groups.map((g) => _buildReminderGroup(g)),
                        const SizedBox(height: 24),
                      ],
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF15BE77),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Pukul ${group.time}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...group.reminders.map((reminder) => _alarmItem(
                reminder.time,
                reminder.namaObat,
                '${reminder.jumlahDosis} ${reminder.satuan}',
                reminder.kategoriObat,
              )),
        ],
      ),
    );
  }

  Widget _chip(String text, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _alarmItem(String time, String title, String dosage, String category) {
    final color = _getCategoryColor(category);
    final bgColor = _getCategoryBgColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      dosage,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_on_rounded,
              color: Color(0xFF15BE77),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

