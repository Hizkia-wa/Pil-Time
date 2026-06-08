import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import '../../services/jadwal_cache_service.dart';
import '../../services/notification_service.dart';
import '../../models/dashboard.dart';
import '../../models/jadwal.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<FetchDashboard>(_onFetchDashboard);
    on<MarkAsTaken>(_onMarkAsTaken);
    on<MarkMandiriSlotAsTaken>(_onMarkMandiriSlotAsTaken);
  }

  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      Map<String, List<String>> tempRiwayat = {};
      final today = DateTime.now().toUtc().add(const Duration(hours: 7));
      final todayDateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final tempTakenJadwalIds = <int>{};
      final tempMissedJadwalIds = <int>{};
      final tempTakenMandiriSlots = <String>{};  // Key: "jadwalId_waktu"
      final tempMissedMandiriSlots = <String>{};
      final mandiriTodayRiwayat = <int, List<String>>{};
      final mandiriTodayMissed = <int, List<String>>{};
      final tempLoggedTodayJadwalIds = <int>{};

      // 1. Ambil riwayat kepatuhan untuk mewarnai kalender
      final riwayatResponse = await ApiService.getPasienRiwayat();
      if (riwayatResponse['success']) {
        final List<dynamic> data = riwayatResponse['data'] ?? [];
        for (final item in data) {
          final tanggalRaw = item['tanggal'] as String?;
          final status = item['status'] as String?;
          final jadwalIdStr = item['jadwal_id'];
          final parsedJadwalId = int.tryParse(jadwalIdStr.toString());

          if (tanggalRaw != null && status != null) {
            // Normalisasi tanggal: ambil hanya 10 karakter pertama (YYYY-MM-DD)
            // Mengantisipasi format ISO seperti "2026-06-08T00:00:00Z"
            final tanggal = tanggalRaw.length >= 10 ? tanggalRaw.substring(0, 10) : tanggalRaw;
            
            tempRiwayat.putIfAbsent(tanggal, () => []);
            tempRiwayat[tanggal]!.add(status);

            // Jika tanggal adalah hari ini
            if (tanggal == todayDateStr && parsedJadwalId != null) {
              tempLoggedTodayJadwalIds.add(parsedJadwalId);
              if (status == 'Diminum' || status == 'Terlambat') {
                tempTakenJadwalIds.add(parsedJadwalId);
                // Normalisasi waktu_minum ke format HH:MM (abaikan detik jika ada)
                final waktuRaw = item['waktu_minum'] as String? ?? '';
                final waktu = waktuRaw.length >= 5 ? waktuRaw.substring(0, 5) : waktuRaw;
                if (waktu.isNotEmpty) {
                  mandiriTodayRiwayat.putIfAbsent(parsedJadwalId, () => []);
                  mandiriTodayRiwayat[parsedJadwalId]!.add(waktu);
                }
              } else if (status == 'Terlewat') {
                tempMissedJadwalIds.add(parsedJadwalId);
                final waktuRaw = item['waktu_minum'] as String? ?? '';
                final waktu = waktuRaw.length >= 5 ? waktuRaw.substring(0, 5) : waktuRaw;
                if (waktu.isNotEmpty) {
                  mandiriTodayMissed.putIfAbsent(parsedJadwalId, () => []);
                  mandiriTodayMissed[parsedJadwalId]!.add(waktu);
                }
              }
            }
          }
        }
      }

      // 2. Ambil data dashboard utama
      final response = await ApiService.getDashboard(pasienId: event.pasienId);

      if (response['success']) {
        final dashboard = Dashboard.fromJson(response['data']);

        // Auto-log Terlewat jika sudah lewat 75 menit dan belum pernah dicatat hari ini (ignore Mandiri)
        // PENTING: Hanya jalankan auto-log jika data riwayat berhasil dimuat.
        // Jika gagal, tempLoggedTodayJadwalIds kosong dan bisa menimpa record Diminum di database.
        if (riwayatResponse['success']) {
          for (final j in dashboard.todayJadwals) {
            if (j.kategoriObat == 'Mandiri') continue;
            if (tempLoggedTodayJadwalIds.contains(j.id)) continue;

            try {
              final parts = j.waktuMinum.split(':');
              if (parts.length >= 2) {
                final jadwalDt = DateTime.utc(
                  today.year,
                  today.month,
                  today.day,
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                );
                final diffMinutes = today.difference(jadwalDt).inMinutes;
                if (diffMinutes > 75) {
                  // Log ke backend menggunakan waktu minum asli agar key konstan
                  await ApiService.postRiwayat(
                    jadwalId: j.id,
                    status: 'Terlewat',
                    waktuMinum: j.waktuMinum,
                  );
                  tempLoggedTodayJadwalIds.add(j.id);
                  tempMissedJadwalIds.add(j.id);
                  tempRiwayat.putIfAbsent(todayDateStr, () => []);
                  tempRiwayat[todayDateStr]!.add('Terlewat');
                  debugPrint(
                      '[DashboardBloc] Auto-logged Terlewat for jadwal #${j.id} (${j.namaObat})');
                }
              }
            } catch (e) {
              debugPrint('[DashboardBloc] Gagal auto-log Terlewat: $e');
            }
          }
        }

        // Setelah mendapat dashboard, rekonstruksi taken mandiri slots
        tempTakenMandiriSlots.clear();
        tempMissedMandiriSlots.clear();
        final mandiriJadwalIds = <int>[];

        for (final j in dashboard.todayJadwals) {
          if (j.kategoriObat == 'Mandiri') {
            mandiriJadwalIds.add(j.id);
            if (mandiriTodayRiwayat.containsKey(j.id)) {
              for (final w in mandiriTodayRiwayat[j.id]!) {
                tempTakenMandiriSlots.add('${j.id}_$w');
              }
            }
            if (mandiriTodayMissed.containsKey(j.id)) {
              for (final w in mandiriTodayMissed[j.id]!) {
                tempMissedMandiriSlots.add('${j.id}_$w');
              }
            }
          }
        }

        // Hapus mandiri IDs dari takenJadwalIds dan missedJadwalIds (dikelola terpisah via slot)
        tempTakenJadwalIds.removeAll(mandiriJadwalIds);
        tempMissedJadwalIds.removeAll(mandiriJadwalIds);
        // Bangun mandiri slots dari riwayat hari ini
        for (final j in dashboard.todayJadwals) {
          if (j.kategoriObat != 'Mandiri') continue;
          final slots = j.waktuMinum.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          final riwayatWaktuList = mandiriTodayRiwayat[j.id] ?? [];
          for (final slot in slots) {
            // Cocokkan slot dengan waktu yang ada di riwayat hari ini, normalisasi detik bila perlu
            if (riwayatWaktuList.any((r) {
              final rClean = r.trim();
              final rPrefix = rClean.length >= 5 ? rClean.substring(0, 5) : rClean;
              final slotPrefix = slot.length >= 5 ? slot.substring(0, 5) : slot;
              return rPrefix == slotPrefix;
            })) {
              tempTakenMandiriSlots.add('${j.id}_$slot');
            }
          }
        }

        // Simpan jadwal ke cache untuk akses offline
        await JadwalCacheService.saveJadwals(
          [...dashboard.todayJadwals, ...dashboard.allJadwals],
        );

        // Auto-schedule alarm di background (hanya untuk yang belum diminum)
        final unfinishedJadwals = dashboard.todayJadwals
            .where((j) => !tempTakenJadwalIds.contains(j.id))
            .toList();
        _scheduleAlarmsBackground(unfinishedJadwals);

        emit(DashboardLoaded(
          dashboard: dashboard,
          riwayatByDate: tempRiwayat,
          takenJadwalIds: tempTakenJadwalIds,
          takenMandiriSlots: tempTakenMandiriSlots,
          missedJadwalIds: tempMissedJadwalIds,
          missedMandiriSlots: tempMissedMandiriSlots,
          fromFetch: true,
        ));
      } else {
        // Jika 401: token expired/hilang
        if (response['statusCode'] == 401) {
          emit(DashboardFailure(
            error: response['error'] ?? 'Token kedaluwarsa',
            statusCode: 401,
          ));
          return;
        }

        // Offline fallback: coba load dari cache
        final cachedJadwals = await JadwalCacheService.getJadwals();
        if (cachedJadwals.isNotEmpty) {
          final offlineDashboard = Dashboard(
            pasienId: event.pasienId,
            nama: event.pasienNama,
            email: '',
            noTelepon: '',
            noTeleponPendamping: '',
            jenisKelamin: '',
            tanggalLahir: '',
            alamat: '',
            todayJadwals: cachedJadwals.where((j) => j.status == 'aktif').toList(),
            allJadwals: cachedJadwals,
          );
          emit(DashboardLoaded(
            dashboard: offlineDashboard,
            riwayatByDate: tempRiwayat,
            takenJadwalIds: tempTakenJadwalIds,
            takenMandiriSlots: tempTakenMandiriSlots,
            missedJadwalIds: tempMissedJadwalIds,
            missedMandiriSlots: tempMissedMandiriSlots,
          ));
        } else {
          emit(DashboardFailure(
            error: response['error'] ?? 'Gagal memuat dashboard',
            statusCode: response['statusCode'],
          ));
        }
      }
    } catch (e) {
      // Offline fallback jika terjadi error koneksi
      try {
        final cachedJadwals = await JadwalCacheService.getJadwals();
        if (cachedJadwals.isNotEmpty) {
          final offlineDashboard = Dashboard(
            pasienId: event.pasienId,
            nama: event.pasienNama,
            email: '',
            noTelepon: '',
            noTeleponPendamping: '',
            jenisKelamin: '',
            tanggalLahir: '',
            alamat: '',
            todayJadwals: cachedJadwals.where((j) => j.status == 'aktif').toList(),
            allJadwals: cachedJadwals,
          );
          emit(DashboardLoaded(
            dashboard: offlineDashboard,
            riwayatByDate: const {},
            takenJadwalIds: const {},
            takenMandiriSlots: const {},
            missedJadwalIds: const {},
            missedMandiriSlots: const {},
          ));
          return;
        }
      } catch (_) {}
      emit(DashboardFailure(error: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onMarkAsTaken(
    MarkAsTaken event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isMarking: true));

    try {
      final now = DateTime.now();
      final waktuSekarang = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      // Gunakan ComplianceStatus untuk menentukan status kepatuhan
      final complianceStatus = NotificationService.checkComplianceFromString(
        scheduledTimeStr: event.jadwal.waktuMinum,
        confirmationTime: now,
      );
      final status = complianceStatus.backendValue;

      final result = await ApiService.postRiwayat(
        jadwalId: event.jadwal.id,
        status: status,
        waktuMinum: waktuSekarang,
      );

      if (result['success']) {
        // Batalkan alarm/snooze yang sudah dijadwalkan karena sudah diminum
        NotificationService.instance.cancelJadwal(event.jadwal.id);

        final updatedTaken = Set<int>.from(currentState.takenJadwalIds)..add(event.jadwal.id);
        // Hapus dari missed jika sebelumnya terlewat lalu diminum sekarang
        final updatedMissed = Set<int>.from(currentState.missedJadwalIds)..remove(event.jadwal.id);
        
        // Buat temp copy riwayat harian baru
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final updatedRiwayat = Map<String, List<String>>.from(currentState.riwayatByDate);
        updatedRiwayat.putIfAbsent(todayStr, () => []);
        updatedRiwayat[todayStr]!.add(status);

        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: updatedTaken,
          takenMandiriSlots: currentState.takenMandiriSlots,
          missedJadwalIds: updatedMissed,
          missedMandiriSlots: currentState.missedMandiriSlots,
          isMarking: false,
        ));

        // emit temporary success state untuk trigger snackbar reaktif di UI
        emit(DashboardMarkingSuccess('${event.jadwal.namaObat} berhasil dicatat!'));
        
        // Kembalikan ke state loaded agar widget tetap menampilkan dashboard
        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: updatedTaken,
          takenMandiriSlots: currentState.takenMandiriSlots,
          missedJadwalIds: updatedMissed,
          missedMandiriSlots: currentState.missedMandiriSlots,
          isMarking: false,
        ));
      } else {
        emit(currentState.copyWith(isMarking: false));
        emit(DashboardMarkingFailure(result['error'] ?? 'Gagal mencatat'));
        emit(currentState);
      }
    } catch (e) {
      emit(currentState.copyWith(isMarking: false));
      emit(DashboardMarkingFailure(ErrorHandler.getErrorMessage(e)));
      emit(currentState);
    }
  }

  /// Handler untuk checklist satu slot waktu obat mandiri
  Future<void> _onMarkMandiriSlotAsTaken(
    MarkMandiriSlotAsTaken event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isMarking: true));

    try {
      final now = DateTime.now();
      // Gunakan slot time sebagai waktu minum yang tercatat
      final result = await ApiService.postRiwayat(
        jadwalId: event.jadwal.id,
        status: 'Diminum',
        waktuMinum: event.waktuSlot,
      );

      if (result['success']) {
        NotificationService.instance.cancelJadwal(event.jadwal.id);

        final slotKey = '${event.jadwal.id}_${event.waktuSlot}';
        final updatedMandiriSlots = Set<String>.from(currentState.takenMandiriSlots)..add(slotKey);
        // Hapus slot mandiri dari missed jika ada
        final updatedMissedMandiri = Set<String>.from(currentState.missedMandiriSlots)..remove(slotKey);

        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final updatedRiwayat = Map<String, List<String>>.from(currentState.riwayatByDate);
        updatedRiwayat.putIfAbsent(todayStr, () => []);
        updatedRiwayat[todayStr]!.add('Diminum');

        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: currentState.takenJadwalIds,
          takenMandiriSlots: updatedMandiriSlots,
          missedJadwalIds: currentState.missedJadwalIds,
          missedMandiriSlots: updatedMissedMandiri,
          isMarking: false,
        ));

        emit(DashboardMarkingSuccess('${event.jadwal.namaObat} (${event.waktuSlot}) berhasil dicatat!'));

        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: currentState.takenJadwalIds,
          takenMandiriSlots: updatedMandiriSlots,
          missedJadwalIds: currentState.missedJadwalIds,
          missedMandiriSlots: updatedMissedMandiri,
          isMarking: false,
        ));
      } else {
        emit(currentState.copyWith(isMarking: false));
        emit(DashboardMarkingFailure(result['error'] ?? 'Gagal mencatat'));
        emit(currentState);
      }
    } catch (e) {
      emit(currentState.copyWith(isMarking: false));
      emit(DashboardMarkingFailure(ErrorHandler.getErrorMessage(e)));
      emit(currentState);
    }
  }

  void _scheduleAlarmsBackground(List<Jadwal> jadwals) {
    Future(() async {
      try {
        final notifModels = jadwals
            .where((j) => j.status.toLowerCase() == 'aktif')
            .map((j) => JadwalNotifModel(
                  jadwalId: j.id,
                  namaObat: j.namaObat,
                  dosis: '${j.jumlahDosis} ${j.satuan}',
                  waktuMinum: j.waktuMinum,
                  waktuReminderPagi: j.waktuReminderPagi,
                  waktuReminderMalam: j.waktuReminderMalam,
                ))
            .toList();

        await NotificationService.instance.scheduleAllJadwals(notifModels);
        debugPrint('[DashboardBloc] ${notifModels.length} alarm dijadwalkan dari dashboard.');
      } catch (e) {
        debugPrint('[DashboardBloc] Gagal jadwalkan alarm (non-fatal): $e');
      }
    });
  }
}
