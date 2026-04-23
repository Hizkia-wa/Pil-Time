import 'package:flutter/material.dart';

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

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final List<NotificationItem> data = [
    NotificationItem(
      title: "Obat Paracetamol (Sesudah Makan)",
      desc: "Segera diminum untuk meredakan gejala demam Anda.",
      time: "08:00",
      type: NotificationType.mendatang,
    ),
    NotificationItem(
      title: "Obat Darah Tinggi (Amlodipine)",
      desc: "Penting untuk menjaga tekanan darah tetap stabil setiap hari.",
      time: "06:00",
      type: NotificationType.terlewat,
    ),
    NotificationItem(
      title: "Jalan Pagi 15 Menit",
      desc: "Udara pagi sangat baik untuk kesehatan paru-paru Anda.",
      time: "07:00",
      type: NotificationType.rutinitas,
    ),
    NotificationItem(
      title: "Suplemen Vitamin C",
      desc: "Menjaga daya tahan tubuh tetap prima.",
      time: "12:00",
      type: NotificationType.mendatang,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Icon(Icons.arrow_back_ios, color: Colors.black),
          centerTitle: true,
          title: Text(
            "Notifikasi",
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Alarm"),
            ],
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) => buildCard(data[i]),
        ),
      ),
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
