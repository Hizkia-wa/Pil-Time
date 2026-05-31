import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFcmNotification {
  final String id;
  final String title;
  final String desc;
  final String time;
  final String type; // 'mendatang', 'terlewat', 'rutinitas', 'info'
  final int? jadwalId;
  final String? aturan;
  final DateTime savedAt; // kapan notifikasi ini disimpan

  LocalFcmNotification({
    required this.id,
    required this.title,
    required this.desc,
    required this.time,
    required this.type,
    this.jadwalId,
    this.aturan,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'desc': desc,
        'time': time,
        'type': type,
        'jadwalId': jadwalId,
        'aturan': aturan,
        'savedAt': savedAt.toIso8601String(),
      };

  factory LocalFcmNotification.fromJson(Map<String, dynamic> json) =>
      LocalFcmNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        desc: json['desc'] as String,
        time: json['time'] as String,
        type: json['type'] as String,
        jadwalId: json['jadwalId'] as int?,
        aturan: json['aturan'] as String?,
        // Notifikasi lama tanpa savedAt dianggap sudah kadaluarsa
        savedAt: json['savedAt'] != null
            ? DateTime.tryParse(json['savedAt'] as String) ?? DateTime(2000)
            : DateTime(2000),
      );
}

class NotificationStorageService {
  NotificationStorageService._();
  static final NotificationStorageService instance = NotificationStorageService._();

  static const String _fcmNotifsKey = 'local_fcm_notifications';
  static const String _readNotifKeysKey = 'read_notification_keys';

  /// Menghapus notifikasi FCM yang lebih dari [maxAgeHours] jam dari storage
  Future<void> cleanupOldFcmNotifications({int maxAgeHours = 24}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_fcmNotifsKey) ?? [];
      final cutoff = DateTime.now().subtract(Duration(hours: maxAgeHours));

      final filtered = listJson.where((s) {
        try {
          final notif = LocalFcmNotification.fromJson(
            jsonDecode(s) as Map<String, dynamic>,
          );
          return notif.savedAt.isAfter(cutoff);
        } catch (_) {
          return false; // data corrupt → buang
        }
      }).toList();

      await prefs.setStringList(_fcmNotifsKey, filtered);
    } catch (_) {}
  }

  Future<List<LocalFcmNotification>> getSavedFcmNotifications() async {
    try {
      // Bersihkan notifikasi lama sebelum membaca agar tidak muncul lagi
      await cleanupOldFcmNotifications();

      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_fcmNotifsKey) ?? [];
      return listJson
          .map((s) => LocalFcmNotification.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFcmNotification(LocalFcmNotification notif) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifs = await getSavedFcmNotifications();
      // Hapus jika duplikat
      notifs.removeWhere((item) => item.id == notif.id);
      notifs.insert(0, notif);
      
      final listJson = notifs.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_fcmNotifsKey, listJson);
    } catch (_) {}
  }

  Future<Set<String>> getReadKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_readNotifKeysKey) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markKeyAsRead(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = await getReadKeys();
      keys.add(key);
      await prefs.setStringList(_readNotifKeysKey, keys.toList());
    } catch (_) {}
  }

  Future<void> markAllAsRead(List<String> keysToMark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = await getReadKeys();
      keys.addAll(keysToMark);
      await prefs.setStringList(_readNotifKeysKey, keys.toList());
    } catch (_) {}
  }

  static const String _deletedNotifKeysKey = 'deleted_notification_keys';

  Future<Set<String>> getDeletedKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_deletedNotifKeysKey) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markKeyAsDeleted(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = await getDeletedKeys();
      keys.add(key);
      await prefs.setStringList(_deletedNotifKeysKey, keys.toList());

      // Jika notifikasi FCM, hapus permanen dari list FCM untuk efisiensi memori
      if (key.startsWith('fcm_')) {
        final fcmId = key.substring(4);
        final notifs = await getSavedFcmNotifications();
        notifs.removeWhere((item) => item.id == fcmId);
        final listJson = notifs.map((item) => jsonEncode(item.toJson())).toList();
        await prefs.setStringList(_fcmNotifsKey, listJson);
      }
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmNotifsKey);
      await prefs.remove(_readNotifKeysKey);
      await prefs.remove(_deletedNotifKeysKey);
    } catch (_) {}
  }

  /// Menghitung unread count secara dinamis untuk ikon lonceng Dashboard
  Future<int> getUnreadCount({
    required List<dynamic> todayJadwals,
    required Set<int> takenJadwalIds,
    required List<dynamic> riwayatData,
  }) async {
    try {
      final readKeys = await getReadKeys();
      final deletedKeys = await getDeletedKeys();
      final fcmNotifs = await getSavedFcmNotifications();
      
      int unreadCount = 0;
      
      // 1. Hitung FCM yang belum dibaca
      for (final notif in fcmNotifs) {
        final key = 'fcm_${notif.id}';
        if (deletedKeys.contains(key)) continue;
        if (!readKeys.contains(key)) {
          unreadCount++;
        }
      }
      
      final now = DateTime.now();
      
      // Helper check expired (>75 menit terlambat)
      bool isTimeExpired(String waktu) {
        try {
          final parts = waktu.split(':');
          if (parts.length < 2) return false;
          final jadwalDt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          return now.difference(jadwalDt).inMinutes > 75;
        } catch (_) { return false; }
      }
      
      // Helper check arrived
      bool hasTimeArrived(String waktu) {
        try {
          final parts = waktu.split(':');
          if (parts.length < 2) return false;
          final jadwalDt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          return now.isAfter(jadwalDt) || now.isAtSameMomentAs(jadwalDt);
        } catch (_) { return false; }
      }
      
      // 2. Hitung dynamic mendatang
      for (final jadwal in todayJadwals) {
        final String waktuStr = (jadwal['waktu_minum'] ?? jadwal['jam'] ?? '00:00').toString();
        final jadwalId = jadwal['id'] ?? jadwal['jadwal_id'];
        final parsedJadwalId = int.tryParse(jadwalId.toString());
        
        if (parsedJadwalId == null) continue;
        
        final List<String> times = waktuStr
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
            
        for (final waktu in times) {
          if (isTimeExpired(waktu)) continue;
          if (takenJadwalIds.contains(parsedJadwalId)) continue;
          
          if (hasTimeArrived(waktu)) {
            final key = 'dynamic_${parsedJadwalId}_$waktu';
            if (!deletedKeys.contains(key) && !readKeys.contains(key)) {
              unreadCount++;
            }
          }
          
          // 15 menit sebelum
          try {
            final timeParts = waktu.split(':');
            if (timeParts.length == 2) {
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);
              minute -= 15;
              if (minute < 0) {
                minute += 60;
                hour -= 1;
                if (hour < 0) hour = 23;
              }
              final advanceTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              if (!isTimeExpired(advanceTime) && hasTimeArrived(advanceTime)) {
                final key = 'dynamic_${parsedJadwalId}_$advanceTime';
                if (!deletedKeys.contains(key) && !readKeys.contains(key)) {
                  unreadCount++;
                }
              }
            }
          } catch (_) {}
        }
      }
      
      // 3. Hitung dynamic terlewat
      for (final tracking in riwayatData) {
        final status = tracking['status'] as String? ?? '';
        final waktu = tracking['waktu_minum'] ?? tracking['jadwal'] ?? '00:00';
        final tanggal = tracking['tanggal'] as String? ?? '';
        final jadwalId = tracking['jadwal_id'];
        final parsedJadwalId = int.tryParse(jadwalId.toString());
        
        if (parsedJadwalId == null) continue;
        
        if (status == 'Terlewat') {
          try {
            final trackingDate = DateTime.parse(tanggal);
            final isToday = trackingDate.year == now.year &&
                trackingDate.month == now.month &&
                trackingDate.day == now.day;
                
            if (isToday) {
              final key = 'dynamic_${parsedJadwalId}_$waktu';
              if (!deletedKeys.contains(key) && !readKeys.contains(key)) {
                unreadCount++;
              }
            }
          } catch (_) {}
        }
      }
      
      return unreadCount;
    } catch (_) {
      return 0;
    }
  }
}
