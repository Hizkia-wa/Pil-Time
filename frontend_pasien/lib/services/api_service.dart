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

  static Future<Map<String, dynamic>> getJadwal({
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
}
