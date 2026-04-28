class JadwalRutinitasItem {
  final int jadwalRutinitasId;
  final String namaAktivitas;
  final String jamMulai;
  final String jamSelesai;
  final String status;
  final List<String> pengulangan;

  JadwalRutinitasItem({
    required this.jadwalRutinitasId,
    required this.namaAktivitas,
    required this.jamMulai,
    required this.jamSelesai,
    required this.status,
    required this.pengulangan,
  });

  // --- TAMBAHKAN BAGIAN INI ---
  factory JadwalRutinitasItem.fromJson(Map<String, dynamic> json) {
    return JadwalRutinitasItem(
      jadwalRutinitasId: json['jadwal_rutinitas_id'] ?? 0,
      namaAktivitas: json['nama_aktivitas'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      status: json['status'] ?? 'none',
      // Jika pengulangan datang sebagai string atau list dari backend
      pengulangan: json['pengulangan'] != null 
          ? List<String>.from(json['pengulangan']) 
          : [],
    );
  }
}