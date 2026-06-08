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
/// Dipanggil saat user men-tap notifikasi ketika app ada di background (bukan killed).
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  debugPrint('[PilTime] Background notification tapped: ${response.payload}');
  final payload = response.payload;
  if (payload != null && payload.isNotEmpty) {
    if (payload.startsWith('reminder:')) {
      NotificationService.instance.showNotificationScreen(payload: payload);
    } else {
      NotificationService.instance.showAlarmScreen(payload);
    }
  }
}

class NotificationService {
  // ── Singleton ──────────────────────────────────────────────
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Flag: true ketika AlarmRingingScreen sedang aktif di foreground.
  /// Digunakan untuk meng-silent semua notifikasi baru agar tidak mengganggu
  /// layar alarm yang sedang berjalan.
  bool isAlarmScreenActive = false;
  int activeAlarmScreensCount = 0;

  /// Antrean payload alarm jika ada alarm yang berbunyi saat layar alarm lain sedang aktif
  final List<String> _alarmQueue = [];

  // ── Timer auto-show alarm (Dart side) ─────────────────────
  // Key: notifId, Value: Timer yang akan otomatis tampilkan AlarmRingingScreen
  final Map<int, Timer> _pendingAlarmTimers = {};



  // ── Konstanta Channel Android ──────────────────────────────
  static const String _channelId = 'pil_time_alarm_v4';
  static const String _channelName = 'Alarm Minum Obat';
  static const String _channelDesc =
      'Notifikasi pengingat jadwal minum obat Pil Time';

  static const String _reminderChannelId = 'pil_time_reminders';
  static const String _reminderChannelName = 'Pengingat Obat';
  static const String _reminderChannelDesc =
      'Notifikasi pengingat biasa sebelum minum obat Pil Time';

  // Channel khusus alarm rutinitas sehat (suara berbeda dari alarm obat)
  // Gunakan v3 agar Android membuat channel baru dengan setting silent
  static const String _rutinitasChannelId = 'pil_time_rutinitas_v3';
  static const String _rutinitasChannelName = 'Pengingat Rutinitas Sehat';
  static const String _rutinitasChannelDesc =
      'Notifikasi pengingat jadwal rutinitas/aktivitas sehat Pil Time';

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
    try {
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
          playSound: false,
          enableVibration: false,
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

        // 1. Jadwalkan Alarm Utama (Initial)
        await _plugin.zonedSchedule(
          currentNotifId,
          '💊 Waktunya Minum Obat!',
          '$namaObat — $dosis',
          scheduledTZ,
          notifDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$jadwalId:$namaObat:$timeStr',
          matchDateTimeComponents: DateTimeComponents.time, // Repeat harian
        );

        debugPrint(
            '[PilTime] Scheduled alarm #$currentNotifId for $namaObat at $timeStr (WIB)');

        // 2. Jadwalkan Snooze 1 (+20 Menit)
        final snooze1TZ = scheduledTZ.add(const Duration(minutes: 20));
        await _plugin.zonedSchedule(
          currentNotifId + 100,
          '💊 Pengingat Kedua (Snooze): Waktunya Minum Obat!',
          '$namaObat — $dosis (Sudah lewat 20 menit)',
          snooze1TZ,
          notifDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$jadwalId:$namaObat:$timeStr',
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
            '[PilTime] Scheduled Snooze 1 #${currentNotifId + 100} for $namaObat at ${snooze1TZ.hour}:${snooze1TZ.minute} (WIB)');

        // 3. Jadwalkan Snooze 2 (+40 Menit)
        final snooze2TZ = scheduledTZ.add(const Duration(minutes: 40));
        await _plugin.zonedSchedule(
          currentNotifId + 200,
          '💊 Pengingat Ketiga (Snooze): Waktunya Minum Obat!',
          '$namaObat — $dosis (Sudah lewat 40 menit)',
          snooze2TZ,
          notifDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$jadwalId:$namaObat:$timeStr',
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
            '[PilTime] Scheduled Snooze 2 #${currentNotifId + 200} for $namaObat at ${snooze2TZ.hour}:${snooze2TZ.minute} (WIB)');

        // 4. Jadwalkan Warning Terlambat (+60 Menit) - Batas Akhir Kategori Tepat Waktu
        final terlambatTZ = scheduledTZ.add(const Duration(minutes: 60));
        final Int64List urgentVibrationPattern = Int64List.fromList([
          0, 1500, 300, 1500, 300, 1500, 300, 1500,
        ]);
        final urgentAndroidDetails = AndroidNotificationDetails(
          _channelId,
          'Alarm Sangat Penting (Terlambat)',
          channelDescription: 'Notifikasi peringatan keterlambatan minum obat',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          playSound: false,
          enableVibration: false,
          styleInformation: const BigTextStyleInformation(''),
          icon: 'ic_notification',
        );
        final urgentNotifDetails = NotificationDetails(
          android: urgentAndroidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'alarm_voice.mp3',
          ),
        );

        await _plugin.zonedSchedule(
          currentNotifId + 300,
          '⚠️ Status Terlambat: Segera Minum $namaObat!',
          'Sudah terlambat 60 menit! Segera minum sebelum status berubah menjadi Terlewat (15 menit lagi)!',
          terlambatTZ,
          urgentNotifDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$jadwalId:$namaObat:$timeStr',
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
            '[PilTime] Scheduled Terlambat Warning #${currentNotifId + 300} for $namaObat at ${terlambatTZ.hour}:${terlambatTZ.minute} (WIB)');

        // ── Auto-show alarm screen dari Dart side (tanpa tap notifikasi) ──
        // Alur: notifikasi muncul → langsung buka AlarmRingingScreen secara otomatis
        final now = tz.TZDateTime.now(tz.getLocation(_timezone));
        
        // Auto-show untuk Alarm Utama
        final delayUntilAlarmMs = scheduledTZ.difference(now).inMilliseconds;
        if (delayUntilAlarmMs > 0) {
          _pendingAlarmTimers[currentNotifId]?.cancel();
          _pendingAlarmTimers[currentNotifId] = Timer(
            Duration(milliseconds: delayUntilAlarmMs),
            () {
              debugPrint('[PilTime] Auto-show alarm secara instan (timer #$currentNotifId)');
              showAlarmScreen('$jadwalId:$namaObat:$timeStr');
            },
          );
        }

        // Auto-show untuk Snooze 1 (+20 Menit)
        final delayUntilSnooze1Ms = snooze1TZ.difference(now).inMilliseconds;
        if (delayUntilSnooze1Ms > 0) {
          _pendingAlarmTimers[currentNotifId + 100]?.cancel();
          _pendingAlarmTimers[currentNotifId + 100] = Timer(
            Duration(milliseconds: delayUntilSnooze1Ms),
            () {
              debugPrint('[PilTime] Auto-show Snooze 1 secara instan (timer #${currentNotifId + 100})');
              showAlarmScreen('$jadwalId:$namaObat:$timeStr');
            },
          );
        }

        // Auto-show untuk Snooze 2 (+40 Menit)
        final delayUntilSnooze2Ms = snooze2TZ.difference(now).inMilliseconds;
        if (delayUntilSnooze2Ms > 0) {
          _pendingAlarmTimers[currentNotifId + 200]?.cancel();
          _pendingAlarmTimers[currentNotifId + 200] = Timer(
            Duration(milliseconds: delayUntilSnooze2Ms),
            () {
              debugPrint('[PilTime] Auto-show Snooze 2 secara instan (timer #${currentNotifId + 200})');
              showAlarmScreen('$jadwalId:$namaObat:$timeStr');
            },
          );
        }

        // Auto-show untuk Warning Terlambat (+60 Menit)
        final delayUntilTerlambatMs = terlambatTZ.difference(now).inMilliseconds;
        if (delayUntilTerlambatMs > 0) {
          _pendingAlarmTimers[currentNotifId + 300]?.cancel();
          _pendingAlarmTimers[currentNotifId + 300] = Timer(
            Duration(milliseconds: delayUntilTerlambatMs),
            () {
              debugPrint('[PilTime] Auto-show Warning Terlambat secara instan (timer #${currentNotifId + 300})');
              showAlarmScreen('$jadwalId:$namaObat:$timeStr');
            },
          );
        }
      }
    } catch (e) {
      debugPrint('[PilTime] Error scheduling jadwal notification: $e');
    }
  }

  // ==========================================================
  // SCHEDULE RUTINITAS ALARM — Rutinitas sehat pasien
  // ==========================================================
  Future<void> scheduleRutinitasNotification({
    required int notifId,
    required String namaRutinitas,
    required String waktuReminder,
    required int rutinitasId,
    required String deskripsi,
    bool startFromTomorrow = false,
  }) async {
    try {
      if (!_initialized) await initialize();

      // Bersihkan waktu dari detik jika ada (misal: "08:00:00" -> "08:00")
      var cleanWaktu = waktuReminder.trim();
      final timeParts = cleanWaktu.split(':');
      if (timeParts.length > 2) {
        cleanWaktu = '${timeParts[0]}:${timeParts[1]}';
      }

      final scheduledTZ = _buildScheduledDate(cleanWaktu, startFromTomorrow: startFromTomorrow);
      if (scheduledTZ == null) {
        debugPrint('[PilTime] Invalid routine time format: $waktuReminder (clean: $cleanWaktu)');
        return;
      }

      // ID unik untuk rutinitas (offset 100000)
      final routineNotifId = notifId + 100000;

      // Rutinitas: notifikasi SILENT di sisi Android karena suaranya dihandle
      // sepenuhnya oleh Dart (FlutterRingtonePlayer di AlarmRingingScreen).
      // fullScreenIntent WAJIB true agar bisa membangunkan layar (wake lock).
      // Karena Importance.max, notifikasi akan popup heads-up (namun akan segera
      // dihapus/cancel oleh Dart saat AlarmRingingScreen terbuka).
      final androidDetails = AndroidNotificationDetails(
        _rutinitasChannelId,
        _rutinitasChannelName,
        channelDescription: _rutinitasChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        ongoing: false,
        playSound: false,             // ← Suara dihandle Dart, bukan Android
        enableVibration: false,       // ← Hindari tabrakan getaran
        styleInformation: BigTextStyleInformation(
          deskripsi.isNotEmpty ? deskripsi : 'Saatnya melakukan rutinitas sehat Anda!',
        ),
        icon: 'ic_notification',
      );

      // iOS: silent juga untuk rutinitas (suara diputar via FlutterRingtonePlayer)
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        presentSound: false, // ← Silent di iOS juga
      );

      final notifDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        routineNotifId,
        '🏃 Waktunya Aktivitas Sehat!',
        deskripsi.isNotEmpty
            ? '$namaRutinitas — $deskripsi'
            : 'Jangan lupa: $namaRutinitas',
        scheduledTZ,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'routine:$rutinitasId:$namaRutinitas:$cleanWaktu',
        matchDateTimeComponents: DateTimeComponents.time, // Repeat harian
      );

      debugPrint(
          '[PilTime] Scheduled routine alarm #$routineNotifId for $namaRutinitas at $cleanWaktu (WIB)');

      // ── Auto-show alarm screen dari Dart side (tanpa tap notifikasi) ──
      final now = tz.TZDateTime.now(tz.getLocation(_timezone));
      final delayUntilAlarmMs = scheduledTZ.difference(now).inMilliseconds;
      if (delayUntilAlarmMs > 0) {
        _pendingAlarmTimers[routineNotifId]?.cancel();
        _pendingAlarmTimers[routineNotifId] = Timer(
          Duration(milliseconds: delayUntilAlarmMs),
          () {
            debugPrint('[PilTime] Auto-show routine alarm secara instan (timer #$routineNotifId)');
            showAlarmScreen('routine:$rutinitasId:$namaRutinitas:$cleanWaktu');
          },
        );
      }
    } catch (e) {
      debugPrint('[PilTime] Error scheduling rutinitas notification: $e');
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
    try {
      if (!_initialized) await initialize();

      final scheduledTZ = _buildScheduledDate(scheduledTime);
      if (scheduledTZ == null) {
        debugPrint('[PilTime] Invalid advance time format: $scheduledTime');
        return;
      }

      // Jika AlarmRingingScreen sedang aktif, jadwalkan pengingat ini sebagai silent
      // agar tidak muncul sebagai pop-up yang mengganggu layar alarm.
      final suppressPopup = isAlarmScreenActive;

      final androidDetails = AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: _reminderChannelDesc,
        importance: suppressPopup ? Importance.low : Importance.high,
        priority: suppressPopup ? Priority.low : Priority.high,
        playSound: !suppressPopup,
        enableVibration: !suppressPopup,
        styleInformation: const BigTextStyleInformation(''),
        icon: 'ic_notification',
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: !suppressPopup,
        presentBadge: true,
        presentSound: !suppressPopup,
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
        payload: 'reminder:$jadwalId:$originalTime:$dosis:$namaObat',
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
          '[PilTime] Scheduled advance notification #$notifId for $namaObat at $scheduledTime (WIB)${suppressPopup ? " [silent — AlarmScreen aktif]" : ""}');
    } catch (e) {
      debugPrint('[PilTime] Error scheduling advance notification: $e');
    }
  }


  // ==========================================================
  // SCHEDULE BANYAK JADWAL SEKALIGUS
  // Dipanggil dari dashboard setelah fetch data jadwal hari ini
  // ==========================================================
  Future<void> scheduleAllJadwals(List<JadwalNotifModel> jadwals) async {
    // Batalkan semua jadwal lama dulu
    await cancelAllMedicineAlarms();

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
      await _plugin.cancel(jadwalId + 100 + offset);   // Snooze 1
      await _plugin.cancel(jadwalId + 200 + offset);   // Snooze 2
      await _plugin.cancel(jadwalId + 300 + offset);   // Warning Terlambat
      await _plugin.cancel(jadwalId + 10000 + offset); // reminder_pagi
      await _plugin.cancel(jadwalId + 20000 + offset); // reminder_malam
      await _plugin.cancel(jadwalId + 30000 + offset); // advance_reminder

      // Batalkan Dart-side timer juga
      _pendingAlarmTimers.remove(jadwalId + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 100 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 200 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 300 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 10000 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 20000 + offset)?.cancel();
    }
    debugPrint('[PilTime] Cancelled notifications for jadwal #$jadwalId');
  }

  // ==========================================================
  // BATALKAN SNOOZE ALARM saja (saat alarm dimatikan manual)
  // ==========================================================
  Future<void> cancelSnoozesForJadwal(int jadwalId) async {
    for (int i = 0; i <= 5; i++) {
      final offset = i * 1000;
      await _plugin.cancel(jadwalId + 100 + offset); // Snooze 1
      await _plugin.cancel(jadwalId + 200 + offset); // Snooze 2
      await _plugin.cancel(jadwalId + 300 + offset); // Warning Terlambat

      // Batalkan Dart-side timer juga
      _pendingAlarmTimers.remove(jadwalId + 100 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 200 + offset)?.cancel();
      _pendingAlarmTimers.remove(jadwalId + 300 + offset)?.cancel();
    }
    debugPrint('[PilTime] Cancelled snooze alarms for jadwal #$jadwalId');
  }

  // ==========================================================
  // BATALKAN alarm rutinitas spesifik
  // ==========================================================
  Future<void> cancelRutinitas(int rutinitasId) async {
    final routineNotifId = rutinitasId + 100000;
    await _plugin.cancel(routineNotifId);
    _pendingAlarmTimers.remove(routineNotifId)?.cancel();
    debugPrint('[PilTime] Cancelled routine notification #$routineNotifId');
  }

  // ==========================================================
  // BATALKAN SEMUA alarm rutinitas
  // ==========================================================
  Future<void> cancelAllRoutineAlarms() async {
    try {
      final pendingRequests = await _plugin.pendingNotificationRequests();
      for (final request in pendingRequests) {
        if (request.id >= 100000) {
          await _plugin.cancel(request.id);
          _pendingAlarmTimers.remove(request.id)?.cancel();
        }
      }
      debugPrint('[PilTime] All routine notifications and timers cancelled.');
    } catch (e) {
      debugPrint('[PilTime] Error cancelling routine notifications: $e');
    }
  }

  // ==========================================================
  // BATALKAN SEMUA alarm obat
  // ==========================================================
  Future<void> cancelAllMedicineAlarms() async {
    try {
      final pendingRequests = await _plugin.pendingNotificationRequests();
      for (final request in pendingRequests) {
        if (request.id < 100000) {
          await _plugin.cancel(request.id);
          _pendingAlarmTimers.remove(request.id)?.cancel();
        }
      }
      debugPrint('[PilTime] All medicine notifications and timers cancelled.');
    } catch (e) {
      debugPrint('[PilTime] Error cancelling medicine notifications: $e');
    }
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
    try {
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
        playSound: false,
        enableVibration: false,
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
    } catch (e) {
      debugPrint('[PilTime] ERROR in scheduleTestNotification: $e');
      final navigator = navigatorKey.currentState;
      if (navigator != null && navigator.context.mounted) {
        showDialog(
          context: navigator.context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error Test Alarm'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
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
    bool isAlarm = false,
  }) async {
    if (!_initialized) await initialize();

    // Jika AlarmRingingScreen aktif, tampilkan notifikasi secara silent
    // agar tidak ada pop-up yang mengganggu layar alarm yang sedang berjalan.
    final suppressPopup = isAlarmScreenActive;

    final androidDetails = AndroidNotificationDetails(
      isAlarm ? _channelId : _reminderChannelId,
      isAlarm ? _channelName : _reminderChannelName,
      channelDescription: isAlarm ? _channelDesc : _reminderChannelDesc,
      importance: suppressPopup ? Importance.low : Importance.high,
      priority: suppressPopup ? Priority.low : Priority.high,
      icon: 'ic_notification',
      playSound: !suppressPopup && !isAlarm,
    );

    final notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: !suppressPopup,
        presentBadge: true,
        presentSound: !suppressPopup,
        sound: (!suppressPopup && isAlarm) ? 'alarm_voice.mp3' : null,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID sementara
      title,
      body,
      notifDetails,
      payload: payload,
    );

    if (suppressPopup) {
      debugPrint('[PilTime] showImmediateNotification: silent mode (AlarmScreen aktif)');
    }
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
    final times = scheduledTimeStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (times.isEmpty) return ComplianceStatus.terlewat;

    ComplianceStatus bestStatus = ComplianceStatus.terlewat;
    int minAbsDiff = 999999;

    for (final timeStr in times) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      
      final diff = now.difference(scheduled).inMinutes;
      final absDiff = diff.abs();
      
      if (absDiff < minAbsDiff) {
        minAbsDiff = absDiff;
        bestStatus = checkCompliance(scheduledTime: scheduled, confirmationTime: now);
      }
    }

    return bestStatus;
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
  tz.TZDateTime? _buildScheduledDate(String timeStr, {bool startFromTomorrow = false}) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
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

    if (startFromTomorrow) {
      scheduled = scheduled.add(const Duration(days: 1));
    } else {
      // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
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
      enableVibration: false,
      playSound: false,
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

    // 3. Channel Alarm Rutinitas Sehat — importance max (untuk full-screen)
    // Suara: SILENT (playSound: false). Dart side yang akan handle suara kustom.
    const rutinitasChannel = AndroidNotificationChannel(
      _rutinitasChannelId,
      _rutinitasChannelName,
      description: _rutinitasChannelDesc,
      importance: Importance.max,
      enableVibration: false,
      playSound: false,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(reminderChannel);
      await androidPlugin.createNotificationChannel(rutinitasChannel);
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
        final jadwalId = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
        
        final now = DateTime.now();
        String timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        String namaObat = 'Obat';
        String desc = 'Siapkan obat ini. Waktu minum segera tiba.';

        // Cek format baru: reminder:jadwalId:HH:MM:dosis:namaObat
        if (parts.length >= 5 && parts[1].length == 2 && parts[2].length == 2 && int.tryParse(parts[1]) != null) {
          final originalTime = '${parts[1]}:${parts[2]}';
          final dosis = parts[3];
          namaObat = parts.sublist(4).join(':');
          timeStr = originalTime; // Tampilkan waktu jadwal sebenarnya
          desc = 'Siapkan obat ini ($dosis). Waktu minum: $originalTime';
        } else if (parts.length > 1) {
          namaObat = parts.sublist(1).join(':');
        }

        mockItem = NotificationItem(
          title: namaObat,
          desc: desc,
          time: timeStr,
          type: NotificationType.mendatang,
          jadwalId: jadwalId,
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
    _cancelNotificationForPayload(payload);

    if (isAlarmScreenActive) {
      debugPrint('[PilTime] AlarmRingingScreen sedang aktif. Memasukkan ke antrean: $payload');
      _alarmQueue.add(payload);
      return;
    }

    isAlarmScreenActive = true;

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

  /// Dipanggil dari `AlarmRingingScreen` ketika layar ditutup (dimatikan)
  /// Mengembalikan payload alarm selanjutnya, atau null jika antrean kosong.
  String? showNextAlarm() {
    if (_alarmQueue.isNotEmpty) {
      final nextPayload = _alarmQueue.removeAt(0);
      debugPrint('[PilTime] Menampilkan alarm dari antrean: $nextPayload');
      return nextPayload;
    }
    return null;
  }

  void _cancelNotificationForPayload(String payload) {
    try {
      final parts = payload.split(':');
      if (parts.isNotEmpty) {
        final idStr = parts[0];
        if (idStr == 'test') {
          _plugin.cancel(99999);
        } else if (payload.startsWith('routine:')) {
          final id = int.tryParse(parts[1]);
          if (id != null) {
            _plugin.cancel(id + 100000);
            _pendingAlarmTimers.remove(id + 100000)?.cancel();
          }
        } else {
          final id = int.tryParse(idStr);
          if (id != null) {
            // Batalkan semua kemungkinan offset notifikasi untuk jadwal ini
            for (int i = 0; i <= 5; i++) {
              final offset = i * 1000;
              _plugin.cancel(id + offset);
              _plugin.cancel(id + 100 + offset);
              _plugin.cancel(id + 200 + offset);
              _plugin.cancel(id + 300 + offset);
              _plugin.cancel(id + 10000 + offset);
              _plugin.cancel(id + 20000 + offset);
              _plugin.cancel(id + 30000 + offset);
            }
            if (id == 99999) {
              _plugin.cancel(99999);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[PilTime] Gagal membatalkan notifikasi di _cancelNotificationForPayload: $e');
    }
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

      // Tunggu Navigator benar-benar siap (retry tiap 300ms, maks 6 detik)
      // Lebih andal dari fixed delay karena cold-start bisa lambat
      int attempt = 0;
      while (navigatorKey.currentState == null && attempt < 20) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempt++;
      }

      if (navigatorKey.currentState == null) {
        debugPrint('[PilTime] Navigator tidak siap setelah 6 detik, alarm screen dibatalkan.');
        return;
      }

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
