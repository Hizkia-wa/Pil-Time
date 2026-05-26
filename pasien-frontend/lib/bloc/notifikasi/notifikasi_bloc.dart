import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../screens/notifikasi/notifikasi_screen.dart';
import 'notifikasi_event.dart';
import 'notifikasi_state.dart';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  NotifikasiBloc() : super(NotifikasiInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsTaken>(_onMarkNotificationAsTaken);
    on<DeferNotificationEvent>(_onDeferNotification);
    on<UndeferNotificationEvent>(_onUndeferNotification);
    on<SubmitMissedReasonEvent>(_onSubmitMissedReason);
    on<AddMockNotification>(_onAddMockNotification);
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

      notifications.sort((a, b) => b.time.compareTo(a.time));

      emit(NotifikasiLoaded(
        allNotifications: notifications,
        deferredNotifications: const {},
      ));
    } catch (e) {
      emit(NotifikasiFailure(e.toString()));
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

          updatedNotifications.sort((a, b) => b.time.compareTo(a.time));

          emit(NotifikasiLoaded(
            allNotifications: updatedNotifications,
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
      emit(NotifikasiActionFailure(e.toString()));
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

          updatedNotifications.sort((a, b) => b.time.compareTo(a.time));

          emit(NotifikasiLoaded(
            allNotifications: updatedNotifications,
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
      emit(NotifikasiActionFailure(e.toString()));
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
    final currentState = state;
    if (currentState is NotifikasiLoaded) {
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
}
