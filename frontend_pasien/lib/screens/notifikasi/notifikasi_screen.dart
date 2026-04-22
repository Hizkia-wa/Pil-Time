import 'package:flutter/material.dart';

enum NotificationType { mendatang, terlewat, rutinitas }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
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
  late TabController _tabController;

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: 'paracetamol',
      title: 'Obat Paracetamol (Sesudah Makan)',
      description: 'Segera diminum untuk meredakan gejala demam Anda.',
      time: '08:00',
      type: NotificationType.mendatang,
    ),
    NotificationItem(
      id: 'amlodipine',
      title: 'Obat Darah Tinggi (Amlodipine)',
      description:
          'Penting untuk menjaga tekanan darah tetap stabil setiap hari.',
      time: '06:00',
      type: NotificationType.terlewat,
    ),
    NotificationItem(
      id: 'jalan_pagi',
      title: 'Jalan Pagi 15 Menit',
      description: 'Udara pagi sangat baik untuk kesehatan paru-paru Anda.',
      time: '07:00',
      type: NotificationType.rutinitas,
    ),
    NotificationItem(
      id: 'vitamin_c',
      title: 'Suplemen Vitamin C',
      description: 'Menjaga daya tahan tubuh tetap prima.',
      time: '12:00',
      type: NotificationType.mendatang,
    ),
  ];

  List<NotificationItem> get _alarmList => _allNotifications
      .where((n) =>
          n.type == NotificationType.mendatang ||
          n.type == NotificationType.terlewat)
      .toList();

  List<NotificationItem> get _terlewatList => _allNotifications
      .where((n) => n.type == NotificationType.terlewat)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Build //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_allNotifications),
          _buildList(_alarmList),
          _buildList(_terlewatList),
        ],
      ),
    );
  }

  // AppBar //

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Color(0xFF1A1A2E), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Notifikasi',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF4CAF50),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: const Color(0xFF4CAF50),
            unselectedLabelColor: const Color(0xFF999999),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Alarm'),
              Tab(text: 'Terlewat'),
            ],
          ),
        ),
      ),
    );
  }

  // List //

  Widget _buildList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (_, index) => _buildCard(items[index]),
    );
  }

  // Card //

  Widget _buildCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(item),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCardIcon(item),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 14),
                _buildCardActions(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(NotificationItem item) {
    late Color color;
    late String label;

    switch (item.type) {
      case NotificationType.mendatang:
        color = const Color(0xFF4CAF50);
        label = 'MENDATANG • ${item.time}';
        break;
      case NotificationType.terlewat:
        color = const Color(0xFFFF6B6B);
        label = 'TERLEWAT • ${item.time}';
        break;
      case NotificationType.rutinitas:
        color = const Color(0xFF4A90D9);
        label = 'RUTINITAS • ${item.time}';
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardIcon(NotificationItem item) {
    if (item.type == NotificationType.terlewat) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF6B6B)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.error_outline,
            color: Color(0xFFFF6B6B), size: 20),
      );
    } else if (item.type == NotificationType.rutinitas) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.directions_walk,
            color: Color(0xFF4A90D9), size: 20),
      );
    } else if (item.id == 'vitamin_c') {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.link, color: Color(0xFF4CAF50), size: 20),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardActions(NotificationItem item) {
    switch (item.type) {
      case NotificationType.mendatang:
        if (item.id == 'vitamin_c') return const SizedBox.shrink();
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                label: const Text('Siap!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.access_time,
                    size: 16, color: Color(0xFF666666)),
                label: const Text('Tunda 15m',
                    style: TextStyle(
                        color: Color(0xFF666666), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );

      case NotificationType.terlewat:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_note,
                    size: 16, color: Colors.white),
                label: const Text('Catat Alasan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Minum Sekarang',
                    style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ),
          ],
        );

      case NotificationType.rutinitas:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check, size: 16, color: Colors.white),
            label: const Text('Selesai',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90D9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
          ),
        );
    }
  }
}