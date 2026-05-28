import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../screens/alarm/alarm_ringing_screen.dart';
import '../screens/notifikasi/notifikasi_screen.dart';

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

  // ── Timer auto-show alarm (Dart side) ─────────────────────
  // Key: notifId, Value: Timer yang akan otomatis tampilkan AlarmRingingScreen
  final Map<int, Timer> _pendingAlarmTimers = {};



  // ── Konstanta Channel Android ──────────────────────────────
  static const String _channelId = 'pil_time_alarm_custom';
  static const String _channelName = 'Alarm Minum Obat';
  static const String _channelDesc =
      'Notifikasi pengingat jadwal minum obat Pil Time';

  static const String _reminderChannelId = 'pil_time_reminders';
  static const String _reminderChannelName = 'Pengingat Obat';
  static const String _reminderChannelDesc =
      'Notifikasi pengingat biasa sebelum minum obat Pil Time';

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
        sound: const RawResourceAndroidNotificationSound('alarm_voice'),
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        styleInformation: const BigTextStyleInformation(''),
        icon: 'ic_notification',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_voice.mp3',
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

      // ── Auto-show alarm screen dari Dart side (tanpa tap notifikasi) ──
      // Alur: notifikasi muncul → langsung buka AlarmRingingScreen secara otomatis
      final now = tz.TZDateTime.now(tz.getLocation(_timezone));
      final delayUntilAlarmMs = scheduledTZ.difference(now).inMilliseconds;
      if (delayUntilAlarmMs > 0) {
        _pendingAlarmTimers[currentNotifId]?.cancel();
        _pendingAlarmTimers[currentNotifId] = Timer(
          Duration(milliseconds: delayUntilAlarmMs),
          () {
            debugPrint('[PilTime] Auto-show alarm secara instan (timer #$currentNotifId)');
            showAlarmScreen('$jadwalId:$namaObat');
          },
        );
        debugPrint(
            '[PilTime] Auto-open timer: ${delayUntilAlarmMs}ms (instan)');
      }
    }
  }

  // ==========================================================
  // SCHEDULE ADVANCE NOTIFICATION — 15 menit sebelum waktu minum
  // (Hanya berupa notifikasi biasa, bukan alarm ringing screen)
  // ==========================================================
  Future<void> scheduleAdvanceNotification({
    required int notifId,
    required String namaObat,
    required String dosis,
    required String scheduledTime, // "HH:MM"
    required String originalTime,  // "HH:MM"
    required int jadwalId,
  }) async {
    if (!_initialized) await initialize();

    final scheduledTZ = _buildScheduledDate(scheduledTime);
    if (scheduledTZ == null) {
      debugPrint('[PilTime] Invalid advance time format: $scheduledTime');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(''),
      icon: 'ic_notification',
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
      notifId,
      '🔔 Siapkan Obat: $namaObat',
      'Siapkan obat ini ($dosis). Waktu minum: $originalTime',
      scheduledTZ,
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reminder:$jadwalId:$namaObat',
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
        '[PilTime] Scheduled advance notification #$notifId for $namaObat at $scheduledTime (WIB)');
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

        // Pengingat 15 menit sebelum (Hanya berupa notifikasi biasa, ID offset +30000)
        final timeList = jadwal.waktuMinum
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        for (int i = 0; i < timeList.length; i++) {
          final timeStr = timeList[i];
          final advanceTimeStr = _subtract15Minutes(timeStr);
          if (advanceTimeStr != null) {
            final currentNotifId = jadwal.jadwalId + 30000 + (i * 1000);
            await scheduleAdvanceNotification(
              notifId: currentNotifId,
              namaObat: jadwal.namaObat,
              dosis: jadwal.dosis,
              scheduledTime: advanceTimeStr,
              originalTime: timeStr,
              jadwalId: jadwal.jadwalId,
            );
          }
        }
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
      await _plugin.cancel(jadwalId + 30000 + offset); // advance_reminder

      // Batalkan Dart-side timer juga
      _pendingAlarmTimers.remove(jadwalId + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 10000 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 20000 + offset)?.cancel();
    }
    debugPrint('[PilTime] Cancelled notifications for jadwal #$jadwalId');
  }

  // ==========================================================
  // BATALKAN SEMUA notifikasi (misalnya saat logout)
  // ==========================================================
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    // Batalkan semua Dart-side timer
    for (final timer in _pendingAlarmTimers.values) {
      timer.cancel();
    }
    _pendingAlarmTimers.clear();
    debugPrint('[PilTime] All notifications and timers cancelled.');
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
      sound: const RawResourceAndroidNotificationSound('alarm_voice'),
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      icon: 'ic_notification',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_voice.mp3',
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

    // ── Auto-show alarm screen secara instan setelah delay berakhir ──
    final autoOpenMs = delaySeconds * 1000;
    _pendingAlarmTimers[99999]?.cancel();
    _pendingAlarmTimers[99999] = Timer(
      Duration(milliseconds: autoOpenMs),
      () {
        debugPrint('[PilTime] Auto-show test alarm secara instan (${autoOpenMs}ms)');
        showAlarmScreen('99999:$namaObat');
      },
    );
    debugPrint(
        '[PilTime] Test alarm: notif T+${delaySeconds}s, screen T+${autoOpenMs}ms (instan)');
  }

  // ==========================================================
  // TEST HELPER — Schedule notifikasi pengingat biasa (15m sebelum) N detik dari sekarang
  // ==========================================================
  Future<void> scheduleTestReminderNotification({
    required String namaObat,
    int delaySeconds = 3,
  }) async {
    if (!_initialized) await initialize();

    final location = tz.getLocation(_timezone);
    final scheduledTime = tz.TZDateTime.now(location)
        .add(Duration(seconds: delaySeconds));

    final androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'ic_notification',
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
      88888, // ID khusus untuk test reminder
      '🔔 Siapkan Obat: $namaObat',
      'Siapkan obat ini. Waktu minum: Waktu Jadwal',
      scheduledTime,
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reminder:88888:$namaObat',
    );

    debugPrint(
        '[PilTime] Test reminder notification scheduled in ${delaySeconds}s for: $namaObat');
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
      icon: 'ic_notification',
      sound: RawResourceAndroidNotificationSound('alarm_voice'),
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_voice.mp3',
      ),
    );

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

  /// Kurangi waktu "HH:MM" sebanyak 15 menit
  String? _subtract15Minutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      minute -= 15;
      if (minute < 0) {
        minute += 60;
        hour -= 1;
        if (hour < 0) hour = 23;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

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

    // 1. Channel Alarm Kustom (Minum Obat) dengan suara kustom
    const alarmChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_voice'),
    );

    // 2. Channel Pengingat Biasa dengan suara default sistem
    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(reminderChannel);
    }
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

  Future<bool> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      return true;
    }
    return true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[PilTime] Notification tapped: ${response.payload}');
    
    if (response.id != null) {
      _plugin.cancel(response.id!);
    }

    if (response.payload != null) {
      final payload = response.payload!;
      if (payload.startsWith('reminder:')) {
        showNotificationScreen(payload: payload);
      } else {
        showAlarmScreen(payload);
      }
    }
  }

  void showNotificationScreen({String? payload}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('[PilTime] Navigator belum siap, notification screen tidak bisa ditampilkan.');
      return;
    }

    // Parse payload untuk membuat mock item yang tampil di daftar
    NotificationItem? mockItem;
    if (payload != null && payload.startsWith('reminder:')) {
      try {
        // Format: reminder:jadwalId:namaObat
        final withoutPrefix = payload.substring('reminder:'.length);
        final parts = withoutPrefix.split(':');
        final namaObat = parts.length > 1 ? parts.sublist(1).join(':') : 'Obat';
        final now = DateTime.now();
        final timeStr =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        mockItem = NotificationItem(
          title: namaObat,
          desc: 'Siapkan obat ini. Waktu minum segera tiba.',
          time: timeStr,
          type: NotificationType.mendatang,
          isAdvanceReminder: true,
        );
      } catch (_) {}
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => NotificationScreen(mockItem: mockItem),
      ),
    );
    debugPrint('[PilTime] NotificationScreen ditampilkan dari tap pengingat.');
  }

  // ==========================================================
  // TAMPILKAN ALARM RINGING SCREEN SECARA LANGSUNG
  // Dipanggil dari: _onNotificationTapped (tap notif),
  //                 FCM foreground handler,
  //                 atau main.dart saat app dibuka via notif.
  // ==========================================================
  void showAlarmScreen(String payload) {
    // Batalkan notifikasi terkait secara instan agar suaranya mati saat layar alarm terbuka
    try {
      final parts = payload.split(':');
      if (parts.isNotEmpty) {
        final idStr = parts[0];
        if (idStr == 'test') {
          _plugin.cancel(99999);
        } else {
          final id = int.tryParse(idStr);
          if (id != null) {
            // Batalkan semua kemungkinan offset notifikasi untuk jadwal ini
            for (int i = 0; i <= 5; i++) {
              _plugin.cancel(id + (i * 1000));
              _plugin.cancel(id + 10000 + (i * 1000));
              _plugin.cancel(id + 20000 + (i * 1000));
            }
            if (id == 99999) {
              _plugin.cancel(99999);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[PilTime] Gagal membatalkan notifikasi di showAlarmScreen: $e');
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('[PilTime] Navigator belum siap, alarm screen tidak bisa ditampilkan.');
      return;
    }

    // Pastikan tidak menduplikat AlarmRingingScreen yang sudah tampil
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AlarmRingingScreen(payload: payload),
        settings: const RouteSettings(name: '/alarm-ringing'),
      ),
      // Pertahankan semua route di bawahnya (bukan replace semuanya)
      // Kita hanya ingin memastikan AlarmRingingScreen paling atas
      (route) => route.settings.name != '/alarm-ringing',
    );

    debugPrint('[PilTime] AlarmRingingScreen ditampilkan untuk payload: $payload');
  }

  // ==========================================================
  // CEK APAKAH APP DIBUKA DARI NOTIFIKASI (Terminated State)
  // Panggil ini di main.dart setelah NotificationService.initialize()
  // ==========================================================
  Future<void> checkLaunchFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details != null &&
        details.didNotificationLaunchApp &&
        details.notificationResponse?.payload != null) {
      final payload = details.notificationResponse!.payload!;
      debugPrint('[PilTime] App diluncurkan dari notifikasi, payload: $payload');
      // Delay singkat agar Navigator sudah siap
      await Future.delayed(const Duration(milliseconds: 500));
      if (payload.startsWith('reminder:')) {
        showNotificationScreen(payload: payload);
      } else {
        showAlarmScreen(payload);
      }
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
