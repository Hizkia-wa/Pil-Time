import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Gunakan 10.0.2.2 untuk Android Emulator (alias host machine)
  // Gunakan localhost untuk iOS Simulator atau testing lokal
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<Map<String, dynamic>> getDashboard({
    required int pasienId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/dashboard?pasien_id=$pasienId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
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

  static Future<Map<String, dynamic>> getJadwal({required int pasienId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/jadwal?pasien_id=$pasienId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
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

  static Future<Map<String, dynamic>> getProfile({
    required int pasienId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/profile?pasien_id=$pasienId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
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

  static Future<Map<String, dynamic>> getTodayMedications({
    required int pasienId,
  }) async {
    try {
      // Get dashboard which includes today's jadwals
      final response = await getDashboard(pasienId: pasienId);
      return response;
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getRiwayat({
    required int pasienId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/riwayat/pasien/$pasienId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // Backend returns { "data": [...] }
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

  static Future<Map<String, dynamic>> getMedicines({
    required int pasienId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pasien/jadwal?pasien_id=$pasienId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Gagal mengambil data obat',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> createRutinitas({
    required int pasienId,
    required String namaRutinitas,
    required String waktuReminder,
    String? deskripsi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pasien/rutinitas'),
        headers: {
          'Content-Type': 'application/json',
          'X-Pasien-ID': pasienId.toString(),
        },
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

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pasien/forgot-password'),
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
        Uri.parse('$baseUrl/api/pasien/verify-reset-code'),
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
        Uri.parse('$baseUrl/api/pasien/reset-password'),
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
