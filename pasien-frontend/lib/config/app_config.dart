class AppConfig {
  // ========== APP INFO ==========
  static const String appName = 'Pil Time';
  static const String primaryColor = '0xFF15BE77';
  static const String hasSeenOnboardingKey = 'hasSeenOnboarding';

  // ========== BACKEND URL CONFIGURATION ==========
  /// Pilih salah satu konfigurasi sesuai target:
  /// - PHYSICAL DEVICE (USB/WiFi): gunakan 172.30.42.29
  /// - ANDROID EMULATOR: gunakan 10.0.2.2
  ///
  /// Caranya: uncomment yang diinginkan, comment yang lain

  // PHYSICAL DEVICE CONFIG
  static const String baseUrl = 'http://172.30.42.29:8080';
  static const String authServiceUrl = 'http://172.30.42.29:8081';

  // EMULATOR CONFIG (Uncomment ini untuk emulator)
  // static const String baseUrl = 'http://10.0.2.2:8080';
  // static const String authServiceUrl = 'http://10.0.2.2:8081';

  // ========== API ENDPOINTS ==========
  static const String authLogin = '$authServiceUrl/auth/pasien/login';
  static const String authRegister = '$authServiceUrl/auth/pasien/register';
  static const String authResetPassword =
      '$authServiceUrl/auth/pasien/reset-password';

  static const String pasienJadwal = '$baseUrl/api/pasien/jadwal';
  static const String pasienRiwayat = '$baseUrl/api/pasien/riwayat';
  static const String pasienRutinitas = '$baseUrl/api/pasien/rutinitas';
  static const String pasienFcmToken = '$baseUrl/api/pasien/fcm-token';
  static const String adminJadwal = '$baseUrl/api/admin/jadwal';

  // Connection timeout (detik)
  static const int timeoutDuration = 10;
}
