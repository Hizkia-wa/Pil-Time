import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_service.dart';

class ApiService {
  // Main backend (port 8080) — semua data aplikasi
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth service (port 8081) — untuk forgot/reset password (public)
  static const String authUrl = 'http://10.0.2.2:8081';

  /// Helper: buat header dengan JWT token
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ============================
  //         DASHBOARD
  // ============================

  static Future<Map<String, dynamic>> getDashboard({
    required int pasienId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Gagal mengambil data dashboard',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ============================
  //          JADWAL
  // ============================

  static Future<Map<String, dynamic>> getJadwal({required int pasienId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/jadwal'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Gagal mengambil data jadwal',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getMedicines({
    required int pasienId,
  }) async {
    return getJadwal(pasienId: pasienId);
  }

  static Future<Map<String, dynamic>> getTodayMedications({
    required int pasienId,
  }) async {
    return getDashboard(pasienId: pasienId);
  }

  // ============================
  //          PROFILE
  // ============================

  static Future<Map<String, dynamic>> getProfile({
    required int pasienId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Gagal mengambil data profil',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ============================
  //          RIWAYAT
  // ============================

  static Future<Map<String, dynamic>> getRiwayat({
    required int pasienId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/riwayat/pasien/$pasienId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {'success': true, 'data': responseBody['data'] ?? []};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error':
              errorBody['message'] ??
              errorBody['error'] ??
              'Gagal mengambil riwayat',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ============================
  //         RUTINITAS
  // ============================

  static Future<Map<String, dynamic>> createRutinitas({
    required int pasienId,
    required String namaRutinitas,
    required String waktuReminder,
    String? deskripsi,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/pasien/rutinitas'),
        headers: headers,
        body: jsonEncode({
          'pasien_id': pasienId,
          'nama_rutinitas': namaRutinitas,
          'deskripsi': deskripsi ?? '',
          'waktu_reminder': waktuReminder,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error':
              errorBody['error'] ??
              errorBody['message'] ??
              'Gagal membuat rutinitas',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ============================
  //       FORGOT PASSWORD
  //    (Public — via auth-service)
  // ============================

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/pasien/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Gagal kirim OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/pasien/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'OTP salah'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/pasien/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'new_password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Gagal reset password',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal'};
    }
  }
}
