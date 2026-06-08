import 'package:flutter/material.dart';

class DialogHelper {
  static const Color emerald = Color(0xFF15BE77);

  /// Menampilkan dialog sukses
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    // Hilangkan emoji jika ada dari pesan
    final cleanMessage = message.replaceAll(RegExp(r'[^\w\s.,!?:\-]'), '').trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: emerald, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            cleanMessage,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onClose != null) {
                  onClose();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: emerald,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  /// Menampilkan dialog error
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    // Hilangkan emoji jika ada dari pesan
    final cleanMessage = message.replaceAll(RegExp(r'[^\w\s.,!?:\-]'), '').trim();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            cleanMessage,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
