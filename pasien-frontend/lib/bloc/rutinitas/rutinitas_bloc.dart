import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import 'rutinitas_event.dart';
import 'rutinitas_state.dart';

class RutinitasBloc extends Bloc<RutinitasEvent, RutinitasState> {
  RutinitasBloc() : super(RutinitasSehatInitial()) {
    on<FetchRutinitasSehat>(_onFetchRutinitasSehat);
    on<CreateObatMandiri>(_onCreateObatMandiri);
    on<UpdateObatMandiri>(_onUpdateObatMandiri);
    on<DeleteObatMandiri>(_onDeleteObatMandiri);
    on<CreateRutinitasSehat>(_onCreateRutinitasSehat);
    on<UpdateRutinitasSehat>(_onUpdateRutinitasSehat);
    on<DeleteRutinitasSehat>(_onDeleteRutinitasSehat);
  }

  String get _baseUrl => "${ApiService.baseUrl}/api/pasien";

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _onFetchRutinitasSehat(
    FetchRutinitasSehat event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasSehatLoading());
    try {
      final headers = await _getAuthHeaders();

      final obatResponse = await http.get(
        Uri.parse("$_baseUrl/obat-mandiri"),
        headers: headers,
      );

      final rutinitasResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas"),
        headers: headers,
      );

      final streakRutinitasResponse = await http.get(
        Uri.parse("$_baseUrl/rutinitas/streak/${event.pasienId}"),
        headers: headers,
      );

      final streakObatResponse = await http.get(
        Uri.parse("$_baseUrl/riwayat/streak/${event.pasienId}"),
        headers: headers,
      );

      List<dynamic> listObat = [];
      List<dynamic> listRutinitas = [];
      int streakRutinitas = 0;
      int streakObat = 0;

      if (obatResponse.statusCode == 200) {
        final obatData = jsonDecode(obatResponse.body);
        listObat = obatData['data'] ?? [];
      }

      if (rutinitasResponse.statusCode == 200) {
        final rutinitasData = jsonDecode(rutinitasResponse.body);
        listRutinitas = rutinitasData['data'] ?? [];
      }

      if (streakRutinitasResponse.statusCode == 200) {
        final streakData = jsonDecode(streakRutinitasResponse.body);
        streakRutinitas = streakData['current_streak'] ?? 0;
      }

      if (streakObatResponse.statusCode == 200) {
        final streakData = jsonDecode(streakObatResponse.body);
        streakObat = streakData['current_streak'] ?? 0;
      }

      emit(RutinitasSehatLoaded(
        listObat: listObat,
        listRutinitas: listRutinitas,
        streakRutinitas: streakRutinitas,
        streakObat: streakObat,
      ));
    } catch (e) {
      emit(RutinitasSehatFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCreateObatMandiri(
    CreateObatMandiri event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse("$_baseUrl/obat-mandiri"),
        headers: headers,
        body: jsonEncode(event.data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(const RutinitasActionSuccess('Obat berhasil ditambahkan'));
      } else {
        final errorBody = jsonDecode(response.body);
        emit(RutinitasActionFailure(errorBody['error'] ?? 'Gagal menambahkan obat'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateObatMandiri(
    UpdateObatMandiri event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse("$_baseUrl/obat-mandiri/${event.obatId}"),
        headers: headers,
        body: jsonEncode(event.data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const RutinitasActionSuccess('Obat berhasil diperbarui'));
      } else {
        final errorBody = jsonDecode(response.body);
        emit(RutinitasActionFailure(errorBody['error'] ?? 'Gagal memperbarui obat'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteObatMandiri(
    DeleteObatMandiri event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse("$_baseUrl/obat-mandiri/${event.obatId}"),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        emit(const RutinitasActionSuccess('Jadwal obat berhasil dihapus'));
      } else {
        emit(const RutinitasActionFailure('Gagal menghapus jadwal obat'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCreateRutinitasSehat(
    CreateRutinitasSehat event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse("$_baseUrl/rutinitas"),
        headers: headers,
        body: jsonEncode(event.payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(const RutinitasActionSuccess('Rutinitas berhasil disimpan!'));
      } else {
        final errorBody = jsonDecode(response.body);
        emit(RutinitasActionFailure(errorBody['error'] ?? errorBody['message'] ?? 'Gagal menyimpan rutinitas'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateRutinitasSehat(
    UpdateRutinitasSehat event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse("$_baseUrl/rutinitas/${event.id}"),
        headers: headers,
        body: jsonEncode(event.payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const RutinitasActionSuccess('Rutinitas berhasil diperbarui!'));
      } else {
        final errorBody = jsonDecode(response.body);
        emit(RutinitasActionFailure(errorBody['error'] ?? errorBody['message'] ?? 'Gagal memperbarui rutinitas'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteRutinitasSehat(
    DeleteRutinitasSehat event,
    Emitter<RutinitasState> emit,
  ) async {
    emit(RutinitasActionLoading());
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse("$_baseUrl/rutinitas/${event.id}"),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        emit(const RutinitasActionSuccess('Rutinitas berhasil dihapus'));
      } else {
        emit(const RutinitasActionFailure('Gagal menghapus rutinitas'));
      }
    } catch (e) {
      emit(RutinitasActionFailure(ErrorHandler.getErrorMessage(e)));
    }
  }
}
