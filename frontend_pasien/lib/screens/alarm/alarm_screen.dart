import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _remindersFuture = _fetchReminders();
  }

  Future<List<ReminderGroup>> _fetchReminders() async {
    try {
      final response = await ApiService.getDashboard(pasienId: widget.pasienId);
      if (!response['success']) {
        throw Exception(response['error'] ?? 'Gagal mengambil data jadwal');
      }

      final dashboard = Dashboard.fromJson(response['data']);
      final reminders = _extractReminders(dashboard.todayJadwals);
      return reminders;
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      rethrow;
    }
  }

  List<ReminderGroup> _extractReminders(List<Jadwal> jadwals) {
    final Map<String, List<Reminder>> reminderMap = {};

    for (var jadwal in jadwals) {
      if (jadwal.status.toLowerCase() != 'aktif') continue;

      // Main time - waktuMinum
      if (jadwal.waktuMinum.isNotEmpty) {
        _addReminderToMap(reminderMap, jadwal.waktuMinum, jadwal);
      }

      // Optional reminder times
      if (jadwal.waktuReminderPagi.isNotEmpty && jadwal.waktuReminderPagi != jadwal.waktuMinum) {
        _addReminderToMap(reminderMap, jadwal.waktuReminderPagi, jadwal);
      }
      if (jadwal.waktuReminderMalam.isNotEmpty && jadwal.waktuReminderMalam != jadwal.waktuMinum) {
        _addReminderToMap(reminderMap, jadwal.waktuReminderMalam, jadwal);
      }
    }

    // Sort by time and convert to ReminderGroups
    final sortedTimes = reminderMap.keys.toList()..sort();
    return sortedTimes
        .map((time) => ReminderGroup(
              time: time,
              reminders: reminderMap[time] ?? [],
            ))
        .toList();
  }

  void _addReminderToMap(Map<String, List<Reminder>> map, String time, Jadwal jadwal) {
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
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Find next reminder time >= current time
    for (var group in groups) {
      if (group.time.compareTo(currentTime) >= 0) {
        return group.time;
      }
    }

    // If no upcoming, show first (next day)
    return groups.isNotEmpty ? groups.first.time : '--:--';
  }

  String _getNextReminderMedicine(List<ReminderGroup> groups) {
    if (groups.isEmpty) return 'Tidak ada jadwal';
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Find next reminder
    for (var group in groups) {
      if (group.time.compareTo(currentTime) >= 0) {
        return group.reminders.isNotEmpty
            ? group.reminders.first.fullInfo
            : 'Obat terjadwal';
      }
    }

    // If no upcoming, show first (next day)
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
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Gagal mengambil data jadwal'),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _remindersFuture = _fetchReminders()),
                      icon: Icon(Icons.refresh),
                      label: Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2BB673),
                      ),
                    ),
                  ],
                ),
              );
            }

            final groups = snapshot.data ?? [];

            return Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Reminder dan Alarm",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // CARD ALARM BERIKUTNYA
                if (groups.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF0B1F3A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alarm berikutnya",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _getNextReminderTime(groups),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getNextReminderMedicine(groups),
                          style: TextStyle(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            _chip("Notifikasi Aktif"),
                            SizedBox(width: 10),
                            _chip("Alarm Aktif"),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20),

                // LIST REMINDERS
                if (groups.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Tidak ada jadwal hari ini', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Text(
                          "Semua Alarm Hari ini (${groups.fold<int>(0, (sum, g) => sum + g.reminders.length)} obat)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        ...groups.asMap().entries.map((entry) {
                          return _buildReminderGroup(entry.value);
                        }),
                      ],
                    ),
                  ),

                // BUTTON
                if (groups.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement alarm off functionality - show dialog or disable reminders
                      },
                      child: Text("Matikan Alarm", style: TextStyle(fontSize: 16)),
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
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              group.time,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
          ...group.reminders.map((reminder) {
            return _alarmItem(
              reminder.time,
              reminder.namaObat,
              '${reminder.jumlahDosis} ${reminder.satuan}',
              _getCategoryColor(reminder.kategoriObat),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.greenAccent, fontSize: 12),
      ),
    );
  }

  Widget _alarmItem(String time, String title, String dosage, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: color),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(dosage, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(6),
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
