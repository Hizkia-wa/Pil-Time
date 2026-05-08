import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

enum NotificationType { mendatang, terlewat, rutinitas }

class NotificationItem {
  final String title;
  final String desc;
  final String time;
  final NotificationType type;
  final int? jadwalId;
  final String? aturan;
  final bool isAdvanceReminder; // true jika notifikasi 15 menit sebelumnya

  NotificationItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.type,
    this.jadwalId,
    this.aturan,
    this.isAdvanceReminder = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  int? _pasienId;
  List<NotificationItem> _allNotifications = [];
  bool _isLoading = true;
  String? _errorMsg;
  late TabController _tabController;
  Set<int> _deferredNotifications = {}; // Track deferred notifications by index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session == null) {
        setState(() {
          _errorMsg = 'User session tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final pasienId = session['pasien_id'] as int;
      setState(() => _pasienId = pasienId);

      await _fetchNotifications(pasienId);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
      setState(() {
        _errorMsg = 'Gagal memuat notifikasi: $e';
        _isLoading = false;
      });
    }
  }

  /// Cek apakah waktu jadwal (format "HH:MM") sudah lewat >75 menit.
  /// Konsisten dengan threshold di dashboard, alarm screen, dan backend.
  bool _isTimeExpired(String waktu) {
    try {
      final parts = waktu.split(':');
      if (parts.length < 2) return false;
      final now = DateTime.now();
      final jadwalDt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return now.difference(jadwalDt).inMinutes > 75;
    } catch (_) {
      return false;
    }
  }

  /// Cek apakah waktu jadwal (format "HH:MM") sudah tiba atau lewat saat ini.
  bool _hasTimeArrived(String waktu) {
    try {
      final parts = waktu.split(':');
      if (parts.length < 2) return false;
      final now = DateTime.now();
      final jadwalDt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      // Jika sekarang sudah sama atau melewati waktu jadwal, berarti sudah tiba
      return now.isAfter(jadwalDt) || now.isAtSameMomentAs(jadwalDt);
    } catch (_) {
      return false;
    }
  }


  Future<void> _fetchNotifications(int pasienId) async {
    try {
      // Fetch dashboard data (upcoming medications)
      final dashboardResponse = await ApiService.getDashboard(
        pasienId: pasienId,
      );

      // Fetch riwayat data (missed medications)
      final riwayatResponse = await ApiService.getRiwayat(pasienId: pasienId);

      if (!dashboardResponse['success']) {
        throw Exception(dashboardResponse['error']);
      }

      final notifications = <NotificationItem>[];

      // Ambil ID jadwal yang sudah diminum/terlambat hari ini agar tidak ditampilkan sebagai mendatang
      final takenTodayJadwalIds = <int>{};
      if (riwayatResponse['success']) {
        final riwayatData = riwayatResponse['data'] as List<dynamic>? ?? [];
        for (final tracking in riwayatData) {
          final status = tracking['status'] as String? ?? '';
          final tanggal = tracking['tanggal'] as String? ?? '';
          final jadwalId = tracking['jadwal_id'];

          final parsedJadwalId = int.tryParse(jadwalId.toString());
          if (parsedJadwalId != null &&
              (status == 'Diminum' || status == 'Terlambat')) {
            try {
              final trackingDate = DateTime.parse(tanggal);
              final today = DateTime.now();
              final isToday = trackingDate.year == today.year &&
                  trackingDate.month == today.month &&
                  trackingDate.day == today.day;

              if (isToday) {
                takenTodayJadwalIds.add(parsedJadwalId);
              }
            } catch (_) {}
          }
        }
      }

      // Process dashboard data for upcoming medications
      final dashboardData = dashboardResponse['data'] as Map<String, dynamic>?;
      if (dashboardData != null && dashboardData['today_jadwals'] != null) {
        final todayJadwals =
            dashboardData['today_jadwals'] as List<dynamic>? ?? [];

        for (final jadwal in todayJadwals) {
          final namaObat = jadwal['nama_obat'] ?? 'Obat';
          final String waktuStr = (jadwal['waktu_minum'] ?? jadwal['jam'] ?? '00:00').toString();
          final aturan = jadwal['aturan'] ?? '';
          final jadwalId = jadwal['id'] ?? jadwal['jadwal_id'];

          final parsedJadwalId = int.tryParse(jadwalId.toString());

          // Pisahkan waktu jika comma-separated
          final List<String> times = waktuStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          for (final waktu in times) {
            // Lewati jadwal yang sudah >75 menit (sudah Terlewat)
            if (_isTimeExpired(waktu)) continue;

            // Lewati jika obat sudah diminum hari ini
            if (parsedJadwalId != null &&
                takenTodayJadwalIds.contains(parsedJadwalId)) {
              continue;
            }

            // Notifikasi pada jam jadwal (hanya jika sudah tiba)
            if (_hasTimeArrived(waktu)) {
              notifications.add(
                NotificationItem(
                  title: namaObat,
                  desc: aturan.isNotEmpty
                      ? 'Segera diminum sesuai aturan: $aturan'
                      : 'Segera diminum untuk kesehatan Anda.',
                  time: waktu,
                  type: NotificationType.mendatang,
                  jadwalId: parsedJadwalId,
                  aturan: aturan,
                  isAdvanceReminder: false,
                ),
              );
            }

            // Notifikasi 15 menit sebelum (hanya tampil jika belum expired dan sudah tiba)
            try {
              final timeParts = waktu.split(':');
              if (timeParts.length == 2) {
                int hour = int.parse(timeParts[0]);
                int minute = int.parse(timeParts[1]);

                // Kurangi 15 menit
                minute -= 15;
                if (minute < 0) {
                  minute += 60;
                  hour -= 1;
                  if (hour < 0) hour = 23;
                }

                final advanceTime =
                    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                // Tampilkan reminder 15 menit sebelum hanya jika belum expired dan sudah tiba
                if (!_isTimeExpired(advanceTime) &&
                    _hasTimeArrived(advanceTime)) {
                  notifications.add(
                    NotificationItem(
                      title: namaObat,
                      desc: 'Siapkan obat ini. Waktu minum: $waktu',
                      time: advanceTime,
                      type: NotificationType.mendatang,
                      jadwalId: parsedJadwalId,
                      aturan: aturan,
                      isAdvanceReminder: true,
                    ),
                  );
                }
              }
            } catch (_) {}
          }
        }
      }

      // Process riwayat data for missed medications
      if (riwayatResponse['success']) {
        final riwayatData = riwayatResponse['data'] as List<dynamic>? ?? [];

        for (final tracking in riwayatData) {
          final status = tracking['status'] as String? ?? '';
          final namaObat = tracking['nama_obat'] ?? 'Obat';
          final waktu =
              tracking['waktu_minum'] ?? tracking['jadwal'] ?? '00:00';
          final tanggal = tracking['tanggal'] as String? ?? '';
          final jadwalId = tracking['jadwal_id'];

          final parsedJadwalId = int.tryParse(jadwalId.toString());

          // Check if it's today and terlewat
          if (status == 'Terlewat' || status == 'Terlambat') {
            final today = DateTime.now();
            try {
              final trackingDate = DateTime.parse(tanggal);
              final isToday = trackingDate.year == today.year &&
                  trackingDate.month == today.month &&
                  trackingDate.day == today.day;

              if (isToday && status == 'Terlewat') {
                notifications.add(
                  NotificationItem(
                    title: namaObat,
                    desc:
                        'Anda melewatkan dosis ini. Catat alasan atau minum sekarang jika masih diperlukan.',
                    time: waktu,
                    type: NotificationType.terlewat,
                    jadwalId: parsedJadwalId,
                    isAdvanceReminder: false,
                  ),
                );
              }
            } catch (_) {}
          }
        }
      }

      // Urutkan notifikasi secara kronologis descending (waktu terbaru paling atas)
      notifications.sort((a, b) => b.time.compareTo(a.time));

      setState(() {
        _allNotifications = notifications;
        _isLoading = false;
        _errorMsg = null;
      });
    } catch (e) {
      debugPrint("Exception in _fetchNotifications: $e");
      setState(() {
        _errorMsg = 'Gagal memuat notifikasi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "Notifikasi",
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Alarm"),
            ],
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_allNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Semua jadwal Anda berjalan dengan baik',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Tab Semua
        _buildNotificationList(_getVisibleNotifications(_allNotifications)),
        // Tab Alarm
        _buildNotificationList(
          _getVisibleNotifications(
            _allNotifications
                .where((n) => n.type == NotificationType.mendatang)
                .toList(),
          ),
        ),
      ],
    );
  }

  // Filter notifikasi yang tidak tertunda
  List<NotificationItem> _getVisibleNotifications(
    List<NotificationItem> notifications,
  ) {
    return notifications.where((n) {
      final idx = _allNotifications.indexOf(n);
      return !_deferredNotifications.contains(idx);
    }).toList();
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada notifikasi untuk kategori ini',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (_, i) => buildCard(notifications[i]),
    );
  }

  Widget buildCard(NotificationItem item) {
    Color color;
    String label;

    switch (item.type) {
      case NotificationType.mendatang:
        color = Color(0xFF22C55E);
        label = "MENDATANG • ${item.time}";
        break;
      case NotificationType.terlewat:
        color = Color(0xFFEF4444);
        label = "TERLEWAT • ${item.time}";
        break;
      case NotificationType.rutinitas:
        color = Color(0xFF3B82F6);
        label = "RUTINITAS • ${item.time}";
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // GARIS KIRI
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LABEL
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // ICON
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.type == NotificationType.rutinitas
                              ? Icons.directions_walk
                              : item.type == NotificationType.terlewat
                              ? Icons.error_outline
                              : Icons.notifications,
                          color: color,
                          size: 18,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),

                  Text(
                    item.desc,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),

                  SizedBox(height: 12),

                  buildButton(item, color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(NotificationItem item, Color color) {
    if (item.type == NotificationType.mendatang) {
      // Untuk advance reminder (15 menit sebelum), hanya tampilkan reminder
      if (item.isAdvanceReminder) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bersiaplah untuk minum obat ini',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }

      // Notifikasi jadwal normal
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsTaken(item),
              icon: Icon(Icons.check, size: 16),
              label: Text("Siap!"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _deferNotification(item),
              icon: Icon(Icons.access_time, size: 16),
              label: Text("Tunda 15m"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (item.type == NotificationType.terlewat) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showReasonDialog(item),
              icon: Icon(Icons.edit),
              label: Text("Catat Alasan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markAsTaken(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Minum Sekarang"),
            ),
          ),
        ],
      );
    }

    // rutinitas
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.check),
        label: Text("Selesai"),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menandai obat sudah diminum
  Future<void> _markAsTaken(NotificationItem item) async {
    if (item.jadwalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ID jadwal tidak ditemukan')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final waktuMinum =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final response = await ApiService.postRiwayat(
        jadwalId: item.jadwalId!,
        status: 'Diminum',
        waktuMinum: waktuMinum,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Obat berhasil dicatat'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh notifikasi
        await Future.delayed(Duration(milliseconds: 500));
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response['error']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fungsi untuk menunda notifikasi 15 menit
  void _deferNotification(NotificationItem item) {
    final index = _allNotifications.indexOf(item);
    if (index != -1) {
      setState(() {
        _deferredNotifications.add(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi ditunda 15 menit'),
          duration: Duration(seconds: 2),
        ),
      );

      // Auto-undur setelah 15 menit
      Future.delayed(Duration(minutes: 15), () {
        setState(() {
          _deferredNotifications.remove(index);
        });
      });
    }
  }

  // Fungsi untuk menampilkan dialog catat alasan
  void _showReasonDialog(NotificationItem item) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Catat Alasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obat: ${item.title}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Jelaskan alasan Anda melewatkan obat ini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitMissedReason(item, reasonController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menyimpan alasan terlewat
  Future<void> _submitMissedReason(NotificationItem item, String reason) async {
    if (item.jadwalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ID jadwal tidak ditemukan')),
      );
      return;
    }

    try {
      final response = await ApiService.postRiwayat(
        jadwalId: item.jadwalId!,
        status: 'Terlewat',
        waktuMinum: item.time,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Alasan telah dicatat'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh notifikasi
        await Future.delayed(Duration(milliseconds: 500));
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response['error']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
