import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../utils/error_handler.dart';import '../../services/notification_service.dart';
import '../../services/notification_storage_service.dart';
import '../../screens/notifikasi/notifikasi_screen.dart';
import 'notifikasi_event.dart';
import 'notifikasi_state.dart';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  // Cache in-memory untuk kunci yang baru dihapus.
  // Digunakan untuk memblokir notifikasi yang baru dihapus agar tidak muncul
  // kembali ketika FetchNotifications berjalan secara bersamaan (race condition).
  final Set<String> _pendingDeletedKeys = {};

  NotifikasiBloc() : super(NotifikasiInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsTaken>(_onMarkNotificationAsTaken);
    on<DeferNotificationEvent>(_onDeferNotification);
    on<UndeferNotificationEvent>(_onUndeferNotification);
    on<SubmitMissedReasonEvent>(_onSubmitMissedReason);
    on<AddMockNotification>(_onAddMockNotification);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

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
      return now.isAfter(jadwalDt) || now.isAtSameMomentAs(jadwalDt);
    } catch (_) {
      return false;
    }
  }

  bool _isSameNotification(NotificationItem a, NotificationItem b) {
    if (a.title != b.title) return false;
    if (a.type != b.type) return false;
    if (a.isAdvanceReminder != b.isAdvanceReminder) return false;

    if (a.jadwalId != null && b.jadwalId != null) {
      return a.jadwalId == b.jadwalId;
    }

    try {
      final partsA = a.time.split(':');
      final partsB = b.time.split(':');
      if (partsA.length >= 2 && partsB.length >= 2) {
        final minA = int.parse(partsA[0]) * 60 + int.parse(partsA[1]);
        final minB = int.parse(partsB[0]) * 60 + int.parse(partsB[1]);
        final diff = (minA - minB).abs();
        return diff <= 60;
      }
    } catch (_) {}

    return a.time == b.time;
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotifikasiState> emit,
  ) async {
    emit(NotifikasiLoading());
    try {
      final dashboardResponse = await ApiService.getDashboard(
        pasienId: event.pasienId,
      );
      final riwayatResponse = await ApiService.getRiwayat(pasienId: event.pasienId);

      if (!dashboardResponse['success']) {
        throw Exception(dashboardResponse['error'] ?? 'Gagal memuat data dashboard');
      }

      final notifications = <NotificationItem>[];
      final takenTodayJadwalIds = <int>{};
      
      // Ambil data kunci dibaca, FCM, dan terhapus dari SharedPreferences
      final readKeys = await NotificationStorageService.instance.getReadKeys();
      final deletedKeys = await NotificationStorageService.instance.getDeletedKeys();
      final fcmNotifs = await NotificationStorageService.instance.getSavedFcmNotifications();

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

      // Masukkan FCM push notifications tersimpan
      for (final fcmNotif in fcmNotifs) {
        final key = 'fcm_${fcmNotif.id}';
        // Filter berdasarkan storage (persistant) DAN cache in-memory (race condition guard)
        if (deletedKeys.contains(key) || _pendingDeletedKeys.contains(key)) continue;
        final isRead = readKeys.contains(key);
        
        NotificationType notifType = NotificationType.mendatang;
        if (fcmNotif.type == 'terlewat') {
          notifType = NotificationType.terlewat;
        } else if (fcmNotif.type == 'rutinitas') {
          notifType = NotificationType.rutinitas;
        }

        notifications.add(
          NotificationItem(
            id: fcmNotif.id,
            title: fcmNotif.title,
            desc: fcmNotif.desc,
            time: fcmNotif.time,
            type: notifType,
            jadwalId: fcmNotif.jadwalId,
            aturan: fcmNotif.aturan,
            isRead: isRead,
          ),
        );
      }

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

          final List<String> times = waktuStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          for (final waktu in times) {
            if (_isTimeExpired(waktu)) continue;

            if (parsedJadwalId != null &&
                takenTodayJadwalIds.contains(parsedJadwalId)) {
              continue;
            }

            if (_hasTimeArrived(waktu)) {
              final key = 'dynamic_${parsedJadwalId}_$waktu';
              if (!deletedKeys.contains(key)) {
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
                    isRead: readKeys.contains(key),
                  ),
                );
              }
            }

            try {
              final timeParts = waktu.split(':');
              if (timeParts.length == 2) {
                int hour = int.parse(timeParts[0]);
                int minute = int.parse(timeParts[1]);

                minute -= 15;
                if (minute < 0) {
                  minute += 60;
                  hour -= 1;
                  if (hour < 0) hour = 23;
                }

                final advanceTime =
                    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                if (!_isTimeExpired(advanceTime) &&
                    _hasTimeArrived(advanceTime)) {
                  final key = 'dynamic_${parsedJadwalId}_$advanceTime';
                  if (!deletedKeys.contains(key)) {
                    notifications.add(
                      NotificationItem(
                        title: namaObat,
                        desc: 'Siapkan obat ini. Waktu minum: $waktu',
                        time: waktu, // Tampilkan waktu jadwal sebenarnya, bukan advanceTime
                        type: NotificationType.mendatang,
                        jadwalId: parsedJadwalId,
                        aturan: aturan,
                        isAdvanceReminder: true,
                        isRead: readKeys.contains(key),
                      ),
                    );
                  }
                }
              }
            } catch (_) {}
          }
        }
      }

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

          if (status == 'Terlewat' || status == 'Terlambat') {
            final today = DateTime.now();
            try {
              final trackingDate = DateTime.parse(tanggal);
              final isToday = trackingDate.year == today.year &&
                  trackingDate.month == today.month &&
                  trackingDate.day == today.day;

              if (isToday && status == 'Terlewat') {
                final key = 'dynamic_${parsedJadwalId}_$waktu';
                if (!deletedKeys.contains(key)) {
                  notifications.add(
                    NotificationItem(
                      title: namaObat,
                      desc:
                          'Anda melewatkan dosis ini. Catat alasan atau minum sekarang jika masih diperlukan.',
                      time: waktu,
                      type: NotificationType.terlewat,
                      jadwalId: parsedJadwalId,
                      isAdvanceReminder: false,
                      isRead: readKeys.contains(key),
                    ),
                  );
                }
              }
            } catch (_) {}
          }
        }
      }

      // Deduplicate notifications
      final uniqueNotifications = <NotificationItem>[];
      for (final notif in notifications) {
        bool isDuplicate = false;
        for (final existing in uniqueNotifications) {
          if (_isSameNotification(notif, existing)) {
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          uniqueNotifications.add(notif);
        }
      }

      uniqueNotifications.sort((a, b) => b.time.compareTo(a.time));

      emit(NotifikasiLoaded(
        allNotifications: uniqueNotifications,
        deferredNotifications: const {},
      ));
    } catch (e) {
      emit(NotifikasiFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onMarkAsTaken(
    int pasienId,
    NotificationItem item,
    Emitter<NotifikasiState> emit,
  ) async {
    if (item.jadwalId == null) {
      emit(const NotifikasiActionFailure('ID jadwal tidak ditemukan'));
      return;
    }

    final currentState = state;
    List<NotificationItem> allNotifications = [];
    Set<NotificationItem> deferredNotifications = {};

    if (currentState is NotifikasiLoaded) {
      allNotifications = currentState.allNotifications;
      deferredNotifications = currentState.deferredNotifications;
    }

    emit(NotifikasiActionLoading());

    try {
      final now = DateTime.now();
      final waktuMinum =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Hitung compliance status agar diminum / terlambat akurat
      final complianceStatus = NotificationService.checkComplianceFromString(
        scheduledTimeStr: item.time,
        confirmationTime: now,
      );
      final status = complianceStatus.backendValue;

      final response = await ApiService.postRiwayat(
        jadwalId: item.jadwalId!,
        status: status,
        waktuMinum: waktuMinum,
      );

      if (response['success']) {
        emit(const NotifikasiActionSuccess('Obat berhasil dicatat'));
        
        // Memicu Fetch kembali untuk memperbarui list notifikasi secara sinkron
        final dashboardResponse = await ApiService.getDashboard(pasienId: pasienId);
        final riwayatResponse = await ApiService.getRiwayat(pasienId: pasienId);

        if (dashboardResponse['success']) {
          // Lakukan re-parsing internal untuk mengupdate status
          final updatedNotifications = <NotificationItem>[];
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

              final List<String> times = waktuStr
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              for (final waktu in times) {
                if (_isTimeExpired(waktu)) continue;

                if (parsedJadwalId != null &&
                    takenTodayJadwalIds.contains(parsedJadwalId)) {
                  continue;
                }

                if (_hasTimeArrived(waktu)) {
                  updatedNotifications.add(
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

                try {
                  final timeParts = waktu.split(':');
                  if (timeParts.length == 2) {
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);

                    minute -= 15;
                    if (minute < 0) {
                      minute += 60;
                      hour -= 1;
                      if (hour < 0) hour = 23;
                    }

                    final advanceTime =
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                    if (!_isTimeExpired(advanceTime) &&
                        _hasTimeArrived(advanceTime)) {
                      updatedNotifications.add(
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

              if (status == 'Terlewat' || status == 'Terlambat') {
                final today = DateTime.now();
                try {
                  final trackingDate = DateTime.parse(tanggal);
                  final isToday = trackingDate.year == today.year &&
                      trackingDate.month == today.month &&
                      trackingDate.day == today.day;

                  if (isToday && status == 'Terlewat') {
                    updatedNotifications.add(
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

          final uniqueUpdatedNotifications = <NotificationItem>[];
          for (final notif in updatedNotifications) {
            bool isDuplicate = false;
            for (final existing in uniqueUpdatedNotifications) {
              if (_isSameNotification(notif, existing)) {
                isDuplicate = true;
                break;
              }
            }
            if (!isDuplicate) {
              uniqueUpdatedNotifications.add(notif);
            }
          }

          uniqueUpdatedNotifications.sort((a, b) => b.time.compareTo(a.time));

          emit(NotifikasiLoaded(
            allNotifications: uniqueUpdatedNotifications,
            deferredNotifications: deferredNotifications,
          ));
        } else {
          emit(NotifikasiLoaded(
            allNotifications: allNotifications,
            deferredNotifications: deferredNotifications,
          ));
        }
      } else {
        emit(NotifikasiActionFailure(response['error'] ?? 'Gagal memproses pencatatan'));
        emit(NotifikasiLoaded(
          allNotifications: allNotifications,
          deferredNotifications: deferredNotifications,
        ));
      }
    } catch (e) {
      emit(NotifikasiActionFailure(ErrorHandler.getErrorMessage(e)));
      emit(NotifikasiLoaded(
        allNotifications: allNotifications,
        deferredNotifications: deferredNotifications,
      ));
    }
  }

  Future<void> _onMarkNotificationAsTaken(
    MarkNotificationAsTaken event,
    Emitter<NotifikasiState> emit,
  ) async {
    await _onMarkAsTaken(event.pasienId, event.item, emit);
  }

  Future<void> _onDeferNotification(
    DeferNotificationEvent event,
    Emitter<NotifikasiState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      final updatedDeferred = Set<NotificationItem>.from(currentState.deferredNotifications)
        ..add(event.item);
      
      emit(currentState.copyWith(deferredNotifications: updatedDeferred));

      // Otomatis batalkan tunda (undefer) setelah 15 menit
      Future.delayed(const Duration(minutes: 15), () {
        if (!isClosed) {
          add(UndeferNotificationEvent(item: event.item));
        }
      });
    }
  }

  Future<void> _onUndeferNotification(
    UndeferNotificationEvent event,
    Emitter<NotifikasiState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      final updatedDeferred = Set<NotificationItem>.from(currentState.deferredNotifications)
        ..remove(event.item);
      
      emit(currentState.copyWith(deferredNotifications: updatedDeferred));
    }
  }

  Future<void> _onSubmitMissedReason(
    SubmitMissedReasonEvent event,
    Emitter<NotifikasiState> emit,
  ) async {
    if (event.item.jadwalId == null) {
      emit(const NotifikasiActionFailure('ID jadwal tidak ditemukan'));
      return;
    }

    final currentState = state;
    List<NotificationItem> allNotifications = [];
    Set<NotificationItem> deferredNotifications = {};

    if (currentState is NotifikasiLoaded) {
      allNotifications = currentState.allNotifications;
      deferredNotifications = currentState.deferredNotifications;
    }

    emit(NotifikasiActionLoading());

    try {
      final response = await ApiService.postRiwayat(
        jadwalId: event.item.jadwalId!,
        status: 'Terlewat',
        waktuMinum: event.item.time,
      );

      if (response['success']) {
        emit(const NotifikasiActionSuccess('Alasan telah dicatat'));

        // Refresh lists
        final dashboardResponse = await ApiService.getDashboard(pasienId: event.pasienId);
        final riwayatResponse = await ApiService.getRiwayat(pasienId: event.pasienId);

        if (dashboardResponse['success']) {
          final updatedNotifications = <NotificationItem>[];
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

              final List<String> times = waktuStr
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              for (final waktu in times) {
                if (_isTimeExpired(waktu)) continue;

                if (parsedJadwalId != null &&
                    takenTodayJadwalIds.contains(parsedJadwalId)) {
                  continue;
                }

                if (_hasTimeArrived(waktu)) {
                  updatedNotifications.add(
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

                try {
                  final timeParts = waktu.split(':');
                  if (timeParts.length == 2) {
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);

                    minute -= 15;
                    if (minute < 0) {
                      minute += 60;
                      hour -= 1;
                      if (hour < 0) hour = 23;
                    }

                    final advanceTime =
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                    if (!_isTimeExpired(advanceTime) &&
                        _hasTimeArrived(advanceTime)) {
                      updatedNotifications.add(
                        NotificationItem(
                          title: namaObat,
                          desc: 'Siapkan obat ini. Waktu minum: $waktu',
                          time: waktu, // Tampilkan waktu jadwal sebenarnya, bukan advanceTime
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

              if (status == 'Terlewat' || status == 'Terlambat') {
                final today = DateTime.now();
                try {
                  final trackingDate = DateTime.parse(tanggal);
                  final isToday = trackingDate.year == today.year &&
                      trackingDate.month == today.month &&
                      trackingDate.day == today.day;

                  if (isToday && status == 'Terlewat') {
                    updatedNotifications.add(
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

          final uniqueUpdatedNotifications = <NotificationItem>[];
          for (final notif in updatedNotifications) {
            bool isDuplicate = false;
            for (final existing in uniqueUpdatedNotifications) {
              if (_isSameNotification(notif, existing)) {
                isDuplicate = true;
                break;
              }
            }
            if (!isDuplicate) {
              uniqueUpdatedNotifications.add(notif);
            }
          }

          uniqueUpdatedNotifications.sort((a, b) => b.time.compareTo(a.time));

          emit(NotifikasiLoaded(
            allNotifications: uniqueUpdatedNotifications,
            deferredNotifications: deferredNotifications,
          ));
        } else {
          emit(NotifikasiLoaded(
            allNotifications: allNotifications,
            deferredNotifications: deferredNotifications,
          ));
        }
      } else {
        emit(NotifikasiActionFailure(response['error'] ?? 'Gagal mencatat alasan'));
        emit(NotifikasiLoaded(
          allNotifications: allNotifications,
          deferredNotifications: deferredNotifications,
        ));
      }
    } catch (e) {
      emit(NotifikasiActionFailure(ErrorHandler.getErrorMessage(e)));
      emit(NotifikasiLoaded(
        allNotifications: allNotifications,
        deferredNotifications: deferredNotifications,
      ));
    }
  }

  Future<void> _onAddMockNotification(
    AddMockNotification event,
    Emitter<NotifikasiState> emit,
  ) async {
    // Jangan tambahkan jika sudah dihapus (cek in-memory cache)
    if (_pendingDeletedKeys.contains(event.item.uniqueKey)) return;

    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      final isDuplicate = currentState.allNotifications.any((n) => _isSameNotification(n, event.item));
      if (isDuplicate) {
        return;
      }
      final updatedNotifications = List<NotificationItem>.from(currentState.allNotifications)
        ..insert(0, event.item); // taruh paling atas
      emit(currentState.copyWith(allNotifications: updatedNotifications));
    } else {
      emit(NotifikasiLoaded(
        allNotifications: [event.item],
        deferredNotifications: const {},
      ));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotifikasiState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      // 1. Optimistic Update: Mark as read and emit state immediately to update UI instantly
      final updatedNotifications = currentState.allNotifications.map((notif) {
        if (notif.uniqueKey == event.item.uniqueKey && !notif.isRead) {
          return NotificationItem(
            title: notif.title,
            desc: notif.desc,
            time: notif.time,
            type: notif.type,
            jadwalId: notif.jadwalId,
            aturan: notif.aturan,
            isAdvanceReminder: notif.isAdvanceReminder,
            id: notif.id,
            isRead: true,
          );
        }
        return notif;
      }).toList();
      
      emit(currentState.copyWith(allNotifications: updatedNotifications));

      // 2. Perform persistent SharedPreferences write in the background
      try {
        await NotificationStorageService.instance.markKeyAsRead(event.item.uniqueKey);
      } catch (_) {}
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotifikasiState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      final keys = event.items.map((i) => i.uniqueKey).toList();
      await NotificationStorageService.instance.markAllAsRead(keys);
      
      final updatedNotifications = currentState.allNotifications.map((notif) {
        if (!notif.isRead) {
          return NotificationItem(
            title: notif.title,
            desc: notif.desc,
            time: notif.time,
            type: notif.type,
            jadwalId: notif.jadwalId,
            aturan: notif.aturan,
            isAdvanceReminder: notif.isAdvanceReminder,
            id: notif.id,
            isRead: true,
          );
        }
        return notif;
      }).toList();
      
      emit(currentState.copyWith(allNotifications: updatedNotifications));
    }
  }

  List<String> _getRelatedKeys(NotificationItem item) {
    final keys = <String>[item.uniqueKey];
    if (item.jadwalId == null || item.id != null) {
      return keys;
    }

    try {
      final parts = item.time.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (item.isAdvanceReminder) {
          minute += 15;
          if (minute >= 60) {
            minute -= 60;
            hour += 1;
            if (hour >= 24) hour = 0;
          }
          final actualTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          keys.add('dynamic_${item.jadwalId}_$actualTime');
        } else {
          minute -= 15;
          if (minute < 0) {
            minute += 60;
            hour -= 1;
            if (hour < 0) hour = 23;
          }
          final advanceTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          keys.add('dynamic_${item.jadwalId}_$advanceTime');
        }
      }
    } catch (_) {}

    return keys;
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotifikasiState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
      final relatedKeys = _getRelatedKeys(event.item);

      // Tambahkan ke in-memory cache SEGERA sebelum operasi storage async
      // agar FetchNotifications yang berjalan bersamaan tidak me-load ulang notifikasi ini
      _pendingDeletedKeys.addAll(relatedKeys);

      final updatedNotifications = currentState.allNotifications
          .where((notif) => !relatedKeys.contains(notif.uniqueKey))
          .toList();
      
      emit(currentState.copyWith(allNotifications: updatedNotifications));

      try {
        for (final key in relatedKeys) {
          await NotificationStorageService.instance.markKeyAsDeleted(key);
        }
      } catch (_) {}
    }
  }
}
