import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  // Main backend (port 8080) — untuk data aplikasi
  static const String backendUrl = 'http://10.0.2.2:8080';

  // Auth service (port 8081) — untuk login, register, reset password
  static const String authUrl = 'http://10.0.2.2:8081';

  // Shared Preferences keys
  static const String _pasienIdKey = 'pasien_id';
  static const String _pasienNameKey = 'pasien_name';
  static const String _pasienEmailKey = 'pasien_email';
  static const String _tokenKey = 'auth_token';

  // ============================
  //      SESSION MANAGEMENT
  // ============================

  static Future<void> _saveSession({
    required int pasienId,
    required String pasienName,
    required String pasienEmail,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pasienIdKey, pasienId);
    await prefs.setString(_pasienNameKey, pasienName);
    await prefs.setString(_pasienEmailKey, pasienEmail);
    await prefs.setString(_tokenKey, token);
  }

  static Future<Map<String, dynamic>?> getPasienSession() async {
    final prefs = await SharedPreferences.getInstance();
    final pasienId = prefs.getInt(_pasienIdKey);
    final pasienName = prefs.getString(_pasienNameKey);
    final pasienEmail = prefs.getString(_pasienEmailKey);
    final token = prefs.getString(_tokenKey);

    if (pasienId == null || pasienName == null || pasienEmail == null || token == null) {
      return null;
    }

    return {
      'pasien_id': pasienId,
      'pasien_name': pasienName,
      'pasien_email': pasienEmail,
      'token': token,
    };
  }

  /// Ambil JWT token yang tersimpan
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pasienIdKey);
    await prefs.remove(_pasienNameKey);
    await prefs.remove(_pasienEmailKey);
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final pasienId = prefs.getInt(_pasienIdKey);
    final token = prefs.getString(_tokenKey);
    // Session valid hanya jika ada pasien_id DAN token JWT
    return pasienId != null && token != null && token.isNotEmpty;
  }

  // ============================
  //        AUTH: REGISTER
  // ============================

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String nik,
    required String tanggalLahir,
    required String telepon,
    required String jenisKelamin,
    required String alamat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/pasien/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': nama,
          'email': email,
          'password': password,
          'nik': nik,
          'tanggal_lahir': tanggalLahir,
          'telepon': telepon,
          'jenis_kelamin': jenisKelamin,
          'alamat': alamat,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ============================
  //         AUTH: LOGIN
  // ============================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/pasien/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan session termasuk JWT token
        await _saveSession(
          pasienId: data['pasien_id'] ?? 0,
          pasienName: data['nama_lengkap'] ?? data['nama'] ?? '',
          pasienEmail: data['email'] ?? '',
          token: data['token'] ?? '',
        );

        return {'success': true, 'data': data};
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: ${e.toString()}'};
    }
  }
}
