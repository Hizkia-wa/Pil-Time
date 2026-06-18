import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service untuk meminta izin-izin khusus Android yang dibutuhkan agar
/// alarm Pil Time bisa muncul otomatis di atas layar meskipun app ditutup.
///
/// Izin yang diminta:
///   1. SYSTEM_ALERT_WINDOW — "Display over other apps" (fullScreenIntent)
///   2. REQUEST_IGNORE_BATTERY_OPTIMIZATIONS — agar app tidak dimatikan Doze
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  static const _channel = MethodChannel('com.piltime.app/permissions');

  // ── Cek & minta semua izin yang dibutuhkan untuk alarm ──────────────────
  /// Panggil ini SEKALI saat app pertama kali dibuka (di initState atau main).
  /// Akan menampilkan dialog penjelasan sebelum membuka pengaturan sistem.
  Future<void> requestAlarmPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;

    // 1. Display over other apps (SYSTEM_ALERT_WINDOW)
    final needOverlay = await _needsOverlayPermission();
    if (needOverlay && context.mounted) {
      await _showOverlayPermissionDialog(context);
    }

    // 2. Ignore battery optimization
    final needBattery = await _needsBatteryOptimizationExemption();
    if (needBattery && context.mounted) {
      await _showBatteryOptimizationDialog(context);
    }
  }

  // ── CEK STATUS IZIN ──────────────────────────────────────────────────────

  Future<bool> _needsOverlayPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('canDrawOverlays');
      return !granted;
    } catch (e) {
      debugPrint('[PermissionService] canDrawOverlays error: $e');
      return false;
    }
  }

  Future<bool> _needsBatteryOptimizationExemption() async {
    try {
      final bool ignoring =
          await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return !ignoring;
    } catch (e) {
      debugPrint('[PermissionService] isIgnoringBatteryOptimizations error: $e');
      return false;
    }
  }

  // ── BUKA PENGATURAN SISTEM ───────────────────────────────────────────────

  Future<void> _openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (e) {
      debugPrint('[PermissionService] openOverlaySettings error: $e');
    }
  }

  Future<void> _openBatteryOptimizationSettings() async {
    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
    } catch (e) {
      debugPrint('[PermissionService] openBatteryOptimizationSettings error: $e');
    }
  }

  // ── DIALOG PENJELASAN ────────────────────────────────────────────────────

  Future<void> _showOverlayPermissionDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PermissionDialog(
        icon: Icons.alarm_rounded,
        iconColor: const Color(0xFF15BE77),
        title: 'Izinkan Alarm Muncul Otomatis',
        description:
            'Agar alarm pengingat minum obat dapat muncul langsung '
            'di layar Anda — bahkan saat aplikasi sedang tidak dibuka — '
            'aktifkan izin "Tampil di atas aplikasi lain" untuk Pil Time.\n\n'
            'Izin ini TIDAK digunakan untuk iklan atau memantau aktivitas Anda.',
        settingsLabel: 'Buka Pengaturan',
        skipLabel: 'Nanti Saja',
      ),
    );

    if (confirmed == true) {
      await _openOverlaySettings();
    }
  }

  Future<void> _showBatteryOptimizationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PermissionDialog(
        icon: Icons.battery_charging_full_rounded,
        iconColor: const Color(0xFF15BE77),
        title: 'Jangan Matikan Alarm saat HP Hemat Daya',
        description:
            'Beberapa HP (terutama Xiaomi, OPPO, Vivo) secara otomatis '
            'menghentikan aplikasi untuk menghemat baterai. '
            'Izinkan Pil Time berjalan di latar belakang agar alarm '
            'tidak terlewat saat HP dalam mode hemat daya.',
        settingsLabel: 'Izinkan',
        skipLabel: 'Nanti Saja',
      ),
    );

    if (confirmed == true) {
      await _openBatteryOptimizationSettings();
    }
  }
}

// ── DIALOG UI ────────────────────────────────────────────────────────────────
class _PermissionDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String settingsLabel;
  final String skipLabel;

  const _PermissionDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.settingsLabel,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: iconColor),
              ),
              const SizedBox(height: 20),
              // Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              // Deskripsi
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Tombol Izinkan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    settingsLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol Skip
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    skipLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
