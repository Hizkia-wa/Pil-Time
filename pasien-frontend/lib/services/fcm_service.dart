import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/jadwal.dart';
import 'auth_service.dart';
import 'jadwal_cache_service.dart';
import 'notification_service.dart';

// ============================================================
// BACKGROUND HANDLER — harus top-level function (bukan method)
// Dipanggil saat app di-background atau terminated
// ============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Pesan diterima: ${message.data}');

  if (message.data['type'] == 'jadwal_baru') {
    // Simpan jadwal ke local cache
    final jadwal = _buildJadwalFromFcmData(message.data);
    if (jadwal != null) {
      await JadwalCacheService.addOrUpdateJadwal(jadwal);

      // Schedule alarm lokal agar muncul saat offline
      await NotificationService.instance.initialize();
      await NotificationService.instance.scheduleJadwalNotification(
        notifId: jadwal.id,
        namaObat: jadwal.namaObat,
        dosis: '${jadwal.jumlahDosis} ${jadwal.satuan}',
        scheduledTime: jadwal.waktuMinum,
        jadwalId: jadwal.id,
      );
    }
  }
}

/// Parse FCM data payload menjadi Jadwal model
Jadwal? _buildJadwalFromFcmData(Map<String, dynamic> data) {
  try {
    return Jadwal(
      id: int.tryParse(data['jadwal_id'] ?? '0') ?? 0,
      pasienId: 0,
      pasienNama: '',
      namaObat: data['nama_obat'] ?? '',
      jumlahDosis: int.tryParse(data['jumlah_dosis'] ?? '1') ?? 1,
      satuan: data['satuan'] ?? '',
      kategoriObat: data['kategori_obat'] ?? '',
      takaranObat: '',
      frekuensiPerHari: '',
      waktuMinum: data['waktu_minum'] ?? '',
      aturanKonsumsi: data['aturan_konsumsi'] ?? '',
      catatan: '',
      tipeDurasi: '',
      jumlahHari: 0,
      tanggalMulai: data['tanggal_mulai'] ?? '',
      tanggalSelesai: data['tanggal_selesai'] ?? '',
      waktuReminderPagi: data['waktu_reminder_pagi'] ?? '',
      waktuReminderMalam: data['waktu_reminder_malam'] ?? '',
      status: data['status'] ?? 'aktif',
      createdAt: '',
      updatedAt: '',
    );
  } catch (e) {
    debugPrint('[FCM] Gagal parse jadwal dari payload: $e');
    return null;
  }
}

// ============================================================
// FCM SERVICE
// ============================================================
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _backendUrl = 'http://10.0.2.2:8080';

  // ==========================================================
  // INISIALISASI — panggil setelah Firebase.initializeApp()
  // ==========================================================
  Future<void> initialize() async {
    // 1. Request permission (Android 13+, iOS)
    await _requestPermission();

    // 2. Handle pesan saat app FOREGROUND
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 3. Handle tap notifikasi saat app BACKGROUND (tapi belum terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 4. Daftarkan token ke backend
    await _registerTokenToBackend();

    // 5. Pantau perubahan token (token bisa berubah saat reinstall)
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refresh: $newToken');
      _sendTokenToBackend(newToken);
    });

    debugPrint('[FCM] FcmService initialized ✓');
  }

  // ==========================================================
  // FOREGROUND MESSAGE HANDLER
  // Saat app terbuka dan notifikasi datang
  // ==========================================================
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM Foreground] Data: ${message.data}');

    if (message.data['type'] == 'jadwal_baru') {
      // Simpan ke cache
      final jadwal = _buildJadwalFromFcmData(message.data);
      if (jadwal != null) {
        await JadwalCacheService.addOrUpdateJadwal(jadwal);

        // Schedule alarm lokal
        await NotificationService.instance.scheduleJadwalNotification(
          notifId: jadwal.id,
          namaObat: jadwal.namaObat,
          dosis: '${jadwal.jumlahDosis} ${jadwal.satuan}',
          scheduledTime: jadwal.waktuMinum,
          jadwalId: jadwal.id,
        );
      }

      // Tampilkan notifikasi lokal di foreground (FCM tidak auto-display)
      final title = message.data['title'] ?? '💊 Jadwal Obat Baru';
      final body = message.data['body'] ?? 'Nakes menambahkan jadwal obat baru';
      await NotificationService.instance.showImmediateNotification(
        title: title,
        body: body,
        payload: message.data['jadwal_id'],
      );
    }
  }

  // ==========================================================
  // OPENED FROM NOTIFICATION (app di background, user tap notif)
  // ==========================================================
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] App dibuka dari notifikasi: ${message.data}');
    // Navigasi bisa ditambahkan di sini menggunakan GlobalNavigatorKey
  }

  // ==========================================================
  // REGISTER TOKEN KE BACKEND
  // ==========================================================
  Future<void> _registerTokenToBackend() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[FCM] Token null — skip register');
        return;
      }
      debugPrint('[FCM] Token: ${token.substring(0, 10)}...');
      await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('[FCM] Gagal ambil token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = await AuthService.getToken();
      if (authToken == null || authToken.isEmpty) {
        debugPrint('[FCM] Belum login — skip token register');
        return;
      }

      final response = await http.post(
        Uri.parse('$_backendUrl/api/pasien/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('[FCM] Token berhasil didaftarkan ke backend ✓');
      } else {
        debugPrint('[FCM] Gagal daftar token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FCM] Error daftar token: $e');
    }
  }

  // ==========================================================
  // REQUEST PERMISSION
  // ==========================================================
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }
}
