import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../screens/alarm/alarm_ringing_screen.dart';

// ============================================================
// NOTIFICATION SERVICE — PIL TIME
// Handles: scheduling, cancelling, compliance-based reminders
// ============================================================

/// Callback global untuk handle notifikasi saat app di background / terminated.
/// Harus berupa top-level function (bukan method di dalam class).
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  debugPrint('[PilTime] Background notification tapped: ${response.payload}');
  // Payload berformat "jadwal_id:nama_obat"
  // Bisa di-parse di sini untuk navigasi atau log
}

class NotificationService {
  // ── Singleton ──────────────────────────────────────────────
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Konstanta Channel Android ──────────────────────────────
  static const String _channelId = 'pil_time_alarm';
  static const String _channelName = 'Alarm Minum Obat';
  static const String _channelDesc =
      'Notifikasi pengingat jadwal minum obat Pil Time';

  // ── Timezone WIB (Asia/Jakarta) ───────────────────────────
  static const String _timezone = 'Asia/Jakarta';

  // ==========================================================
  // INISIALISASI
  // Panggil sekali di main() sebelum runApp()
  // ==========================================================
  Future<void> initialize() async {
    if (_initialized) return;

    // Inisialisasi timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timezone));

    // Setting untuk Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setting untuk iOS/macOS
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    // Buat channel notifikasi Android
    await _createNotificationChannel();

    // Request permission di Android 13+
    await _requestPermissions();

    _initialized = true;
    debugPrint('[PilTime] NotificationService initialized ✓');
  }

  // ==========================================================
  // SCHEDULE ALARM — Jadwal tunggal berdasarkan waktu HH:MM
  //
  // [notifId]      : unique ID (gunakan jadwal_id)
  // [namaObat]     : nama obat untuk judul notifikasi
  // [dosis]        : misal "2 tablet"
  // [scheduledTime]: format "HH:MM" dari field waktu_minum backend
  // [jadwalId]     : payload untuk navigasi ketika notif di-tap
  // ==========================================================
  Future<void> scheduleJadwalNotification({
    required int notifId,
    required String namaObat,
    required String dosis,
    required String scheduledTime, // "HH:MM" atau "HH:MM, HH:MM"
    required int jadwalId,
  }) async {
    if (!_initialized) await initialize();

    // Pecah string waktu_minum jika dipisah koma (contoh: "08:00, 10:25, 14:00")
    final timeList = scheduledTime
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (int i = 0; i < timeList.length; i++) {
      final timeStr = timeList[i];
      final scheduledTZ = _buildScheduledDate(timeStr);
      if (scheduledTZ == null) {
        debugPrint('[PilTime] Invalid time format: $timeStr');
        continue;
      }

      // ID unik untuk setiap waktu (offset 1000 untuk setiap waktu tambahan)
      final currentNotifId = notifId + (i * 1000);

      // Pola Getaran Agresif (Panjang dan berulang)
      final Int64List vibrationPattern = Int64List.fromList([
        0,
        1000, // Getar 1 detik
        500,  // Jeda 0.5 detik
        1000,
        500,
        1000,
        500,
      ]);

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true, // Tampil over lock screen
        ongoing: false,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        // FLAG_INSISTENT (4): Membuat suara berdering terus menerus seperti alarm jam
        additionalFlags: Int32List.fromList(<int>[4]),
        styleInformation: const BigTextStyleInformation(''),
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notifDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        currentNotifId,
        '💊 Waktunya Minum Obat!',
        '$namaObat — $dosis',
        scheduledTZ,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$jadwalId:$namaObat',
        matchDateTimeComponents: DateTimeComponents.time, // Repeat harian
      );

      debugPrint(
          '[PilTime] Scheduled alarm #$currentNotifId for $namaObat at $timeStr (WIB)');
    }
  }

  // ==========================================================
  // SCHEDULE BANYAK JADWAL SEKALIGUS
  // Dipanggil dari dashboard setelah fetch data jadwal hari ini
  // ==========================================================
  Future<void> scheduleAllJadwals(List<JadwalNotifModel> jadwals) async {
    // Batalkan semua jadwal lama dulu
    await cancelAll();

    for (final jadwal in jadwals) {
      // Notif utama — waktu_minum
      if (jadwal.waktuMinum.isNotEmpty) {
        await scheduleJadwalNotification(
          notifId: jadwal.jadwalId,
          namaObat: jadwal.namaObat,
          dosis: jadwal.dosis,
          scheduledTime: jadwal.waktuMinum,
          jadwalId: jadwal.jadwalId,
        );
      }

      // Notif reminder pagi (ID offset +10000 agar tidak tabrakan)
      if (jadwal.waktuReminderPagi.isNotEmpty &&
          jadwal.waktuReminderPagi != jadwal.waktuMinum) {
        await scheduleJadwalNotification(
          notifId: jadwal.jadwalId + 10000,
          namaObat: '🔔 Reminder: ${jadwal.namaObat}',
          dosis: jadwal.dosis,
          scheduledTime: jadwal.waktuReminderPagi,
          jadwalId: jadwal.jadwalId,
        );
      }

      // Notif reminder malam (ID offset +20000)
      if (jadwal.waktuReminderMalam.isNotEmpty &&
          jadwal.waktuReminderMalam != jadwal.waktuMinum) {
        await scheduleJadwalNotification(
          notifId: jadwal.jadwalId + 20000,
          namaObat: '🌙 Reminder: ${jadwal.namaObat}',
          dosis: jadwal.dosis,
          scheduledTime: jadwal.waktuReminderMalam,
          jadwalId: jadwal.jadwalId,
        );
      }
    }

    debugPrint('[PilTime] Scheduled ${jadwals.length} jadwals total.');
  }

  // ==========================================================
  // BATALKAN notifikasi spesifik
  // ==========================================================
  Future<void> cancelJadwal(int jadwalId) async {
    // Batalkan seluruh alarm yang ter-generate dari jadwal yang sama.
    // Loop hingga 6 offset karena kita men-support maks 6 waktu per jadwal obat
    for (int i = 0; i <= 5; i++) {
      final offset = i * 1000;
      await _plugin.cancel(jadwalId + offset);         // waktu_minum
      await _plugin.cancel(jadwalId + 10000 + offset); // reminder_pagi
      await _plugin.cancel(jadwalId + 20000 + offset); // reminder_malam
    }
    debugPrint('[PilTime] Cancelled notifications for jadwal #$jadwalId');
  }

  // ==========================================================
  // BATALKAN SEMUA notifikasi (misalnya saat logout)
  // ==========================================================
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[PilTime] All notifications cancelled.');
  }

  // ==========================================================
  // TEST HELPER — Schedule notifikasi N detik dari sekarang
  // Gunakan untuk verifikasi pipeline notifikasi end-to-end.
  // Aman dihapus setelah testing selesai.
  // ==========================================================
  Future<void> scheduleTestNotification({
    required String namaObat,
    int delaySeconds = 5,
  }) async {
    if (!_initialized) await initialize();

    final location = tz.getLocation(_timezone);
    final scheduledTime = tz.TZDateTime.now(location)
        .add(Duration(seconds: delaySeconds));

    // Pola Getaran Agresif
    final Int64List vibrationPattern = Int64List.fromList([
      0, 1000, 500, 1000, 500, 1000, 500,
    ]);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      additionalFlags: Int32List.fromList(<int>[4]), // Insistent
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      99999, // ID khusus untuk test
      '🧪 [TEST] Pil Time — Alarm Berfungsi!',
      '💊 $namaObat — Notifikasi berhasil diterima',
      scheduledTime,
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test:$namaObat',
    );

    debugPrint(
        '[PilTime] Test notification scheduled in ${delaySeconds}s for: $namaObat');
  }

  // ==========================================================
  // TAMPILKAN NOTIFIKASI SEGERA (untuk test / konfirmasi)
  // ==========================================================
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID sementara
      title,
      body,
      notifDetails,
      payload: payload,
    );
  }

  // ==========================================================
  // COMPLIANCE CHECKER (Dart side)
  //
  // Menentukan status kepatuhan berdasarkan waktu konfirmasi minum
  // vs. scheduled_time dari backend.
  //
  // Kategori:
  //   "Diminum"  → 0 s/d +60 menit dari jadwal
  //   "Terlambat"→ > 60 menit s/d +75 menit (toleransi 15 menit)
  //   "Terlewat" → > 75 menit dari jadwal
  // ==========================================================
  static ComplianceStatus checkCompliance({
    required DateTime scheduledTime,
    required DateTime confirmationTime,
  }) {
    // Pastikan keduanya di-normalize ke timezone lokal
    final diff = confirmationTime.difference(scheduledTime);
    final minutes = diff.inMinutes;

    if (minutes < 0) {
      // Konfirmasi SEBELUM jadwal → anggap tepat waktu (minum lebih awal)
      return ComplianceStatus.diminum;
    } else if (minutes <= 60) {
      return ComplianceStatus.diminum;
    } else if (minutes <= 75) {
      return ComplianceStatus.terlambat;
    } else {
      return ComplianceStatus.terlewat;
    }
  }

  /// Versi string-based: scheduledTimeStr = "HH:MM", tanggal dari context saat ini.
  static ComplianceStatus checkComplianceFromString({
    required String scheduledTimeStr, // format "HH:MM"
    DateTime? confirmationTime,       // default = now
  }) {
    final now = confirmationTime ?? DateTime.now();
    final parts = scheduledTimeStr.split(':');
    if (parts.length != 2) return ComplianceStatus.terlewat;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    // Bangun scheduledTime di tanggal yang sama dengan konfirmasi
    final scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    return checkCompliance(
      scheduledTime: scheduled,
      confirmationTime: now,
    );
  }

  // ==========================================================
  // PRIVATE HELPERS
  // ==========================================================

  /// Bangun [TZDateTime] dari string "HH:MM" untuk hari ini (atau besok jika sudah lewat)
  tz.TZDateTime? _buildScheduledDate(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final location = tz.getLocation(_timezone);
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> _createNotificationChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[PilTime] Notification tapped: ${response.payload}');
    
    // Hentikan suara/getar yang sedang berlangsung
    // (Sebenarnya otomatis mati jika user tap notifikasi, tapi ini untuk pencegahan ekstra)
    if (response.id != null) {
      _plugin.cancel(response.id!);
    }

    if (response.payload != null) {
      // Navigasi ke AlarmRingingScreen melalui Global Navigator
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingingScreen(payload: response.payload!),
        ),
      );
    }
  }
}

// ============================================================
// MODEL HELPER untuk scheduleAllJadwals
// ============================================================
class JadwalNotifModel {
  final int jadwalId;
  final String namaObat;
  final String dosis;           // "2 tablet"
  final String waktuMinum;      // "HH:MM"
  final String waktuReminderPagi;
  final String waktuReminderMalam;

  const JadwalNotifModel({
    required this.jadwalId,
    required this.namaObat,
    required this.dosis,
    required this.waktuMinum,
    this.waktuReminderPagi = '',
    this.waktuReminderMalam = '',
  });
}

// ============================================================
// ENUM STATUS KEPATUHAN
// Sesuai dengan kolom status di tabel tracking_jadwal backend
// ============================================================
enum ComplianceStatus {
  diminum,    // Tepat waktu (0–60 menit)
  terlambat,  // Terlambat   (61–75 menit)
  terlewat;   // Terlewat    (>75 menit)

  /// String yang dikirim ke backend sesuai enum domain/model Go
  String get backendValue {
    switch (this) {
      case ComplianceStatus.diminum:
        return 'Diminum';
      case ComplianceStatus.terlambat:
        return 'Terlambat';
      case ComplianceStatus.terlewat:
        return 'Terlewat';
    }
  }

  String get label {
    switch (this) {
      case ComplianceStatus.diminum:
        return 'Tepat Waktu ✅';
      case ComplianceStatus.terlambat:
        return 'Terlambat ⚠️';
      case ComplianceStatus.terlewat:
        return 'Terlewat ❌';
    }
  }

  Color get color {
    switch (this) {
      case ComplianceStatus.diminum:
        return const Color(0xFF2BB673);
      case ComplianceStatus.terlambat:
        return const Color(0xFFF59E0B);
      case ComplianceStatus.terlewat:
        return const Color(0xFFEF4444);
    }
  }
}
