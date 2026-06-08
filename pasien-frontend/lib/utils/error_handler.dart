import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Koneksi internet terputus. Pastikan Anda terhubung ke jaringan internet.';
    } else if (error is TimeoutException) {
      return 'Koneksi ke server terlalu lama. Server mungkin sedang sibuk.';
    } else if (error is FormatException) {
      return 'Gagal memproses data dari server. Coba lagi nanti.';
    } else if (error is PlatformException) {
      return 'Terdapat masalah pada sistem perangkat Anda.';
    } else {
      String msg = error.toString();
      
      // Bersihkan prefix teknis bawaan Dart
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring(11); // "Exception: ".length == 11
      }
      
      // Jika pesan masih berbau teknis, samarkan menjadi pesan ramah
      if (msg.contains('TypeError') || 
          msg.contains('NoSuchMethodError') || 
          msg.contains('Connection refused') || 
          msg.contains('HandshakeException')) {
        return 'Terjadi kesalahan sistem internal. Silakan coba beberapa saat lagi.';
      }
      
      return msg;
    }
  }
}
