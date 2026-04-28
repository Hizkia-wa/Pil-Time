import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

enum NotificationType { mendatang, terlewat, rutinitas }

class NotificationItem {
  final String title;
  final String desc;
  final String time;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.type,
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

      // Process dashboard data for upcoming medications
      final dashboardData = dashboardResponse['data'] as Map<String, dynamic>?;
      if (dashboardData != null && dashboardData['today_jadwals'] != null) {
        final todayJadwals =
            dashboardData['today_jadwals'] as List<dynamic>? ?? [];

        for (final jadwal in todayJadwals) {
          final namaObat = jadwal['nama_obat'] ?? 'Obat';
          final waktu = jadwal['waktu_minum'] ?? jadwal['jam'] ?? '00:00';
          final aturan = jadwal['aturan'] ?? '';

          notifications.add(
            NotificationItem(
              title: namaObat,
              desc: aturan.isNotEmpty
                  ? 'Segera diminum sesuai aturan: $aturan'
                  : 'Segera diminum untuk kesehatan Anda.',
              time: waktu,
              type: NotificationType.mendatang,
            ),
          );
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

          // Check if it's today and terlewat
          if (status == 'Terlewat' || status == 'Terlambat') {
            final today = DateTime.now();
            try {
              final trackingDate = DateTime.parse(tanggal);
              final isToday =
                  trackingDate.year == today.year &&
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
                  ),
                );
              }
            } catch (_) {}
          }
        }
      }

      // TODO: Add routine notifications when routine API is implemented
      // For now, we'll add a sample if needed

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
        _buildNotificationList(_allNotifications),
        // Tab Alarm
        _buildNotificationList(
          _allNotifications
              .where((n) => n.type == NotificationType.mendatang)
              .toList(),
        ),
      ],
    );
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
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
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
              onPressed: () {},
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
              onPressed: () {},
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
              onPressed: () {},
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
}
