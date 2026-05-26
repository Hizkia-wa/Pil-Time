import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../screens/riwayat/riwayat_konsumsi_obat.dart';
import 'riwayat_event.dart';
import 'riwayat_state.dart';

class RiwayatBloc extends Bloc<RiwayatEvent, RiwayatState> {
  RiwayatBloc() : super(RiwayatInitial()) {
    on<FetchRiwayat>(_onFetchRiwayat);
  }

  List<DayLog> _mapResponseToDayLogs(List<dynamic> response) {
    if (response.isEmpty) return [];

    // Group by tanggal
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in response) {
      final tanggal = item['tanggal'] as String?;
      if (tanggal != null) {
        grouped.putIfAbsent(tanggal, () => []);
        grouped[tanggal]!.add(item as Map<String, dynamic>);
      }
    }

    // Convert to DayLog
    final dayLogs = <DayLog>[];
    for (final entry in grouped.entries) {
      final date = DateTime.parse(entry.key);
      final logs = <MedLog>[];

      for (final item in entry.value) {
        final status = item['status'] as String?;
        final namaObat = item['nama_obat'] as String? ?? 'Obat';
        final waktuMinum = item['waktu_minum'] as String?;
        final jadwal = item['jadwal'] as String?;

        // Map status
        MedStatus medStatus;
        if (status == 'Diminum') {
          medStatus = MedStatus.taken;
        } else if (status == 'Terlambat') {
          medStatus = MedStatus.late;
        } else {
          medStatus = MedStatus.missed;
        }

        // Build instruction from waktu_minum or jadwal
        final instruction = waktuMinum ?? jadwal ?? 'Tidak ada waktu';

        logs.add(
          MedLog(name: namaObat, instruction: instruction, status: medStatus),
        );
      }

      dayLogs.add(DayLog(date: date, logs: logs));
    }

    // Sort by date descending (newest first)
    dayLogs.sort((a, b) => b.date.compareTo(a.date));
    return dayLogs;
  }

  Future<void> _onFetchRiwayat(
    FetchRiwayat event,
    Emitter<RiwayatState> emit,
  ) async {
    emit(RiwayatLoading());
    try {
      final token = await AuthService.getToken();
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/api/pasien/riwayat"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        final dayLogs = _mapResponseToDayLogs(data);
        emit(RiwayatLoaded(allData: dayLogs));
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['message'] ??
            errorBody['error'] ??
            'Server Error ${response.statusCode}';
        emit(RiwayatFailure(errorMsg));
      }
    } catch (e) {
      emit(RiwayatFailure(e.toString()));
    }
  }
}
