class Pasien {
  final int pasienId;
  final String nama;
  final String email;
  final String noTelepon;
  final String jenisKelamin;
  final String tanggalLahir;
  final String alamat;

  Pasien({
    required this.pasienId,
    required this.nama,
    required this.email,
    required this.noTelepon,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      pasienId: json['pasien_id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      alamat: json['alamat'] ?? '',
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
    };
  }
}
