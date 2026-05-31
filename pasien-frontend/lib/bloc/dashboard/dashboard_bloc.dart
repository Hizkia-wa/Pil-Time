import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
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
  }

  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      Map<String, List<String>> tempRiwayat = {};
      final today = DateTime.now();
      final todayDateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final tempTakenJadwalIds = <int>{};
      final tempLoggedTodayJadwalIds = <int>{};

      // 1. Ambil riwayat kepatuhan untuk mewarnai kalender
      final riwayatResponse = await ApiService.getPasienRiwayat();
      if (riwayatResponse['success']) {
        final List<dynamic> data = riwayatResponse['data'] ?? [];
        for (final item in data) {
          final tanggal = item['tanggal'] as String?;
          final status = item['status'] as String?;
          final jadwalIdStr = item['jadwal_id'];
          final parsedJadwalId = int.tryParse(jadwalIdStr.toString());

          if (tanggal != null && status != null) {
            tempRiwayat.putIfAbsent(tanggal, () => []);
            tempRiwayat[tanggal]!.add(status);

            // Jika tanggal adalah hari ini
            if (tanggal == todayDateStr && parsedJadwalId != null) {
              tempLoggedTodayJadwalIds.add(parsedJadwalId);
              if (status == 'Diminum' || status == 'Terlambat') {
                tempTakenJadwalIds.add(parsedJadwalId);
              }
            }
          }
        }
      }

      // 2. Ambil data dashboard utama
      final response = await ApiService.getDashboard(pasienId: event.pasienId);

      if (response['success']) {
        final dashboard = Dashboard.fromJson(response['data']);

        // Auto-log Terlewat jika sudah lewat 75 menit dan belum pernah dicatat hari ini
        for (final j in dashboard.todayJadwals) {
          if (tempLoggedTodayJadwalIds.contains(j.id)) continue;

          try {
            final parts = j.waktuMinum.split(':');
            if (parts.length >= 2) {
              final jadwalDt = DateTime(
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

        // Simpan jadwal ke cache untuk akses offline
        await JadwalCacheService.saveJadwals(
          [...dashboard.todayJadwals, ...dashboard.allJadwals],
        );

        // Auto-schedule alarm di background
        _scheduleAlarmsBackground(dashboard.todayJadwals);

        emit(DashboardLoaded(
          dashboard: dashboard,
          riwayatByDate: tempRiwayat,
          takenJadwalIds: tempTakenJadwalIds,
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
          ));
          return;
        }
      } catch (_) {}
      emit(DashboardFailure(error: e.toString()));
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
        
        // Buat temp copy riwayat harian baru
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final updatedRiwayat = Map<String, List<String>>.from(currentState.riwayatByDate);
        updatedRiwayat.putIfAbsent(todayStr, () => []);
        updatedRiwayat[todayStr]!.add(status);

        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: updatedTaken,
          isMarking: false,
        ));

        // emit temporary success state untuk trigger snackbar reaktif di UI
        emit(DashboardMarkingSuccess('${event.jadwal.namaObat} berhasil dicatat!'));
        
        // Kembalikan ke state loaded agar widget tetap menampilkan dashboard
        emit(DashboardLoaded(
          dashboard: currentState.dashboard,
          riwayatByDate: updatedRiwayat,
          takenJadwalIds: updatedTaken,
          isMarking: false,
        ));
      } else {
        emit(currentState.copyWith(isMarking: false));
        emit(DashboardMarkingFailure(result['error'] ?? 'Gagal mencatat'));
        emit(currentState);
      }
    } catch (e) {
      emit(currentState.copyWith(isMarking: false));
      emit(DashboardMarkingFailure(e.toString()));
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
