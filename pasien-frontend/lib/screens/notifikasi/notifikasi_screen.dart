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

  // ── Tes notifikasi pengingat biasa (15 menit sebelum) ─────
  Future<void> _triggerTestReminder() async {
    try {
      await NotificationService.instance.scheduleTestReminderNotification(
        namaObat: 'Paracetamol (Uji Coba)',
        delaySeconds: 3,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🔔 Notif pengingat muncul dalam 3 detik. Tap notifikasi untuk masuk ke halaman ini.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15BE77),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── Tes alarm berdering (suara alarm_voice, auto buka layar) ─
  Future<void> _triggerTestAlarm() async {
    try {
      await NotificationService.instance.scheduleTestNotification(
        namaObat: 'Paracetamol (Alarm)',
        delaySeconds: 3,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.alarm_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🔊 Alarm berbunyi dalam 3 detik. Layar alarm OTOMATIS muncul setelah bunyi 2×.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── Panel uji coba notifikasi & alarm ─────────────────────
  Widget _buildTestPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15BE77).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    color: Color(0xFF15BE77),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UJI COBA SISTEM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15BE77),
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      'Notifikasi & Alarm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),

            // Button 1 – Notif Pengingat
            _TestButton(
              icon: Icons.notifications_active_rounded,
              label: 'Tes Notifikasi Pengingat',
              sublabel: 'Bunyi chime pendek • Tap notif → masuk halaman ini',
              color: const Color(0xFF15BE77),
              onTap: _triggerTestReminder,
            ),
            const SizedBox(height: 12),

            // Button 2 – Alarm Berdering
            _TestButton(
              icon: Icons.alarm_rounded,
              label: 'Tes Alarm Berdering',
              sublabel: 'Suara alarm_voice 2× → layar alarm muncul otomatis',
              color: const Color(0xFF0D9488),
              onTap: _triggerTestAlarm,
            ),
          ],
        ),
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
              // Panel uji coba selalu tampil di atas
              SliverToBoxAdapter(child: _buildTestPanel()),
              _buildSliverContent(state),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
// HELPER WIDGET \u2014 Tombol uji coba dengan desain premium
// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
class _TestButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _TestButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends State<_TestButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) => _ctrl.forward();
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.sublabel,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.color.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

