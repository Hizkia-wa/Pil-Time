import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jadwal.dart';

/// Service untuk menyimpan data jadwal obat secara lokal di device.
/// Jadwal disimpan ke SharedPreferences sehingga alarm bisa tetap
/// berfungsi saat pasien dalam kondisi offline.
class JadwalCacheService {
  static const String _cacheKey = 'cached_jadwals';

  // ── Simpan semua jadwal (dari dashboard API) ──────────────────────
  static Future<void> saveJadwals(List<Jadwal> jadwals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = jadwals.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_cacheKey, jsonList);
  }

  // ── Ambil jadwal dari cache (dipakai saat offline) ────────────────
  static Future<List<Jadwal>> getJadwals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cacheKey) ?? [];
    return jsonList
        .map((s) => Jadwal.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // ── Tambah 1 jadwal baru dari FCM payload ─────────────────────────
  // Dipanggil oleh FCM background handler saat nakes menambah jadwal
  static Future<void> addOrUpdateJadwal(Jadwal newJadwal) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cacheKey) ?? [];

    final jadwals = jsonList
        .map((s) => Jadwal.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    // Replace jika sudah ada, tambah jika belum
    final idx = jadwals.indexWhere((j) => j.id == newJadwal.id);
    if (idx >= 0) {
      jadwals[idx] = newJadwal;
    } else {
      jadwals.add(newJadwal);
    }

    final updated = jadwals.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_cacheKey, updated);
  }

  // ── Cek apakah cache tersedia ─────────────────────────────────────
  static Future<bool> hasCache() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_cacheKey);
    return list != null && list.isNotEmpty;
  }

  // ── Hapus cache (misal saat logout) ───────────────────────────────
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
