import 'jadwal.dart';

class Dashboard {
  final int pasienId;
  final String nama;
  final String email;
  final String noTelepon;
  final String jenisKelamin;
  final String tanggalLahir;
  final String alamat;
  final List<Jadwal> todayJadwals;
  final List<Jadwal> allJadwals;

  Dashboard({
    required this.pasienId,
    required this.nama,
    required this.email,
    required this.noTelepon,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.alamat,
    required this.todayJadwals,
    required this.allJadwals,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    var todayList = json['today_jadwals'] as List<dynamic>? ?? [];
    var allList = json['all_jadwals'] as List<dynamic>? ?? [];

    return Dashboard(
      pasienId: json['pasien_id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      alamat: json['alamat'] ?? '',
      todayJadwals: todayList
          .map((item) => Jadwal.fromJson(item as Map<String, dynamic>))
          .toList(),
      allJadwals: allList
          .map((item) => Jadwal.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'nama': nama,
      'email': email,
      'no_telepon': noTelepon,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
      'today_jadwals': todayJadwals.map((j) => j.toJson()).toList(),
      'all_jadwals': allJadwals.map((j) => j.toJson()).toList(),
    };
  }
}
