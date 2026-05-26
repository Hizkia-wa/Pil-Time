import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../bloc/notifikasi/notifikasi_bloc.dart';
import '../../bloc/notifikasi/notifikasi_event.dart';
import '../../bloc/notifikasi/notifikasi_state.dart';

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

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotifikasiBloc _notifikasiBloc;
  int? _pasienId;

  @override
  void initState() {
    super.initState();
    _notifikasiBloc = NotifikasiBloc();
    _loadSessionAndFetch();
  }

  Future<void> _loadSessionAndFetch() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null) {
        _pasienId = session['pasien_id'] as int;
        _notifikasiBloc.add(FetchNotifications(pasienId: _pasienId!));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notifikasiBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<NotifikasiBloc, NotifikasiState>(
        bloc: _notifikasiBloc,
        listener: (context, state) {
          if (state is NotifikasiActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ ${state.message}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotifikasiActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotifikasiInitial || state is NotifikasiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotifikasiFailure) {
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
                    state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_pasienId != null) {
                        _notifikasiBloc.add(FetchNotifications(pasienId: _pasienId!));
                      } else {
                        _loadSessionAndFetch();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is NotifikasiLoaded) {
            final visibleNotifications = state.allNotifications.where((n) {
              return !state.deferredNotifications.contains(n);
            }).toList();

            if (visibleNotifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off, size: 48, color: Colors.grey),
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleNotifications.length,
              itemBuilder: (_, i) => buildCard(visibleNotifications[i]),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildCard(NotificationItem item) {
    Color color;
    String label;

    switch (item.type) {
      case NotificationType.mendatang:
        color = const Color(0xFF22C55E);
        label = "MENDATANG • ${item.time}";
        break;
      case NotificationType.terlewat:
        color = const Color(0xFFEF4444);
        label = "TERLEWAT • ${item.time}";
        break;
      case NotificationType.rutinitas:
        color = const Color(0xFF3B82F6);
        label = "RUTINITAS • ${item.time}";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              padding: const EdgeInsets.all(16),
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

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // ICON
                      Container(
                        padding: const EdgeInsets.all(6),
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

                  const SizedBox(height: 6),

                  Text(
                    item.desc,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),

                  const SizedBox(height: 12),

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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 18),
              const SizedBox(width: 8),
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
              icon: const Icon(Icons.check, size: 16),
              label: const Text("Siap!"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _deferNotification(item),
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text("Tunda 15m"),
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
              icon: const Icon(Icons.edit),
              label: const Text("Catat Alasan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
              child: const Text("Minum Sekarang"),
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
        icon: const Icon(Icons.check),
        label: const Text("Selesai"),
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
  void _markAsTaken(NotificationItem item) {
    if (_pasienId != null) {
      _notifikasiBloc.add(MarkNotificationAsTaken(item: item, pasienId: _pasienId!));
    }
  }

  // Fungsi untuk menunda notifikasi 15 menit
  void _deferNotification(NotificationItem item) {
    _notifikasiBloc.add(DeferNotificationEvent(item: item));
  }

  // Fungsi untuk menampilkan dialog catat alasan
  void _showReasonDialog(NotificationItem item) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Alasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obat: ${item.title}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_pasienId != null) {
                _notifikasiBloc.add(SubmitMissedReasonEvent(
                  item: item,
                  reason: reasonController.text,
                  pasienId: _pasienId!,
                ));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
