class Jadwal {
  final int id;
  final int pasienId;
  final String pasienNama;
  final String namaObat;
  final int jumlahDosis;
  final String satuan;
  final String kategoriObat;
  final String takaranObat;
  final String frekuensiPerHari;
  final String waktuMinum;
  final String aturanKonsumsi;
  final String catatan;
  final String tipeDurasi;
  final int jumlahHari;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String waktuReminderPagi;
  final String waktuReminderMalam;
  final String status;
  final String createdAt;
  final String updatedAt;

  Jadwal({
    required this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.namaObat,
    required this.jumlahDosis,
    required this.satuan,
    required this.kategoriObat,
    required this.takaranObat,
    required this.frekuensiPerHari,
    required this.waktuMinum,
    required this.aturanKonsumsi,
    required this.catatan,
    required this.tipeDurasi,
    required this.jumlahHari,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.waktuReminderPagi,
    required this.waktuReminderMalam,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] ?? 0,
      pasienId: json['pasien_id'] ?? 0,
      pasienNama: json['pasien_nama'] ?? '',
      namaObat: json['nama_obat'] ?? '',
      jumlahDosis: json['jumlah_dosis'] ?? 0,
      satuan: json['satuan'] ?? '',
      kategoriObat: json['kategori_obat'] ?? '',
      takaranObat: json['takaran_obat'] ?? '',
      frekuensiPerHari: json['frekuensi_per_hari'] ?? '',
      waktuMinum: json['waktu_minum'] ?? '',
      aturanKonsumsi: json['aturan_konsumsi'] ?? '',
      catatan: json['catatan'] ?? '',
      tipeDurasi: json['tipe_durasi'] ?? '',
      jumlahHari: json['jumlah_hari'] ?? 0,
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      waktuReminderPagi: json['waktu_reminder_pagi'] ?? '',
      waktuReminderMalam: json['waktu_reminder_malam'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'pasien_nama': pasienNama,
      'nama_obat': namaObat,
      'jumlah_dosis': jumlahDosis,
      'satuan': satuan,
      'kategori_obat': kategoriObat,
      'takaran_obat': takaranObat,
      'frekuensi_per_hari': frekuensiPerHari,
      'waktu_minum': waktuMinum,
      'aturan_konsumsi': aturanKonsumsi,
      'catatan': catatan,
      'tipe_durasi': tipeDurasi,
      'jumlah_hari': jumlahHari,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'waktu_reminder_pagi': waktuReminderPagi,
      'waktu_reminder_malam': waktuReminderMalam,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
