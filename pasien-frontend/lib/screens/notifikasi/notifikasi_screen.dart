import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
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
  final NotificationItem? mockItem;

  const NotificationScreen({super.key, this.mockItem});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotifikasiBloc _notifikasiBloc;
  int? _pasienId;
  bool _isExplanationExpanded = false;

  @override
  void initState() {
    super.initState();
    _notifikasiBloc = NotifikasiBloc();
    _loadSessionAndFetch(mockItem: widget.mockItem);
  }

  Future<void> _loadSessionAndFetch({NotificationItem? mockItem}) async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null) {
        _pasienId = session['pasien_id'] as int;
        _notifikasiBloc.add(FetchNotifications(pasienId: _pasienId!));

        // Jika ada mock item (dari tap notifikasi sistem), sisipkan setelah
        // fetch selesai agar tampil di daftar
        if (mockItem != null) {
          await Future.delayed(const Duration(milliseconds: 1200));
          if (!_notifikasiBloc.isClosed) {
            _notifikasiBloc.add(AddMockNotification(item: mockItem));
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notifikasiBloc.close();
    super.dispose();
  }

  Future<void> _triggerTestReminder() async {
    try {
      await NotificationService.instance.scheduleTestReminderNotification(
        namaObat: 'Paracetamol (Uji Coba)',
        delaySeconds: 3,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🔔 Menjadwalkan pengingat biasa dalam 3 detik! Bunyi chime pendek dan akan otomatis masuk ke daftar bawah.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF15BE77),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menjadwalkan tes: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _triggerTestAlarm() async {
    try {
      await NotificationService.instance.scheduleTestNotification(
        namaObat: 'Paracetamol (Alarm)',
        delaySeconds: 3,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🔊 Alarm dijadwalkan dalam 3 detik! Layar alarm akan MUNCUL OTOMATIS — tanpa perlu tap notifikasi.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menjadwalkan alarm kustom: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildTestPanel() {
    const emerald = Color(0xFF15BE77);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15BE77), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: emerald.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'SISTEM UJI COBA NOTIFIKASI & ALARM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Uji Alur Notifikasi Pil-Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Verifikasi alur berdering kustom dan masuknya notifikasi ke halaman rekam medis Anda secara interaktif.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          
          // BUTTON 1: Notif Pengingat Biasa (15 Menit Sebelum)
          ElevatedButton.icon(
            onPressed: _triggerTestReminder,
            icon: const Icon(Icons.notifications_active_rounded, size: 18),
            label: const Text(
              '1. Tes Notif Biasa (15m Sebelum)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D9488),
              elevation: 0,
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '• Mengeluarkan bunyi ping biasa (chime sistem) & otomatis masuk ke daftar notifikasi di bawah agar terlihat oleh pengguna.',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Inter'),
            ),
          ),

          // BUTTON 2: Alarm Berdering (Waktu Minum Obat)
          ElevatedButton.icon(
            onPressed: _triggerTestAlarm,
            icon: const Icon(Icons.volume_up_rounded, size: 18),
            label: const Text(
              '2. Tes Alarm Berdering (Waktu Minum)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white30,
              foregroundColor: Colors.white,
              elevation: 0,
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.white30, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '• Mengeluarkan suara alarm kustom (alarm_voice) tiada henti dan memicu Alarm Ringing Screen persis saat jadwal minum obat.',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Inter'),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() {
                _isExplanationExpanded = !_isExplanationExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Kenapa notifikasi asli/riil harus dipisah?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Icon(
                    _isExplanationExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Sesuai prosedur kesehatan:\n1. Pengingat 15 menit sebelum menggunakan bunyi chime biasa agar ramah bagi pengguna dan otomatis diarsipkan ke halaman ini untuk rekam medis.\n2. Alarm waktu minum obat berbunyi tiada henti dengan suara manusia (alarm_voice) untuk memastikan Anda tidak terlewat, dan didesain murni sebagai alarm interaktif penentu aksi minum obat saat itu juga.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            crossFadeState: _isExplanationExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverContent(NotifikasiState state) {
    if (state is NotifikasiInitial || state is NotifikasiLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF15BE77),
          ),
        ),
      );
    }

    if (state is NotifikasiFailure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15BE77),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is NotifikasiLoaded) {
      final visibleNotifications = state.allNotifications.where((n) {
        return !state.deferredNotifications.contains(n);
      }).toList();

      if (visibleNotifications.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ada notifikasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Semua jadwal Anda berjalan dengan baik',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildCard(visibleNotifications[index]),
            childCount: visibleNotifications.length,
          ),
        ),
      );
    }

    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF15BE77),
        ),
      ),
    );
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
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is NotifikasiActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildTestPanel(),
              ),
              _buildSliverContent(state),
            ],
          );
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
