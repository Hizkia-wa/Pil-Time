import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../bloc/notifikasi/notifikasi_bloc.dart';
import '../../bloc/notifikasi/notifikasi_event.dart';
import '../../bloc/notifikasi/notifikasi_state.dart';
import '../../utils/dialog_helper.dart';

enum NotificationType { mendatang, terlewat, rutinitas }

class NotificationItem {
  final String title;
  final String desc;
  final String time;
  final NotificationType type;
  final int? jadwalId;
  final String? aturan;
  final bool isAdvanceReminder; // true jika notifikasi 15 menit sebelumnya
  final String? id; // Nullable untuk FCM/saved ones
  bool isRead;

  NotificationItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.type,
    this.jadwalId,
    this.aturan,
    this.isAdvanceReminder = false,
    this.id,
    this.isRead = false,
  });

  String get uniqueKey {
    if (id != null) return 'fcm_$id';
    if (isAdvanceReminder) {
      try {
        final parts = time.split(':');
        if (parts.length == 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          minute -= 15;
          if (minute < 0) {
            minute += 60;
            hour -= 1;
            if (hour < 0) hour = 23;
          }
          final advanceTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          return 'dynamic_${jadwalId}_$advanceTime';
        }
      } catch (_) {}
    }
    return 'dynamic_${jadwalId}_$time';
  }

  bool get canDelete {
    if (type != NotificationType.terlewat) return true;
    // Notif terlewat bisa dihapus setelah 12 jam dari waktu jadwal
    try {
      final now = DateTime.now();
      final parts = time.split(':');
      if (parts.length < 2) return true;
      final jadwalDt = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      return now.difference(jadwalDt).inHours >= 12;
    } catch (_) {
      return true;
    }
  }
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
    _notifikasiBloc = context.read<NotifikasiBloc>();
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
    super.dispose();
  }

  void _showNotificationDetail(NotificationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // BlocProvider.value diperlukan agar BLoC bisa diakses dari dalam modal
      // karena showModalBottomSheet membuat route baru yang tidak mewarisi context
      builder: (_) {
        return BlocProvider.value(
          value: _notifikasiBloc,
          child: NotificationDetailWidget(item: item),
        );
      },
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
                  textAlign: TextAlign.center,
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
            (listContext, index) => buildCard(listContext, visibleNotifications[index]),
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
    return BlocBuilder<NotifikasiBloc, NotifikasiState>(
      bloc: _notifikasiBloc,
      builder: (context, state) {
        final unreadCount = state is NotifikasiLoaded
            ? state.allNotifications.where((n) => !n.isRead).length
            : 0;

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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Notifikasi",
                  style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$unreadCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

          ),
          body: BlocConsumer<NotifikasiBloc, NotifikasiState>(
            bloc: _notifikasiBloc,
            listener: (context, state) {
              if (state is NotifikasiActionSuccess) {
                DialogHelper.showSuccessDialog(
                  context: context,
                  title: 'Berhasil',
                  message: state.message,
                );
              } else if (state is NotifikasiActionFailure) {
                DialogHelper.showErrorDialog(
                  context: context,
                  title: 'Gagal',
                  message: state.error,
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverContent(state),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget buildCard(BuildContext listContext, NotificationItem item) {
    Color color;
    String label;

    switch (item.type) {
      case NotificationType.mendatang:
        color = const Color(0xFF22C55E);
        label = item.id != null ? "INFORMASI • ${item.time}" : "MENDATANG • ${item.time}";
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

    return GestureDetector(
        onTap: () => _showNotificationDetail(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                      // LABEL ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "BARU",
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }


}

class NotificationDetailWidget extends StatefulWidget {
  final NotificationItem item;

  const NotificationDetailWidget({
    super.key,
    required this.item,
  });

  @override
  State<NotificationDetailWidget> createState() => _NotificationDetailWidgetState();
}

class _NotificationDetailWidgetState extends State<NotificationDetailWidget> {
  late final NotifikasiBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<NotifikasiBloc>();
    // Memicu optimistic update markAsRead sesaat setelah frame pertama dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_bloc.isClosed) {
        _bloc.add(MarkNotificationAsRead(item: widget.item));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor;
    final IconData headerIcon;
    switch (widget.item.type) {
      case NotificationType.mendatang:
        themeColor = const Color(0xFF15BE77);
        headerIcon = Icons.notifications_active_rounded;
        break;
      case NotificationType.terlewat:
        themeColor = const Color(0xFFEF4444);
        headerIcon = Icons.error_outline_rounded;
        break;
      case NotificationType.rutinitas:
        themeColor = const Color(0xFF3B82F6);
        headerIcon = Icons.directions_walk_rounded;
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(headerIcon, color: themeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.type == NotificationType.mendatang
                          ? (widget.item.id != null ? 'INFORMASI BARU' : 'PENGINGAT AKTIF')
                          : widget.item.type == NotificationType.terlewat
                              ? 'JADWAL TERLEWAT'
                              : 'RUTINITAS SEHAT',
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Keterangan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Info Grid / Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.blueGrey, size: 18),
                      const SizedBox(height: 8),
                      const Text(
                        'Waktu Jadwal',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.time,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.item.aturan != null && widget.item.aturan!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded, color: Colors.blueGrey, size: 18),
                        const SizedBox(height: 8),
                        const Text(
                          'Aturan Konsumsi',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.aturan!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),

          // Action Buttons
          Row(
            children: [
              if (widget.item.canDelete) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final title = widget.item.title;
                      _bloc.add(DeleteNotification(item: widget.item));
                      Navigator.pop(context);
                      DialogHelper.showSuccessDialog(
                        context: context,
                        title: 'Dihapus',
                        message: 'Notifikasi "$title" berhasil dihapus',
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      DialogHelper.showErrorDialog(
                        context: context,
                        title: 'Terkunci',
                        message: 'Notifikasi ini baru bisa dihapus 12 jam setelah jadwal terlewat',
                      );
                    },
                    icon: const Icon(Icons.lock_clock_rounded, color: Color(0xFF94A3B8), size: 20),
                    label: const Text(
                      'Terkunci',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
      ),
    );
  }
}
