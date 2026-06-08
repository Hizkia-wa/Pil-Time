import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../utils/error_handler.dart';
import '../../models/obat.dart';
import '../../screens/info_obat/info_obat.dart';
import 'info_obat_event.dart';
import 'info_obat_state.dart';

class InfoObatBloc extends Bloc<InfoObatEvent, InfoObatState> {
  InfoObatBloc() : super(InfoObatInitial()) {
    on<FetchInfoObat>(_onFetchInfoObat);
  }

  Future<void> _onFetchInfoObat(
    FetchInfoObat event,
    Emitter<InfoObatState> emit,
  ) async {
    emit(InfoObatLoading());
    try {
      final response = await ApiService.getMedicines(pasienId: event.pasienId);
      if (!response['success']) {
        emit(InfoObatFailure(response['error'] ?? 'Gagal mengambil data obat'));
        return;
      }

      final responseData = response['data'] as Map<String, dynamic>;
      final List<dynamic> jadwalsList = responseData['jadwals'] ?? [];
      final obats = jadwalsList
          .map((item) => ObatDetail.fromJson(item as Map<String, dynamic>))
          .toList();

      // Group medicines by tanggalMulai (include all active medicines, including mandiri)
      final Map<String, List<ObatDetail>> grouped = {};
      for (var obat in obats) {
        if (obat.status.toLowerCase() == 'aktif') {
          final key = obat.tanggalMulai;
          if (!grouped.containsKey(key)) {
            grouped[key] = [];
          }
          grouped[key]!.add(obat);
        }
      }

      // Convert to ObatDay sorted by date (newest first)
      final List<ObatDay> days = grouped.entries
          .map((e) {
            try {
              final date = DateTime.parse(e.key);
              return ObatDay(tanggal: date, obatList: e.value);
            } catch (e) {
              return null;
            }
          })
          .whereType<ObatDay>()
          .toList();

      days.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      emit(InfoObatLoaded(days));
    } catch (e) {
      emit(InfoObatFailure(ErrorHandler.getErrorMessage(e)));
    }
  }
}
